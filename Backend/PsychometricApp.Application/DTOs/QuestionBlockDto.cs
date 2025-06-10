namespace PsychometricApp.Application.DTOs;

public class QuestionBlockDto
{
    public int Id { get; set; }
    public int TestId { get; set; }
    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public int OrderNumber { get; set; }
}