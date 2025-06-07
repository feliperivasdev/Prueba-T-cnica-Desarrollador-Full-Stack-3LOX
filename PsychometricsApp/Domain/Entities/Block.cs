namespace Domain.Entities;

public class Block
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = default!; // Ej: "Liderazgo", "Innovación"
    
    public Guid TestId { get; set; }
    public Test Test { get; set; } = default!;

    public ICollection<Question> Questions { get; set; } = new List<Question>();
}
