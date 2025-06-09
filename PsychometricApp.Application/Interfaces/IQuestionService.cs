using PsychometricApp.Application.DTOs;

namespace PsychometricApp.Application.Interfaces;

public interface IQuestionService
{
    Task<IEnumerable<QuestionDto>> GetAllAsync();
    Task<QuestionDto?> GetByIdAsync(int id);
    Task<IEnumerable<QuestionDto>> GetByBlockIdAsync(int questionBlockId);
    Task<QuestionDto> CreateAsync(QuestionDto dto);
    Task<bool> UpdateAsync(int id, QuestionDto dto);
    Task<bool> DeleteAsync(int id);
}