namespace PsychometricApp.Domain.Entities;

public class Question
{
    public int Id { get; set; }

    public string Text { get; set; } = null!;

    public int OrderNumber { get; set; }

    // 🔗 Relación con el bloque al que pertenece
    public int BlockId { get; set; }
    public QuestionBlock Block { get; set; } = null!;

    // 🔗 Opciones de respuesta posibles (escala Likert, etc.)
    public ICollection<AnswerOption>? AnswerOptions { get; set; }

    // 🔗 Respuestas de los usuarios
    public ICollection<UserResponse>? UserResponses { get; set; }
}