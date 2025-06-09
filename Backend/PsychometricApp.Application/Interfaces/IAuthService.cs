using PsychometricApp.Domain.Entities; 
using PsychometricApp.Application.DTOs;

namespace PsychometricApp.Application.Interfaces;

public interface IAuthService
{
    Task<bool> RegisterAsync(UserRegisterDto dto);
    Task<string?> LoginAsync(UserLoginDto dto);
    Task<User?> GetUserByEmailAsync(string email); 
}
