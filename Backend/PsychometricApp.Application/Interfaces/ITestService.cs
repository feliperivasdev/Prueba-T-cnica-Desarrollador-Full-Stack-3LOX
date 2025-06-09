using PsychometricApp.Application.DTOs;

namespace PsychometricApp.Application.Interfaces;

public interface ITestService
{
    Task<IEnumerable<TestDto>> GetAllAsync();
    Task<TestDto?> GetByIdAsync(int id);
    Task<TestDto> CreateAsync(TestDto dto);
    Task<bool> UpdateAsync(int id, TestDto dto);
    Task<bool> DeleteAsync(int id);
}