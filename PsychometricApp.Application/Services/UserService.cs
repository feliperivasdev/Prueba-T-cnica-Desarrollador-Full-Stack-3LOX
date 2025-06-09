using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Infrastructure.Persistence;
using PsychometricApp.Domain.Entities;

namespace PsychometricApp.Application.Services;

public class UserService : IUserService
{
    private readonly AppDbContext _context;
    private readonly IPasswordHasher<User> _passwordHasher;

    public UserService(AppDbContext context, IPasswordHasher<User> passwordHasher)
    {
        _context = context;
        _passwordHasher = passwordHasher;
    }

    public async Task<IEnumerable<UserDto>> GetAllAsync()
    {
        return await _context.Users
            .Select(u => new UserDto
            {
                Id = u.Id,
                Email = u.Email,
                PasswordHash = u.PasswordHash,
                FirstName = u.FirstName,
                LastName = u.LastName,
                UserType = u.UserType,
                CreatedAt = u.CreatedAt,
                UpdatedAt = u.UpdatedAt,
                CorporateId = u.CorporateId
            })
            .ToListAsync();
    }

    public async Task<UserDto?> GetByIdAsync(int id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) return null;

        return new UserDto
        {
            Id = user.Id,
            Email = user.Email,
            PasswordHash = user.PasswordHash,
            FirstName = user.FirstName,
            LastName = user.LastName,
            UserType = user.UserType,
            CreatedAt = user.CreatedAt,
            UpdatedAt = user.UpdatedAt,
            CorporateId = user.CorporateId
        };
    }

    public async Task<UserDto> CreateAsync(UserDto userDto)
    {
        var user = new User
        {
            Email = userDto.Email,
            FirstName = userDto.FirstName,
            LastName = userDto.LastName,
            UserType = userDto.UserType,
            CorporateId = userDto.CorporateId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        // Hashear la contraseña recibida en Password y guardar en PasswordHash
        if (!string.IsNullOrWhiteSpace(userDto.Password))
        {
            user.PasswordHash = _passwordHasher.HashPassword(user, userDto.Password);
        }
        else
        {
            throw new ArgumentException("La contraseña es obligatoria para crear un usuario.");
        }

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        userDto.Id = user.Id;
        userDto.CreatedAt = user.CreatedAt;
        userDto.UpdatedAt = user.UpdatedAt;
        userDto.PasswordHash = user.PasswordHash;
        userDto.Password = null; // Nunca devuelvas la contraseña

        return userDto;
    }

    public async Task<bool> UpdateAsync(int id, UserDto userDto)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) return false;

        user.FirstName = userDto.FirstName;
        user.LastName = userDto.LastName;
        user.UserType = userDto.UserType;
        user.UpdatedAt = DateTime.UtcNow;
        user.CorporateId = userDto.CorporateId;

        if (!string.IsNullOrWhiteSpace(userDto.Password))
        {
            user.PasswordHash = _passwordHasher.HashPassword(user, userDto.Password);
        }

        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) return false;

        _context.Users.Remove(user);
        await _context.SaveChangesAsync();
        return true;
    }
}
