using Microsoft.AspNetCore.Mvc;
using SkillsAuditSystem.Models.ViewModels;
using SkillsAuditSystem.Services;

namespace SkillsAuditSystem.Controllers
{
    public class DashboardController : BaseController
    {
        private readonly IFirestoreService _firestoreService;
        private readonly ILogger<DashboardController> _logger;

        public DashboardController(
            IFirestoreService firestoreService,
            ILogger<DashboardController> logger)
        {
            _firestoreService = firestoreService;
            _logger = logger;
        }

        public async Task<IActionResult> Index()
        {
            try
            {
                var viewModel = new DashboardViewModel();

                // Get all employees
                var allEmployees = await _firestoreService.GetAllEmployeesAsync();
                var activeEmployees = allEmployees.Where(e => e.IsActive).ToList();

                viewModel.TotalEmployees = allEmployees.Count;
                viewModel.ActiveEmployees = activeEmployees.Count;

                // Get pending qualifications
                var pendingQualifications = await _firestoreService.GetPendingQualificationsAsync();
                viewModel.PendingApprovals = pendingQualifications.Count;
                viewModel.PendingQualifications = pendingQualifications.Take(5).ToList();

                // Get training statistics
                var completedTrainings = await _firestoreService.GetTrainingsByStatusAsync("completed");
                var inProgressTrainings = await _firestoreService.GetTrainingsByStatusAsync("in_progress");

                viewModel.CompletedTrainings = completedTrainings.Count;
                viewModel.InProgressTrainings = inProgressTrainings.Count;

                // Get suggested trainings
                var suggestedTrainings = await _firestoreService.GetSuggestedTrainingsAsync();
                viewModel.SuggestedTrainings = suggestedTrainings.Take(5).ToList();

                // Get recent employees
                viewModel.RecentEmployees = allEmployees
                    .OrderByDescending(e => e.CreatedAt)
                    .Take(5)
                    .ToList();

                // Get chart data
                viewModel.EmployeesByProfession = await _firestoreService.GetEmployeesByProfessionAsync();
                viewModel.TrainingStatusDistribution = await _firestoreService.GetTrainingStatusDistributionAsync();
                viewModel.SkillCategories = await _firestoreService.GetSkillCategoriesDistributionAsync();

                // Get total qualifications count
                int totalQualifications = 0;
                foreach (var employee in allEmployees)
                {
                    var qualifications = await _firestoreService.GetQualificationsByEmployeeIdAsync(employee.Id);
                    totalQualifications += qualifications.Count;
                }
                viewModel.TotalQualifications = totalQualifications;

                return View(viewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Dashboard error: {ex.Message}");
                SetErrorMessage("An error occurred while loading the dashboard.");
                return View(new DashboardViewModel());
            }
        }
    }
}