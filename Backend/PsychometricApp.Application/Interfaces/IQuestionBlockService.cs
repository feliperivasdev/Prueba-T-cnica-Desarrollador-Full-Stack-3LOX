using PsychometricApp.Application.DTOs;

namespace PsychometricApp.Application.Interfaces;

public interface IQuestionBlockService
{
    Task<IEnumerable<QuestionBlockDto>> GetAllAsync();
    Task<QuestionBlockDto?> GetByIdAsync(int id);
    Task<IEnumerable<QuestionBlockDto>> GetByTestIdAsync(int testId);
    Task<QuestionBlockDto> CreateAsync(QuestionBlockDto dto);
    Task<bool> UpdateAsync(int id, QuestionBlockDto dto);
    Task<bool> DeleteAsync(int id);
}