using Microsoft.AspNetCore.Mvc;
using SkillsAuditSystem.Models;
using SkillsAuditSystem.Models.ViewModels;
using SkillsAuditSystem.Services;

namespace SkillsAuditSystem.Controllers
{
    public class EmployeeController : BaseController
    {
        private readonly IFirestoreService _firestoreService;
        private readonly IFirebaseAuthService _authService;
        private readonly INotificationService _notificationService;
        private readonly IReportService _reportService;
        private readonly ILogger<EmployeeController> _logger;

        public EmployeeController(
            IFirestoreService firestoreService,
            IFirebaseAuthService authService,
            INotificationService notificationService,
            IReportService reportService,
            ILogger<EmployeeController> logger)
        {
            _firestoreService = firestoreService;
            _authService = authService;
            _notificationService = notificationService;
            _reportService = reportService;
            _logger = logger;
        }

        // GET: Employee
        public async Task<IActionResult> Index()
        {
            try
            {
                var employees = await _firestoreService.GetAllEmployeesAsync();
                return View(employees.OrderBy(e => e.Name).ToList());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading employees: {ex.Message}");
                SetErrorMessage("An error occurred while loading employees.");
                return View(new List<Employee>());
            }
        }

        // GET: Employee/Details/5
        public async Task<IActionResult> Details(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            try
            {
                var employee = await _firestoreService.GetEmployeeByIdAsync(id);

                if (employee == null)
                {
                    return NotFound();
                }

                var viewModel = new EmployeeDetailsViewModel
                {
                    Employee = employee,
                    Qualifications = await _firestoreService.GetQualificationsByEmployeeIdAsync(id),
                    Trainings = await _firestoreService.GetTrainingsByEmployeeIdAsync(id),
                    Skills = await _firestoreService.GetSkillsByEmployeeIdAsync(id)
                };

                // Calculate statistics
                viewModel.TotalQualifications = viewModel.Qualifications.Count;
                viewModel.ApprovedQualifications = viewModel.Qualifications.Count(q => q.Status == "approved");
                viewModel.PendingQualifications = viewModel.Qualifications.Count(q => q.Status == "pending");
                viewModel.CompletedTrainings = viewModel.Trainings.Count(t => t.Status == "completed");
                viewModel.InProgressTrainings = viewModel.Trainings.Count(t => t.Status == "in_progress");
                viewModel.TotalSkills = viewModel.Skills.Count;

                return View(viewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading employee details: {ex.Message}");
                SetErrorMessage("An error occurred while loading employee details.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Employee/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Employee/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(CreateEmployeeViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            try
            {
                // Create Firebase Authentication account
                var (success, uid, message) = await _authService.CreateEmployeeAccountAsync(
                    model.Email,
                    model.Password,
                    model.Name
                );

                if (!success)
                {
                    ModelState.AddModelError(string.Empty, message);
                    return View(model);
                }

                // Create employee record in Firestore
                var employee = new Employee
                {
                    Uid = uid,
                    Name = model.Name,
                    Email = model.Email,
                    CellNumber = model.CellNumber,
                    Profession = model.Profession,
                    Role = "employee",
                    IsActive = true
                };

                var created = await _firestoreService.CreateEmployeeAsync(employee);

                if (created)
                {
                    _logger.LogInformation($"Employee created: {employee.Email}");
                    SetSuccessMessage($"Employee '{employee.Name}' created successfully! Login credentials have been set up.");
                    return RedirectToAction(nameof(Index));
                }
                else
                {
                    // Rollback: Delete Firebase Auth account
                    await _authService.DeleteUserAsync(uid);
                    ModelState.AddModelError(string.Empty, "Failed to create employee record.");
                    return View(model);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating employee: {ex.Message}");
                ModelState.AddModelError(string.Empty, "An error occurred while creating the employee.");
                return View(model);
            }
        }

        // GET: Employee/Edit/5
        public async Task<IActionResult> Edit(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            try
            {
                var employee = await _firestoreService.GetEmployeeByIdAsync(id);

                if (employee == null)
                {
                    return NotFound();
                }

                return View(employee);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading employee for edit: {ex.Message}");
                SetErrorMessage("An error occurred while loading employee data.");
                return RedirectToAction(nameof(Index));
            }
        }

        // POST: Employee/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(string id, Employee employee)
        {
            if (id != employee.Id)
            {
                return NotFound();
            }

            if (!ModelState.IsValid)
            {
                return View(employee);
            }

            try
            {
                var updated = await _firestoreService.UpdateEmployeeAsync(employee);

                if (updated)
                {
                    SetSuccessMessage("Employee updated successfully!");

                    // Send notification to employee
                    await _notificationService.SendProfileUpdateNotificationAsync(
                        employee.Uid,
                        "Your profile has been updated by HR."
                    );

                    return RedirectToAction(nameof(Details), new { id = employee.Id });
                }
                else
                {
                    ModelState.AddModelError(string.Empty, "Failed to update employee.");
                    return View(employee);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating employee: {ex.Message}");
                ModelState.AddModelError(string.Empty, "An error occurred while updating the employee.");
                return View(employee);
            }
        }

        // POST: Employee/ToggleStatus/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ToggleStatus(string id)
        {
            try
            {
                var employee = await _firestoreService.GetEmployeeByIdAsync(id);

                if (employee == null)
                {
                    return NotFound();
                }

                employee.IsActive = !employee.IsActive;
                var updated = await _firestoreService.UpdateEmployeeAsync(employee);

                if (updated)
                {
                    // Update Firebase Auth status
                    await _authService.SetUserStatusAsync(employee.Uid, !employee.IsActive);

                    SetSuccessMessage($"Employee {(employee.IsActive ? "activated" : "deactivated")} successfully!");
                }
                else
                {
                    SetErrorMessage("Failed to update employee status.");
                }

                return RedirectToAction(nameof(Details), new { id });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error toggling employee status: {ex.Message}");
                SetErrorMessage("An error occurred while updating employee status.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Employee/Delete/5
        public async Task<IActionResult> Delete(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            try
            {
                var employee = await _firestoreService.GetEmployeeByIdAsync(id);

                if (employee == null)
                {
                    return NotFound();
                }

                return View(employee);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading employee for deletion: {ex.Message}");
                SetErrorMessage("An error occurred while loading employee data.");
                return RedirectToAction(nameof(Index));
            }
        }

        // POST: Employee/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(string id)
        {
            try
            {
                var employee = await _firestoreService.GetEmployeeByIdAsync(id);

                if (employee == null)
                {
                    return NotFound();
                }

                // Delete from Firestore
                var deleted = await _firestoreService.DeleteEmployeeAsync(id);

                if (deleted)
                {
                    // Delete from Firebase Auth
                    await _authService.DeleteUserAsync(employee.Uid);

                    SetSuccessMessage("Employee deleted successfully!");
                    return RedirectToAction(nameof(Index));
                }
                else
                {
                    SetErrorMessage("Failed to delete employee.");
                    return RedirectToAction(nameof(Delete), new { id });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting employee: {ex.Message}");
                SetErrorMessage("An error occurred while deleting the employee.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Employee/ExportPdf
        public async Task<IActionResult> ExportPdf()
        {
            try
            {
                var employees = await _firestoreService.GetAllEmployeesAsync();
                var pdfBytes = await _reportService.GenerateEmployeesPdfReportAsync(employees);

                return File(pdfBytes, "application/pdf", $"Employees_Report_{DateTime.Now:yyyyMMdd}.pdf");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error generating PDF: {ex.Message}");
                SetErrorMessage("An error occurred while generating the PDF report.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Employee/ExportExcel
        public async Task<IActionResult> ExportExcel()
        {
            try
            {
                var employees = await _firestoreService.GetAllEmployeesAsync();
                var excelBytes = await _reportService.GenerateEmployeesExcelReportAsync(employees);

                return File(excelBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    $"Employees_Report_{DateTime.Now:yyyyMMdd}.xlsx");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error generating Excel: {ex.Message}");
                SetErrorMessage("An error occurred while generating the Excel report.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Employee/DetailedReport/5
        public async Task<IActionResult> DetailedReport(string id)
        {
            try
            {
                var employee = await _firestoreService.GetEmployeeByIdAsync(id);

                if (employee == null)
                {
                    return NotFound();
                }

                var qualifications = await _firestoreService.GetQualificationsByEmployeeIdAsync(id);
                var skills = await _firestoreService.GetSkillsByEmployeeIdAsync(id);
                var trainings = await _firestoreService.GetTrainingsByEmployeeIdAsync(id);

                var pdfBytes = await _reportService.GenerateDetailedEmployeeReportAsync(
                    employee, qualifications, skills, trainings
                );

                return File(pdfBytes, "application/pdf", $"{employee.Name}_Detailed_Report_{DateTime.Now:yyyyMMdd}.pdf");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error generating detailed report: {ex.Message}");
                SetErrorMessage("An error occurred while generating the detailed report.");
                return RedirectToAction(nameof(Details), new { id });
            }
        }
    }
}