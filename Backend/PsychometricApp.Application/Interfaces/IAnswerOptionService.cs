using PsychometricApp.Application.DTOs;

namespace PsychometricApp.Application.Interfaces;

public interface IAnswerOptionService
{
    Task<IEnumerable<AnswerOptionDto>> GetAllAsync();
    Task<AnswerOptionDto?> GetByIdAsync(int id);
    Task<IEnumerable<AnswerOptionDto>> GetByQuestionIdAsync(int questionId);
    Task<AnswerOptionDto> CreateAsync(AnswerOptionDto dto);
    Task<bool> UpdateAsync(int id, AnswerOptionDto dto);
    Task<bool> DeleteAsync(int id);
}