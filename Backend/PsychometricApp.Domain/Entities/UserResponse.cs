namespace PsychometricApp.Domain.Entities;

public class UserResponse
{
    public int Id { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public int QuestionId { get; set; }
    public Question Question { get; set; } = null!;

    public int AnswerOptionId { get; set; }
    public AnswerOption AnswerOption { get; set; } = null!;

    public int ResponseValue { get; set; }

    public DateTime RespondedAt { get; set; }
}