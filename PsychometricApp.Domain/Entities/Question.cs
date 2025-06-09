namespace PsychometricApp.Domain.Entities;

public class Question
{
    public int Id { get; set; }
    public int BlockId { get; set; }
    public QuestionBlock Block { get; set; } = null!;
    public string Text { get; set; } = null!;
    public int OrderNumber { get; set; }

    // Relaciones opcionales
    public ICollection<AnswerOption>? AnswerOptions { get; set; }
    public ICollection<UserResponse>? UserResponses { get; set; }
}