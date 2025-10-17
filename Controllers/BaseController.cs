using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace SkillsAuditSystem.Controllers
{
    public class BaseController : Controller
    {
        protected string? CurrentUserUid => HttpContext.Session.GetString("UserUid");
        protected string? CurrentUserEmail => HttpContext.Session.GetString("UserEmail");
        protected string? CurrentUserName => HttpContext.Session.GetString("UserName");
        protected string? CurrentUserRole => HttpContext.Session.GetString("UserRole");
        protected string? CurrentEmployeeId => HttpContext.Session.GetString("EmployeeId");

        protected bool IsAuthenticated => !string.IsNullOrEmpty(CurrentUserUid);
        protected bool IsAdmin => CurrentUserRole == "admin";

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);

            // Check if user is authenticated (except for Auth controller)
            if (context.Controller.GetType().Name != "AuthController")
            {
                if (!IsAuthenticated)
                {
                    context.Result = new RedirectToActionResult("Login", "Auth", null);
                    return;
                }
            }

            // Pass user info to ViewBag for layout
            ViewBag.CurrentUserName = CurrentUserName;
            ViewBag.CurrentUserEmail = CurrentUserEmail;
            ViewBag.IsAdmin = IsAdmin;
        }

        protected void SetSuccessMessage(string message)
        {
            TempData["SuccessMessage"] = message;
        }

        protected void SetErrorMessage(string message)
        {
            TempData["ErrorMessage"] = message;
        }

        protected void SetInfoMessage(string message)
        {
            TempData["InfoMessage"] = message;
        }

        protected void SetWarningMessage(string message)
        {
            TempData["WarningMessage"] = message;
        }
    }
}