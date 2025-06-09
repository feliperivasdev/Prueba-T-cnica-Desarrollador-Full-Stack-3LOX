namespace PsychometricApp.Domain.Entities;

public class BlockResult
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int BlockId { get; set; }
    public QuestionBlock Block { get; set; } = null!;
    public decimal TotalScore { get; set; }
    public decimal AverageScore { get; set; }
    public DateTime CompletedAt { get; set; }
}