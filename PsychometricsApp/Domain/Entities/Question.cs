namespace Domain.Entities;

public class Question
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Text { get; set; } = default!;
    
    public Guid BlockId { get; set; }
    public Block Block { get; set; } = default!;
}
