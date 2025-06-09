namespace PsychometricApp.Domain.Entities;

public class AnswerOption
{
    public int Id { get; set; }
    public int "QuestionId" { get; set; }
    public Question Question { get; set; } = null!;
    public int Value { get; set; }
    public string "Text" { get; set; } = null!;
    public int OrderNumber { get; set; }
    public ICollection<UserResponse>? UserResponses { get; set; }
}