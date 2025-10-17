using Microsoft.AspNetCore.Mvc;
using SkillsAuditSystem.Models.ViewModels;
using SkillsAuditSystem.Services;

namespace SkillsAuditSystem.Controllers
{
    public class AuthController : Controller
    {
        private readonly IFirebaseAuthService _authService;
        private readonly IFirestoreService _firestoreService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            IFirebaseAuthService authService,
            IFirestoreService firestoreService,
            ILogger<AuthController> logger)
        {
            _authService = authService;
            _firestoreService = firestoreService;
            _logger = logger;
        }

        [HttpGet]
        public IActionResult Login()
        {
            // If already logged in, redirect to dashboard
            if (!string.IsNullOrEmpty(HttpContext.Session.GetString("UserUid")))
            {
                return RedirectToAction("Index", "Dashboard");
            }

            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            try
            {
                // Authenticate with Firebase
                var (success, token, message) = await _authService.SignInAsync(model.Email, model.Password);

                if (!success)
                {
                    ModelState.AddModelError(string.Empty, message);
                    return View(model);
                }

                // Verify token and get user details
                var (isValid, uid, email) = await _authService.VerifyTokenAsync(token);

                if (!isValid)
                {
                    ModelState.AddModelError(string.Empty, "Authentication failed. Please try again.");
                    return View(model);
                }

                // Get employee details from Firestore
                var employee = await _firestoreService.GetEmployeeByUidAsync(uid);

                if (employee == null)
                {
                    ModelState.AddModelError(string.Empty, "Employee record not found.");
                    return View(model);
                }

                // Check if user is admin
                if (employee.Role != "admin")
                {
                    ModelState.AddModelError(string.Empty, "Access denied. Admin privileges required.");
                    return View(model);
                }

                // Store user info in session
                HttpContext.Session.SetString("UserUid", uid);
                HttpContext.Session.SetString("UserEmail", email);
                HttpContext.Session.SetString("UserName", employee.Name);
                HttpContext.Session.SetString("UserRole", employee.Role);
                HttpContext.Session.SetString("EmployeeId", employee.Id);
                HttpContext.Session.SetString("FirebaseToken", token);

                _logger.LogInformation($"Admin user {email} logged in successfully");

                return RedirectToAction("Index", "Dashboard");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Login error: {ex.Message}");
                ModelState.AddModelError(string.Empty, "An error occurred during login. Please try again.");
                return View(model);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Logout()
        {
            var userEmail = HttpContext.Session.GetString("UserEmail");

            HttpContext.Session.Clear();

            _logger.LogInformation($"User {userEmail} logged out");

            return RedirectToAction("Login");
        }

        [HttpGet]
        public IActionResult AccessDenied()
        {
            return View();
        }
    }
}