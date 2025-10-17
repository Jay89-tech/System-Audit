// Install: Install-Package ClosedXML
// Install: Install-Package QuestPDF
// Complete ReportService with ClosedXML for Excel and QuestPDF for PDF

using ClosedXML.Excel;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SkillsAuditSystem.Models;

namespace SkillsAuditSystem.Services
{
    public class ReportService : IReportService
    {
        private readonly ILogger<ReportService> _logger;

        public ReportService(ILogger<ReportService> logger)
        {
            _logger = logger;
            // Set QuestPDF license
            QuestPDF.Settings.License = LicenseType.Community;
        }

        #region Excel Methods (ClosedXML)

        public async Task<byte[]> GenerateEmployeesExcelReportAsync(List<Employee> employees)
        {
            try
            {
                using var workbook = new XLWorkbook();
                var worksheet = workbook.Worksheets.Add("Employees");

                // Headers
                worksheet.Cell(1, 1).Value = "Name";
                worksheet.Cell(1, 2).Value = "Email";
                worksheet.Cell(1, 3).Value = "Cell Number";
                worksheet.Cell(1, 4).Value = "Profession";
                worksheet.Cell(1, 5).Value = "Status";
                worksheet.Cell(1, 6).Value = "Created At";

                // Style headers
                var headerRange = worksheet.Range(1, 1, 1, 6);
                headerRange.Style.Font.Bold = true;
                headerRange.Style.Fill.BackgroundColor = XLColor.FromArgb(30, 58, 138);
                headerRange.Style.Font.FontColor = XLColor.White;
                headerRange.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;

                // Data
                int row = 2;
                foreach (var employee in employees)
                {
                    worksheet.Cell(row, 1).Value = employee.Name;
                    worksheet.Cell(row, 2).Value = employee.Email;
                    worksheet.Cell(row, 3).Value = employee.CellNumber;
                    worksheet.Cell(row, 4).Value = employee.Profession;
                    worksheet.Cell(row, 5).Value = employee.IsActive ? "Active" : "Inactive";
                    worksheet.Cell(row, 6).Value = employee.CreatedAt.ToString("yyyy-MM-dd");
                    row++;
                }

                // Auto-fit columns
                worksheet.Columns().AdjustToContents();

                using var stream = new MemoryStream();
                workbook.SaveAs(stream);
                return await Task.FromResult(stream.ToArray());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error generating Excel report: {ex.Message}");
                throw;
            }
        }

        public async Task<byte[]> GenerateSkillsAuditSummaryAsync(
            Dictionary<string, int> skillsDistribution,
            Dictionary<string, int> professionDistribution)
        {
            try
            {
                using var workbook = new XLWorkbook();

                // Skills Distribution Sheet
                var skillsSheet = workbook.Worksheets.Add("Skills Distribution");
                skillsSheet.Cell(1, 1).Value = "Skill Category";
                skillsSheet.Cell(1, 2).Value = "Count";

                var skillsHeader = skillsSheet.Range(1, 1, 1, 2);
                skillsHeader.Style.Font.Bold = true;
                skillsHeader.Style.Fill.BackgroundColor = XLColor.FromArgb(30, 58, 138);
                skillsHeader.Style.Font.FontColor = XLColor.White;

                int row = 2;
                foreach (var skill in skillsDistribution.OrderByDescending(x => x.Value))
                {
                    skillsSheet.Cell(row, 1).Value = skill.Key;
                    skillsSheet.Cell(row, 2).Value = skill.Value;
                    row++;
                }
                skillsSheet.Columns().AdjustToContents();

                // Profession Distribution Sheet
                var professionSheet = workbook.Worksheets.Add("Profession Distribution");
                professionSheet.Cell(1, 1).Value = "Profession";
                professionSheet.Cell(1, 2).Value = "Count";

                var professionHeader = professionSheet.Range(1, 1, 1, 2);
                professionHeader.Style.Font.Bold = true;
                professionHeader.Style.Fill.BackgroundColor = XLColor.FromArgb(30, 58, 138);
                professionHeader.Style.Font.FontColor = XLColor.White;

                row = 2;
                foreach (var profession in professionDistribution.OrderByDescending(x => x.Value))
                {
                    professionSheet.Cell(row, 1).Value = profession.Key;
                    professionSheet.Cell(row, 2).Value = profession.Value;
                    row++;
                }
                professionSheet.Columns().AdjustToContents();

                using var stream = new MemoryStream();
                workbook.SaveAs(stream);
                return await Task.FromResult(stream.ToArray());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error generating skills audit summary: {ex.Message}");
                throw;
            }
        }

        public async Task<byte[]> GenerateTrainingProgressReportAsync(List<Training> trainings)
        {
            try
            {
                using var workbook = new XLWorkbook();
                var worksheet = workbook.Worksheets.Add("Training Progress");

                // Headers
                worksheet.Cell(1, 1).Value = "Training Name";
                worksheet.Cell(1, 2).Value = "Employee ID";
                worksheet.Cell(1, 3).Value = "Status";
                worksheet.Cell(1, 4).Value = "Progress (%)";
                worksheet.Cell(1, 5).Value = "Start Date";
                worksheet.Cell(1, 6).Value = "End Date";

                var headerRange = worksheet.Range(1, 1, 1, 6);
                headerRange.Style.Font.Bold = true;
                headerRange.Style.Fill.BackgroundColor = XLColor.FromArgb(30, 58, 138);
                headerRange.Style.Font.FontColor = XLColor.White;

                int row = 2;
                foreach (var training in trainings)
                {
                    worksheet.Cell(row, 1).Value = training.TrainingName;
                    worksheet.Cell(row, 2).Value = training.EmployeeId;
                    worksheet.Cell(row, 3).Value = training.Status;
                    worksheet.Cell(row, 4).Value = training.Progress;
                    worksheet.Cell(row, 5).Value = training.StartDate?.ToString("yyyy-MM-dd") ?? "N/A";
                    worksheet.Cell(row, 6).Value = training.EndDate?.ToString("yyyy-MM-dd") ?? "N/A";

                    var statusCell = worksheet.Cell(row, 3);
                    switch (training.Status.ToLower())
                    {
                        case "completed":
                            statusCell.Style.Fill.BackgroundColor = XLColor.LightGreen;
                            break;
                        case "in_progress":
                            statusCell.Style.Fill.BackgroundColor = XLColor.LightBlue;
                            break;
                        case "suggested":
                            statusCell.Style.Fill.BackgroundColor = XLColor.LightYellow;
                            break;
                    }
                    row++;
                }

                worksheet.Columns().AdjustToContents();

                using var stream = new MemoryStream();
                workbook.SaveAs(stream);
                return await Task.FromResult(stream.ToArray());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error generating training progress report: {ex.Message}");
                throw;
            }
        }

        #endregion

        #region PDF Methods (QuestPDF)

        public async Task<byte[]> GenerateEmployeesPdfReportAsync(List<Employee> employees)
        {
            try
            {
                var document = Document.Create(container =>
                {
                    container.Page(page =>
                    {
                        page.Size(PageSizes.A4);
                        page.Margin(2, Unit.Centimetre);
                        page.PageColor(Colors.White);
                        page.DefaultTextStyle(x => x.FontSize(11));

                        page.Header()
                            .Text("Skills Audit System - Employees Report")
                            .SemiBold().FontSize(20).FontColor(Colors.Blue.Darken4);

                        page.Content()
                            .PaddingVertical(1, Unit.Centimetre)
                            .Column(column =>
                            {
                                column.Spacing(20);

                                column.Item().Text($"Generated: {DateTime.Now:yyyy-MM-dd HH:mm}")
                                    .FontSize(10).FontColor(Colors.Grey.Darken2);

                                column.Item().Text($"Total Employees: {employees.Count}")
                                    .FontSize(12).SemiBold();

                                column.Item().Table(table =>
                                {
                                    table.ColumnsDefinition(columns =>
                                    {
                                        columns.ConstantColumn(40);
                                        columns.RelativeColumn(3);
                                        columns.RelativeColumn(3);
                                        columns.RelativeColumn(2);
                                        columns.RelativeColumn(2);
                                    });

                                    table.Header(header =>
                                    {
                                        header.Cell().Element(HeaderCellStyle).Text("#");
                                        header.Cell().Element(HeaderCellStyle).Text("Name");
                                        header.Cell().Element(HeaderCellStyle).Text("Email");
                                        header.Cell().Element(HeaderCellStyle).Text("Profession");
                                        header.Cell().Element(HeaderCellStyle).Text("Status");
                                    });

                                    int index = 1;
                                    foreach (var employee in employees)
                                    {
                                        table.Cell().Element(BodyCellStyle).Text(index++.ToString());
                                        table.Cell().Element(BodyCellStyle).Text(employee.Name);
                                        table.Cell().Element(BodyCellStyle).Text(employee.Email);
                                        table.Cell().Element(BodyCellStyle).Text(employee.Profession);
                                        table.Cell().Element(BodyCellStyle).Text(employee.IsActive ? "Active" : "Inactive");
                                    }

                                    IContainer HeaderCellStyle(IContainer container)
                                    {
                                        return container.DefaultTextStyle(x => x.SemiBold())
                                            .PaddingVertical(5).BorderBottom(1).BorderColor(Colors.Grey.Lighten2);
                                    }

                                    IContainer BodyCellStyle(IContainer container)
                                    {
                                        return container.BorderBottom(1).BorderColor(Colors.Grey.Lighten3)
                                            .PaddingVertical(5);
                                    }
                                });
                            });

                        page.Footer()
                            .AlignCenter()
                            .Text(x =>
                            {
                                x.Span("Page ");
                                x.CurrentPageNumber();
                                x.Span(" of ");
                                x.TotalPages();
                            });
                    });
                });

                return await Task.FromResult(document.GeneratePdf());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error generating PDF report: {ex.Message}");
                throw;
            }
        }

        public async Task<byte[]> GenerateDetailedEmployeeReportAsync(
            Employee employee,
            List<Qualification> qualifications,
            List<Skill> skills,
            List<Training> trainings)
        {
            try
            {
                var document = Document.Create(container =>
                {
                    container.Page(page =>
                    {
                        page.Size(PageSizes.A4);
                        page.Margin(2, Unit.Centimetre);
                        page.PageColor(Colors.White);
                        page.DefaultTextStyle(x => x.FontSize(11));

                        page.Header()
                            .Column(column =>
                            {
                                column.Item().Text("Employee Detailed Report")
                                    .SemiBold().FontSize(20).FontColor(Colors.Blue.Darken4);
                                column.Item().Text($"Generated: {DateTime.Now:yyyy-MM-dd HH:mm}")
                                    .FontSize(10).FontColor(Colors.Grey.Darken2);
                            });

                        page.Content()
                            .PaddingVertical(1, Unit.Centimetre)
                            .Column(column =>
                            {
                                column.Spacing(15);

                                // Employee Info
                                column.Item().Text("Employee Information").FontSize(16).SemiBold();
                                column.Item().LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                                column.Item().Text($"Name: {employee.Name}");
                                column.Item().Text($"Email: {employee.Email}");
                                column.Item().Text($"Profession: {employee.Profession}");
                                column.Item().Text($"Cell: {employee.CellNumber}");

                                // Qualifications
                                column.Item().PaddingTop(20).Text("Qualifications").FontSize(16).SemiBold();
                                column.Item().LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                                if (qualifications.Any())
                                {
                                    foreach (var qual in qualifications)
                                    {
                                        column.Item().Text($"• {qual.QualificationName} - {qual.Institution} ({qual.Status})");
                                    }
                                }
                                else
                                {
                                    column.Item().Text("No qualifications recorded").FontColor(Colors.Grey.Darken1);
                                }

                                // Skills
                                column.Item().PaddingTop(20).Text("Skills").FontSize(16).SemiBold();
                                column.Item().LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                                if (skills.Any())
                                {
                                    foreach (var skill in skills)
                                    {
                                        column.Item().Text($"• {skill.SkillName} - {skill.ProficiencyLevel} ({skill.Category})");
                                    }
                                }
                                else
                                {
                                    column.Item().Text("No skills recorded").FontColor(Colors.Grey.Darken1);
                                }

                                // Trainings
                                column.Item().PaddingTop(20).Text("Trainings").FontSize(16).SemiBold();
                                column.Item().LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                                if (trainings.Any())
                                {
                                    foreach (var training in trainings)
                                    {
                                        column.Item().Text($"• {training.TrainingName} - {training.Status} ({training.Progress}%)");
                                    }
                                }
                                else
                                {
                                    column.Item().Text("No trainings recorded").FontColor(Colors.Grey.Darken1);
                                }
                            });

                        page.Footer()
                            .AlignCenter()
                            .Text(x =>
                            {
                                x.Span("Page ");
                                x.CurrentPageNumber();
                            });
                    });
                });

                return await Task.FromResult(document.GeneratePdf());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error generating detailed employee report: {ex.Message}");
                throw;
            }
        }

        #endregion
    }
}