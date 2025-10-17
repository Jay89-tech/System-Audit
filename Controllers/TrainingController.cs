using Microsoft.AspNetCore.Mvc;
using SkillsAuditSystem.Models;
using SkillsAuditSystem.Models.ViewModels;
using SkillsAuditSystem.Services;

namespace SkillsAuditSystem.Controllers
{
    public class TrainingController : BaseController
    {
        private readonly IFirestoreService _firestoreService;
        private readonly INotificationService _notificationService;
        private readonly IReportService _reportService;
        private readonly ILogger<TrainingController> _logger;

        public TrainingController(
            IFirestoreService firestoreService,
            INotificationService notificationService,
            IReportService reportService,
            ILogger<TrainingController> logger)
        {
            _firestoreService = firestoreService;
            _notificationService = notificationService;
            _reportService = reportService;
            _logger = logger;
        }

        // GET: Training
        public async Task<IActionResult> Index()
        {
            try
            {
                var employees = await _firestoreService.GetAllEmployeesAsync();
                var allTrainings = new List<(Training Training, Employee Employee)>();

                foreach (var employee in employees)
                {
                    var trainings = await _firestoreService.GetTrainingsByEmployeeIdAsync(employee.Id);
                    foreach (var training in trainings)
                    {
                        allTrainings.Add((training, employee));
                    }
                }

                return View(allTrainings.OrderByDescending(t => t.Training.CreatedAt).ToList());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading trainings: {ex.Message}");
                SetErrorMessage("An error occurred while loading trainings.");
                return View(new List<(Training, Employee)>());
            }
        }

        // GET: Training/SuggestTraining/5
        public async Task<IActionResult> SuggestTraining(string employeeId)
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

                ViewBag.Employee = employee;

                var viewModel = new SuggestTrainingViewModel
                {
                    EmployeeId = employeeId
                };

                return View(viewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading suggest training page: {ex.Message}");
                SetErrorMessage("An error occurred while loading the page.");
                return RedirectToAction("Details", "Employee", new { id = employeeId });
            }
        }

        // POST: Training/SuggestTraining
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SuggestTraining(SuggestTrainingViewModel model)
        {
            if (!ModelState.IsValid)
            {
                var employee = await _firestoreService.GetEmployeeByIdAsync(model.EmployeeId);
                ViewBag.Employee = employee;
                return View(model);
            }

            try
            {
                var employee = await _firestoreService.GetEmployeeByIdAsync(model.EmployeeId);

                if (employee == null)
                {
                    return NotFound();
                }

                var training = new Training
                {
                    EmployeeId = model.EmployeeId,
                    TrainingName = model.TrainingName,
                    Description = model.Description,
                    Provider = model.Provider,
                    Status = "suggested",
                    StartDate = model.StartDate,
                    EndDate = model.EndDate,
                    SuggestedBy = CurrentEmployeeId,
                    Progress = 0
                };

                var created = await _firestoreService.CreateTrainingAsync(training);

                if (created)
                {
                    // Send notification to employee
                    await _notificationService.SendTrainingSuggestedNotificationAsync(
                        employee.Uid,
                        training.TrainingName
                    );

                    SetSuccessMessage($"Training '{training.TrainingName}' suggested successfully to {employee.Name}!");
                    _logger.LogInformation($"Training {training.TrainingName} suggested by {CurrentUserEmail} to {employee.Email}");

                    return RedirectToAction("Details", "Employee", new { id = model.EmployeeId });
                }
                else
                {
                    ModelState.AddModelError(string.Empty, "Failed to suggest training.");
                    ViewBag.Employee = employee;
                    return View(model);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error suggesting training: {ex.Message}");
                ModelState.AddModelError(string.Empty, "An error occurred while suggesting the training.");
                var employee = await _firestoreService.GetEmployeeByIdAsync(model.EmployeeId);
                ViewBag.Employee = employee;
                return View(model);
            }
        }

        // GET: Training/Details/5
        public async Task<IActionResult> Details(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            try
            {
                var training = await _firestoreService.GetTrainingByIdAsync(id);

                if (training == null)
                {
                    return NotFound();
                }

                var employee = await _firestoreService.GetEmployeeByIdAsync(training.EmployeeId);
                ViewBag.Employee = employee;

                return View(training);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading training details: {ex.Message}");
                SetErrorMessage("An error occurred while loading training details.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Training/Edit/5
        public async Task<IActionResult> Edit(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            try
            {
                var training = await _firestoreService.GetTrainingByIdAsync(id);

                if (training == null)
                {
                    return NotFound();
                }

                var employee = await _firestoreService.GetEmployeeByIdAsync(training.EmployeeId);
                ViewBag.Employee = employee;

                return View(training);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading training for edit: {ex.Message}");
                SetErrorMessage("An error occurred while loading training data.");
                return RedirectToAction(nameof(Index));
            }
        }

        // POST: Training/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(string id, Training training)
        {
            if (id != training.Id)
            {
                return NotFound();
            }

            if (!ModelState.IsValid)
            {
                var employee = await _firestoreService.GetEmployeeByIdAsync(training.EmployeeId);
                ViewBag.Employee = employee;
                return View(training);
            }

            try
            {
                var updated = await _firestoreService.UpdateTrainingAsync(training);

                if (updated)
                {
                    SetSuccessMessage("Training updated successfully!");
                    return RedirectToAction(nameof(Details), new { id = training.Id });
                }
                else
                {
                    ModelState.AddModelError(string.Empty, "Failed to update training.");
                    var employee = await _firestoreService.GetEmployeeByIdAsync(training.EmployeeId);
                    ViewBag.Employee = employee;
                    return View(training);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating training: {ex.Message}");
                ModelState.AddModelError(string.Empty, "An error occurred while updating the training.");
                var employee = await _firestoreService.GetEmployeeByIdAsync(training.EmployeeId);
                ViewBag.Employee = employee;
                return View(training);
            }
        }

        // GET: Training/ByEmployee/5
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

                var trainings = await _firestoreService.GetTrainingsByEmployeeIdAsync(employeeId);

                ViewBag.Employee = employee;
                return View(trainings.OrderByDescending(t => t.CreatedAt).ToList());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading employee trainings: {ex.Message}");
                SetErrorMessage("An error occurred while loading trainings.");
                return RedirectToAction("Index", "Employee");
            }
        }

        // GET: Training/Delete/5
        public async Task<IActionResult> Delete(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                return NotFound();
            }

            try
            {
                var training = await _firestoreService.GetTrainingByIdAsync(id);

                if (training == null)
                {
                    return NotFound();
                }

                var employee = await _firestoreService.GetEmployeeByIdAsync(training.EmployeeId);
                ViewBag.Employee = employee;

                return View(training);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading training for deletion: {ex.Message}");
                SetErrorMessage("An error occurred while loading training data.");
                return RedirectToAction(nameof(Index));
            }
        }

        // POST: Training/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(string id)
        {
            try
            {
                var training = await _firestoreService.GetTrainingByIdAsync(id);

                if (training == null)
                {
                    return NotFound();
                }

                var employeeId = training.EmployeeId;
                var deleted = await _firestoreService.DeleteTrainingAsync(id);

                if (deleted)
                {
                    SetSuccessMessage("Training deleted successfully!");
                    return RedirectToAction("Details", "Employee", new { id = employeeId });
                }
                else
                {
                    SetErrorMessage("Failed to delete training.");
                    return RedirectToAction(nameof(Delete), new { id });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting training: {ex.Message}");
                SetErrorMessage("An error occurred while deleting the training.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Training/ExportProgress
        public async Task<IActionResult> ExportProgress()
        {
            try
            {
                var employees = await _firestoreService.GetAllEmployeesAsync();
                var allTrainings = new List<Training>();

                foreach (var employee in employees)
                {
                    var trainings = await _firestoreService.GetTrainingsByEmployeeIdAsync(employee.Id);
                    allTrainings.AddRange(trainings);
                }

                var excelBytes = await _reportService.GenerateTrainingProgressReportAsync(allTrainings);

                return File(excelBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    $"Training_Progress_Report_{DateTime.Now:yyyyMMdd}.xlsx");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error generating training progress report: {ex.Message}");
                SetErrorMessage("An error occurred while generating the report.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Training/StatusReport
        public async Task<IActionResult> StatusReport()
        {
            try
            {
                var statusDistribution = await _firestoreService.GetTrainingStatusDistributionAsync();
                ViewBag.StatusDistribution = statusDistribution;

                var employees = await _firestoreService.GetAllEmployeesAsync();
                var allTrainings = new List<(Training Training, Employee Employee)>();

                foreach (var employee in employees)
                {
                    var trainings = await _firestoreService.GetTrainingsByEmployeeIdAsync(employee.Id);
                    foreach (var training in trainings)
                    {
                        allTrainings.Add((training, employee));
                    }
                }

                return View(allTrainings.OrderBy(t => t.Training.Status).ThenBy(t => t.Employee.Name).ToList());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading training status report: {ex.Message}");
                SetErrorMessage("An error occurred while loading the status report.");
                return RedirectToAction(nameof(Index));
            }
        }
    }
}