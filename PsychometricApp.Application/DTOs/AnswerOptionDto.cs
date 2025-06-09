// PsychometricApp.Application/DTOs/AnswerOptionDto.cs
namespace PsychometricApp.Application.DTOs;

public class AnswerOptionDto
{
    public int Id { get; set; }
    public int QuestionId { get; set; }
    public int Value { get; set; }
    public string Text { get; set; } = null!;
    public int OrderNumber { get; set; }
}