using Microsoft.AspNetCore.Mvc;
using SkillsAuditSystem.Models;
using SkillsAuditSystem.Services;

namespace SkillsAuditSystem.Controllers
{
    public class QualificationController : BaseController
    {
        private readonly IFirestoreService _firestoreService;
        private readonly INotificationService _notificationService;
        private readonly IStorageService _storageService;
        private readonly ILogger<QualificationController> _logger;

        public QualificationController(
            IFirestoreService firestoreService,
            INotificationService notificationService,
            IStorageService storageService,
            ILogger<QualificationController> logger)
        {
            _firestoreService = firestoreService;
            _notificationService = notificationService;
            _storageService = storageService;
            _logger = logger;
        }

        // GET: Qualification/PendingApprovals
        public async Task<IActionResult> PendingApprovals()
        {
            try
            {
                var pendingQualifications = await _firestoreService.GetPendingQualificationsAsync();

                // Get employee details for each qualification
                var qualificationsWithEmployees = new List<(Qualification Qualification, Employee Employee)>();

                foreach (var qualification in pendingQualifications)
                {
                    var employee = await _firestoreService.GetEmployeeByIdAsync(qualification.EmployeeId);
                    if (employee != null)
                    {
                        qualificationsWithEmployees.Add((qualification, employee));
                    }
                }

                return View(qualificationsWithEmployees);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading pending qualifications: {ex.Message}");
                SetErrorMessage("An error occurred while loading pending qualifications.");
                return View(new List<(Qualification, Employee)>());
            }
        }

        // GET: Qualification/Details/5
        public async Task<IActionResult> Details(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            try
            {
                var qualification = await _firestoreService.GetQualificationByIdAsync(id);

                if (qualification == null)
                {
                    return NotFound();
                }

                var employee = await _firestoreService.GetEmployeeByIdAsync(qualification.EmployeeId);

                ViewBag.Employee = employee;
                return View(qualification);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading qualification details: {ex.Message}");
                SetErrorMessage("An error occurred while loading qualification details.");
                return RedirectToAction(nameof(PendingApprovals));
            }
        }

        // POST: Qualification/Approve/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Approve(string id, string? notes)
        {
            try
            {
                var qualification = await _firestoreService.GetQualificationByIdAsync(id);

                if (qualification == null)
                {
                    return NotFound();
                }

                var employee = await _firestoreService.GetEmployeeByIdAsync(qualification.EmployeeId);

                if (employee == null)
                {
                    SetErrorMessage("Associated employee not found.");
                    return RedirectToAction(nameof(PendingApprovals));
                }

                // Approve qualification
                var approved = await _firestoreService.ApproveQualificationAsync(id, CurrentEmployeeId ?? "");

                if (approved)
                {
                    // Send notification to employee
                    await _notificationService.SendQualificationApprovedNotificationAsync(
                        employee.Uid,
                        qualification.QualificationName
                    );

                    SetSuccessMessage($"Qualification '{qualification.QualificationName}' approved successfully!");
                    _logger.LogInformation($"Qualification {id} approved by {CurrentUserEmail}");
                }
                else
                {
                    SetErrorMessage("Failed to approve qualification.");
                }

                return RedirectToAction(nameof(PendingApprovals));
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error approving qualification: {ex.Message}");
                SetErrorMessage("An error occurred while approving the qualification.");
                return RedirectToAction(nameof(PendingApprovals));
            }
        }

        // POST: Qualification/Reject/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Reject(string id, string rejectionReason)
        {
            if (string.IsNullOrWhiteSpace(rejectionReason))
            {
                SetErrorMessage("Please provide a reason for rejection.");
                return RedirectToAction(nameof(Details), new { id });
            }

            try
            {
                var qualification = await _firestoreService.GetQualificationByIdAsync(id);

                if (qualification == null)
                {
                    return NotFound();
                }

                var employee = await _firestoreService.GetEmployeeByIdAsync(qualification.EmployeeId);

                if (employee == null)
                {
                    SetErrorMessage("Associated employee not found.");
                    return RedirectToAction(nameof(PendingApprovals));
                }

                // Reject qualification
                var rejected = await _firestoreService.RejectQualificationAsync(id, rejectionReason);

                if (rejected)
                {
                    // Send notification to employee
                    await _notificationService.SendQualificationRejectedNotificationAsync(
                        employee.Uid,
                        qualification.QualificationName,
                        rejectionReason
                    );

                    SetInfoMessage($"Qualification '{qualification.QualificationName}' has been rejected.");
                    _logger.LogInformation($"Qualification {id} rejected by {CurrentUserEmail}. Reason: {rejectionReason}");
                }
                else
                {
                    SetErrorMessage("Failed to reject qualification.");
                }

                return RedirectToAction(nameof(PendingApprovals));
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error rejecting qualification: {ex.Message}");
                SetErrorMessage("An error occurred while rejecting the qualification.");
                return RedirectToAction(nameof(PendingApprovals));
            }
        }

        // GET: Qualification/ViewCertificate
        public async Task<IActionResult> ViewCertificate(string id)
        {
            try
            {
                var qualification = await _firestoreService.GetQualificationByIdAsync(id);

                if (qualification == null || string.IsNullOrEmpty(qualification.CertificateUrl))
                {
                    return NotFound();
                }

                // Redirect to the certificate URL in Firebase Storage
                return Redirect(qualification.CertificateUrl);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error viewing certificate: {ex.Message}");
                SetErrorMessage("An error occurred while accessing the certificate.");
                return RedirectToAction(nameof(PendingApprovals));
            }
        }

        // GET: Qualification/ByEmployee/5
        public async Task<IActionResult> ByEmployee(string employeeId)
        {
            if (string.IsNullOrEmpty(employeeId))
            {
                return NotFound();
            }

            try
            {
                var employee = await _firestoreService.GetEmployeeByIdAsync(employeeId);

                if (employee == null)
                {
                    return NotFound();
                }

                var qualifications = await _firestoreService.GetQualificationsByEmployeeIdAsync(employeeId);

                ViewBag.Employee = employee;
                return View(qualifications.OrderByDescending(q => q.CreatedAt).ToList());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading employee qualifications: {ex.Message}");
                SetErrorMessage("An error occurred while loading qualifications.");
                return RedirectToAction("Index", "Employee");
            }
        }

        // GET: Qualification/Delete/5
        public async Task<IActionResult> Delete(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            try
            {
                var qualification = await _firestoreService.GetQualificationByIdAsync(id);

                if (qualification == null)
                {
                    return NotFound();
                }

                var employee = await _firestoreService.GetEmployeeByIdAsync(qualification.EmployeeId);
                ViewBag.Employee = employee;

                return View(qualification);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading qualification for deletion: {ex.Message}");
                SetErrorMessage("An error occurred while loading qualification data.");
                return RedirectToAction(nameof(PendingApprovals));
            }
        }

        // POST: Qualification/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(string id)
        {
            try
            {
                var qualification = await _firestoreService.GetQualificationByIdAsync(id);

                if (qualification == null)
                {
                    return NotFound();
                }

                var employeeId = qualification.EmployeeId;

                // Delete certificate from storage if exists
                if (!string.IsNullOrEmpty(qualification.CertificateUrl))
                {
                    await _storageService.DeleteFileAsync(qualification.CertificateUrl);
                }

                // Delete qualification
                var deleted = await _firestoreService.DeleteQualificationAsync(id);

                if (deleted)
                {
                    SetSuccessMessage("Qualification deleted successfully!");
                    return RedirectToAction("Details", "Employee", new { id = employeeId });
                }
                else
                {
                    SetErrorMessage("Failed to delete qualification.");
                    return RedirectToAction(nameof(Delete), new { id });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting qualification: {ex.Message}");
                SetErrorMessage("An error occurred while deleting the qualification.");
                return RedirectToAction(nameof(PendingApprovals));
            }
        }
    }
}