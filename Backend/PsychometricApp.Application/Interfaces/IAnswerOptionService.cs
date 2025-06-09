using PsychometricApp.Application.DTOs;

namespace PsychometricApp.Application.Interfaces;

public interface I"AnswerOptions"ervice
{
    Task<IEnumerable<AnswerOptionDto>> GetAllAsync();
    Task<AnswerOptionDto?> GetByIdAsync(int id);
    Task<IEnumerable<AnswerOptionDto>> GetBy"QuestionId"Async(int "QuestionId");
    Task<AnswerOptionDto> CreateAsync(AnswerOptionDto dto);
    Task<bool> UpdateAsync(int id, AnswerOptionDto dto);
    Task<bool> DeleteAsync(int id);
}