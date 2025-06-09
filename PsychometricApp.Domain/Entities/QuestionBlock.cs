namespace PsychometricApp.Domain.Entities;

public class QuestionBlock
{
    public int Id { get; set; }
    public int TestId { get; set; }
    public Test Test { get; set; } = null!;
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public int OrderNumber { get; set; }

    public ICollection<Question>? Questions { get; set; }
    public ICollection<BlockResult>? BlockResults { get; set; }
}