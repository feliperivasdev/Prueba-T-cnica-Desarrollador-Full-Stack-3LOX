namespace PsychometricApp.Domain.Entities;

public class Test
{
    public int Id { get; set; } // <-- ¡Clave primaria necesaria!
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
    public int CreatorId { get; set; }
    public User Creator { get; set; } = null!;
    public ICollection<QuestionBlock> Blocks { get; set; } = new List<QuestionBlock>();
}