using PsychometricApp.Application.DTOs;

namespace PsychometricApp.Application.Interfaces;

public interface IUserService
{
    Task<IEnumerable<UserDto>> GetAllAsync();
    Task<UserDto?> GetByIdAsync(int id);
    Task<UserDto> CreateAsync(UserDto userDto);
    Task<bool> UpdateAsync(int id, UserDto userDto);
    Task<bool> DeleteAsync(int id);
}