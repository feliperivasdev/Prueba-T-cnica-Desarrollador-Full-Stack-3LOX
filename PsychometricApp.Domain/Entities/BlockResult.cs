namespace PsychometricApp.Domain.Entities;

public class BlockResult
{
    public int Id { get; set; }

    public decimal TotalScore { get; set; }

    public decimal AverageScore { get; set; }

    public DateTime CompletedAt { get; set; } = DateTime.UtcNow;

    // 🔗 Usuario al que pertenece el resultado
    public int UserId { get; set; }
    public User User { get; set; } = null!;

    // 🔗 Bloque al que pertenece este resultado
    public int BlockId { get; set; }
    public QuestionBlock Block { get; set; } = null!;
}