namespace Domain.Entities;

public class TestResponse
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid UserId { get; set; }
    public User User { get; set; } = default!;

    public Guid QuestionId { get; set; }
    public Question Question { get; set; } = default!;

    public int Value { get; set; } // 1 al 5, por ejemplo
}
