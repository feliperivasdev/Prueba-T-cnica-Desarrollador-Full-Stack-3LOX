using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Infrastructure.Persistence;
using PsychometricApp.Domain.Entities;

namespace PsychometricApp.Application.Services;

public class UserResponseService : IUserResponseService
{
    private readonly AppDbContext _context;

    public UserResponseService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<UserResponseDto>> GetAllAsync()
    {
        return await _context.UserResponses
            .Select(r => new UserResponseDto
            {
                Id = r.Id,
                UserId = r.UserId,
                QuestionId = r.QuestionId,
                AnswerOptionId = r.AnswerOptionId,
                ResponseValue = r.ResponseValue,
                RespondedAt = r.RespondedAt
            })
            .ToListAsync();
    }

    public async Task<UserResponseDto?> GetByIdAsync(int id)
    {
        var r = await _context.UserResponses.FindAsync(id);
        if (r == null) return null;

        return new UserResponseDto
        {
            Id = r.Id,
            UserId = r.UserId,
            QuestionId = r.QuestionId,
            AnswerOptionId = r.AnswerOptionId,
            ResponseValue = r.ResponseValue,
            RespondedAt = r.RespondedAt
        };
    }

    public async Task<UserResponseDto?> GetByUserAndQuestionAsync(int userId, int questionId)
    {
        var r = await _context.UserResponses
            .FirstOrDefaultAsync(x => x.UserId == userId && x.QuestionId == questionId);
        if (r == null) return null;

        return new UserResponseDto
        {
            Id = r.Id,
            UserId = r.UserId,
            QuestionId = r.QuestionId,
            AnswerOptionId = r.AnswerOptionId,
            ResponseValue = r.ResponseValue,
            RespondedAt = r.RespondedAt
        };
    }

    public async Task<UserResponseDto> CreateAsync(UserResponseDto dto)
    {
        var r = new UserResponse
        {
            UserId = dto.UserId,
            QuestionId = dto.QuestionId,
            AnswerOptionId = dto.AnswerOptionId,
            ResponseValue = dto.ResponseValue,
            RespondedAt = DateTime.UtcNow
        };

        _context.UserResponses.Add(r);
        await _context.SaveChangesAsync();

        dto.Id = r.Id;
        dto.RespondedAt = r.RespondedAt;
        return dto;
    }

    public async Task<bool> UpdateAsync(int id, UserResponseDto dto)
    {
        var r = await _context.UserResponses.FindAsync(id);
        if (r == null) return false;

        r.UserId = dto.UserId;
        r.QuestionId = dto.QuestionId;
        r.AnswerOptionId = dto.AnswerOptionId;
        r.ResponseValue = dto.ResponseValue;
        // RespondedAt usually not updated, but you can update if needed

        _context.UserResponses.Update(r);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var r = await _context.UserResponses.FindAsync(id);
        if (r == null) return false;

        _context.UserResponses.Remove(r);
        await _context.SaveChangesAsync();
        return true;
    }
}
