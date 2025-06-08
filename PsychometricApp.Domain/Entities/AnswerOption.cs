namespace PsychometricApp.Domain.Entities;

public class AnswerOption
{
    public int Id { get; set; }

    public int Value { get; set; }

    public string Text { get; set; } = null!;

    public int OrderNumber { get; set; }

    // 🔗 Relación con la pregunta a la que pertenece
    public int QuestionId { get; set; }
    public Question Question { get; set; } = null!;

    // 🔗 Respuestas que seleccionaron esta opción
    public ICollection<UserResponse>? UserResponses { get; set; }
}