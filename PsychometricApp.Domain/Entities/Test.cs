namespace PsychometricApp.Domain.Entities;

public class Test
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;
    public int CreatedBy { get; set; }
    public User Creator { get; set; } = null!;
    public DateTime CreatedAt { get; set; }

    public ICollection<QuestionBlock> Blocks { get; set; } = new List<QuestionBlock>();
}