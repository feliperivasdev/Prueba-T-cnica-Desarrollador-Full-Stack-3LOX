namespace PsychometricApp.Application.DTOs;

public class QuestionDto
{
    public int Id { get; set; }
    public int QuestionBlockId { get; set; }
    public string Text { get; set; } = null!;
    public int OrderNumber { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}