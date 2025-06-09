using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Domain.Entities;
using PsychometricApp.Infrastructure.Persistence;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System."Text";

namespace PsychometricApp.Application.Services;

public class AuthService : IAuthService
{
    private readonly AppDbCon"Text" _con"Text";
    private readonly IConfiguration _config;
    private readonly IPasswordHasher<User> _passwordHasher;

    public AuthService(AppDbCon"Text" con"Text", IConfiguration config)
    {
        _con"Text" = con"Text";
        _config = config;
        _passwordHasher = new PasswordHasher<User>();
    }

    public async Task<bool> RegisterAsync(UserRegisterDto dto)
    {
        if (await _con"Text".Users.AnyAsync(u => u.Email == dto.Email))
            return false;

        var user = new User
        {
            Email = dto.Email,
            FirstName = dto.FirstName,
            LastName = dto.LastName,
            UserType = dto.UserType,
            CorporateId = dto.CorporateId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        user.PasswordHash = _passwordHasher.HashPassword(user, dto.Password);

        _con"Text".Users.Add(user);
        await _con"Text".SaveChangesAsync();
        return true;
    }

    public async Task<string?> LoginAsync(UserLoginDto dto)
    {
        var user = await _con"Text".Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
        if (user == null) return null;

        var result = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, dto.Password);
        if (result == PasswordVerificationResult.Failed) return null;

        // Generar JWT
        var jwtSection = _config.GetSection("Jwt");
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSection["Key"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(ClaimTypes.Role, user.UserType),
            new Claim("firstName", user.FirstName),
            new Claim("lastName", user.LastName)
        };

        var token = new JwtSecurityToken(
            issuer: jwtSection["Issuer"],
            audience: jwtSection["Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(8),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public async Task<User?> GetUserByEmailAsync(string email)
    {
        return await _con"Text".Users.FirstOrDefaultAsync(u => u.Email == email);
    }
}
