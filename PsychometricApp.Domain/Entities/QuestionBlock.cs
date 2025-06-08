namespace PsychometricApp.Domain.Entities;

public class QuestionBlock
{
    public int Id { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public int OrderNumber { get; set; }

    // 🔗 Relación con el test al que pertenece
    public int TestId { get; set; }
    public Test Test { get; set; } = null!;

    // 🔗 Preguntas del bloque
    public ICollection<Question>? Questions { get; set; }

    // 🔗 Resultados por bloque (por usuario)
    public ICollection<BlockResult>? BlockResults { get; set; }
}