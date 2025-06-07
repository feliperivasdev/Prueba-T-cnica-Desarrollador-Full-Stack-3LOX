namespace Domain.Entities;

public class Test
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Title { get; set; } = default!;
    public ICollection<Block> Blocks { get; set; } = new List<Block>();
}
