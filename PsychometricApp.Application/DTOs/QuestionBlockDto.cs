namespace PsychometricApp.Application.DTOs;

public class QuestionBlockDto
{
    public int Id { get; set; }
    public int TestId { get; set; }
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public int OrderNumber { get; set; }
}