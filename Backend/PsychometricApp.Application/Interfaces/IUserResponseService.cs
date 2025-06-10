using System;
using PsychometricApp.Application.DTOs;

namespace PsychometricApp.Application.Interfaces;

public interface IUserResponseService
{
    Task<IEnumerable<UserResponseDto>> GetAllAsync();
    Task<UserResponseDto?> GetByIdAsync(int id);
    Task<UserResponseDto?> GetByUserAndQuestionAsync(int userId, int QuestionId);
    Task<UserResponseDto> CreateAsync(UserResponseDto dto);
    Task<bool> UpdateAsync(int id, UserResponseDto dto);
    Task<bool> DeleteAsync(int id);
}
