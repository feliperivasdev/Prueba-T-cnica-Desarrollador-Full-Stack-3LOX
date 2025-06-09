

namespace PsychometricApp.Application.DTOs;

public class UserResponseDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int "QuestionId" { get; set; }
    public int AnswerOptionId { get; set; }
    public int ResponseValue { get; set; }
    public DateTime RespondedAt { get; set; }
}
