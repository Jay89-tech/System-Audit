using Microsoft.AspNetCore.Mvc;
using SkillsAuditSystem.Services;

namespace SkillsAuditSystem.Controllers
{
    public class ReportController : BaseController
    {
        private readonly IFirestoreService _firestoreService;
        private readonly IReportService _reportService;
        private readonly ILogger<ReportController> _logger;

        public ReportController(
            IFirestoreService firestoreService,
            IReportService reportService,
            ILogger<ReportController> logger)
        {
            _firestoreService = firestoreService;
            _reportService = reportService;
            _logger = logger;
        }

        // GET: Report/Index
        public IActionResult Index()
        {
            return View();
        }

        // GET: Report/SkillsAudit
        public async Task<IActionResult> SkillsAudit()
        {
            try
            {
                var skillsDistribution = await _firestoreService.GetSkillCategoriesDistributionAsync();
                var professionDistribution = await _firestoreService.GetEmployeesByProfessionAsync();

                ViewBag.SkillsDistribution = skillsDistribution;
                ViewBag.ProfessionDistribution = professionDistribution;

                return View();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading skills audit: {ex.Message}");
                SetErrorMessage("An error occurred while loading the skills audit.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Report/ExportSkillsAudit
        public async Task<IActionResult> ExportSkillsAudit()
        {
            try
            {
                var skillsDistribution = await _firestoreService.GetSkillCategoriesDistributionAsync();
                var professionDistribution = await _firestoreService.GetEmployeesByProfessionAsync();

                var excelBytes = await _reportService.GenerateSkillsAuditSummaryAsync(
                    skillsDistribution,
                    professionDistribution
                );

                return File(excelBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    $"Skills_Audit_Summary_{DateTime.Now:yyyyMMdd}.xlsx");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error exporting skills audit: {ex.Message}");
                SetErrorMessage("An error occurred while generating the report.");
                return RedirectToAction(nameof(SkillsAudit));
            }
        }

        // GET: Report/WorkforcePlanning
        public async Task<IActionResult> WorkforcePlanning()
        {
            try
            {
                var employees = await _firestoreService.GetAllEmployeesAsync();
                var professionDistribution = await _firestoreService.GetEmployeesByProfessionAsync();
                var trainingDistribution = await _firestoreService.GetTrainingStatusDistributionAsync();

                ViewBag.TotalEmployees = employees.Count;
                ViewBag.ActiveEmployees = employees.Count(e => e.IsActive);
                ViewBag.ProfessionDistribution = professionDistribution;
                ViewBag.TrainingDistribution = trainingDistribution;

                // Get employees grouped by profession
                var employeesByProfession = employees
                    .GroupBy(e => e.Profession)
                    .ToDictionary(g => g.Key, g => g.ToList());

                return View(employeesByProfession);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading workforce planning: {ex.Message}");
                SetErrorMessage("An error occurred while loading workforce planning data.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Report/QualificationsSummary
        public async Task<IActionResult> QualificationsSummary()
        {
            try
            {
                var employees = await _firestoreService.GetAllEmployeesAsync();
                var qualificationsSummary = new Dictionary<string, Dictionary<string, int>>();

                int totalQualifications = 0;
                int approvedQualifications = 0;
                int pendingQualifications = 0;
                int rejectedQualifications = 0;

                foreach (var employee in employees)
                {
                    var qualifications = await _firestoreService.GetQualificationsByEmployeeIdAsync(employee.Id);

                    totalQualifications += qualifications.Count;
                    approvedQualifications += qualifications.Count(q => q.Status == "approved");
                    pendingQualifications += qualifications.Count(q => q.Status == "pending");
                    rejectedQualifications += qualifications.Count(q => q.Status == "rejected");

                    var statusCounts = new Dictionary<string, int>
                    {
                        { "Total", qualifications.Count },
                        { "Approved", qualifications.Count(q => q.Status == "approved") },
                        { "Pending", qualifications.Count(q => q.Status == "pending") },
                        { "Rejected", qualifications.Count(q => q.Status == "rejected") }
                    };

                    qualificationsSummary[employee.Name] = statusCounts;
                }

                ViewBag.TotalQualifications = totalQualifications;
                ViewBag.ApprovedQualifications = approvedQualifications;
                ViewBag.PendingQualifications = pendingQualifications;
                ViewBag.RejectedQualifications = rejectedQualifications;

                return View(qualificationsSummary);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading qualifications summary: {ex.Message}");
                SetErrorMessage("An error occurred while loading qualifications summary.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Report/TrainingOverview
        public async Task<IActionResult> TrainingOverview()
        {
            try
            {
                var employees = await _firestoreService.GetAllEmployeesAsync();
                var trainingOverview = new List<(string EmployeeName, int TotalTrainings, int Completed, int InProgress, int NotStarted, int Suggested)>();

                int totalTrainings = 0;
                int completedCount = 0;
                int inProgressCount = 0;
                int notStartedCount = 0;
                int suggestedCount = 0;

                foreach (var employee in employees)
                {
                    var trainings = await _firestoreService.GetTrainingsByEmployeeIdAsync(employee.Id);

                    var completed = trainings.Count(t => t.Status == "completed");
                    var inProgress = trainings.Count(t => t.Status == "in_progress");
                    var notStarted = trainings.Count(t => t.Status == "not_started");
                    var suggested = trainings.Count(t => t.Status == "suggested");

                    totalTrainings += trainings.Count;
                    completedCount += completed;
                    inProgressCount += inProgress;
                    notStartedCount += notStarted;
                    suggestedCount += suggested;

                    trainingOverview.Add((employee.Name, trainings.Count, completed, inProgress, notStarted, suggested));
                }

                ViewBag.TotalTrainings = totalTrainings;
                ViewBag.CompletedCount = completedCount;
                ViewBag.InProgressCount = inProgressCount;
                ViewBag.NotStartedCount = notStartedCount;
                ViewBag.SuggestedCount = suggestedCount;

                return View(trainingOverview);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading training overview: {ex.Message}");
                SetErrorMessage("An error occurred while loading training overview.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Report/SkillsGapAnalysis
        public async Task<IActionResult> SkillsGapAnalysis()
        {
            try
            {
                var employees = await _firestoreService.GetAllEmployeesAsync();
                var skillsData = new Dictionary<string, List<(string SkillName, string Proficiency, string Category)>>();

                foreach (var employee in employees)
                {
                    var skills = await _firestoreService.GetSkillsByEmployeeIdAsync(employee.Id);
                    var skillsList = skills.Select(s => (s.SkillName, s.ProficiencyLevel, s.Category)).ToList();
                    skillsData[employee.Name] = skillsList;
                }

                var skillCategories = await _firestoreService.GetSkillCategoriesDistributionAsync();
                ViewBag.SkillCategories = skillCategories;

                return View(skillsData);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading skills gap analysis: {ex.Message}");
                SetErrorMessage("An error occurred while loading skills gap analysis.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Report/ComprehensivePdf
        public async Task<IActionResult> ComprehensivePdf()
        {
            try
            {
                var employees = await _firestoreService.GetAllEmployeesAsync();
                var pdfBytes = await _reportService.GenerateEmployeesPdfReportAsync(employees);

                return File(pdfBytes, "application/pdf", $"Comprehensive_Report_{DateTime.Now:yyyyMMdd}.pdf");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error generating comprehensive PDF: {ex.Message}");
                SetErrorMessage("An error occurred while generating the PDF report.");
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Report/ComprehensiveExcel
        public async Task<IActionResult> ComprehensiveExcel()
        {
            try
            {
                var employees = await _firestoreService.GetAllEmployeesAsync();
                var excelBytes = await _reportService.GenerateEmployeesExcelReportAsync(employees);

                return File(excelBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    $"Comprehensive_Report_{DateTime.Now:yyyyMMdd}.xlsx");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error generating comprehensive Excel: {ex.Message}");
                SetErrorMessage("An error occurred while generating the Excel report.");
                return RedirectToAction(nameof(Index));
            }
        }
    }
}