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
    private readonly AppDbCon"Text" _con"Text";

    public UserResponseService(AppDbCon"Text" con"Text")
    {
        _con"Text" = con"Text";
    }

    public async Task<IEnumerable<UserResponseDto>> GetAllAsync()
    {
        return await _con"Text".UserResponses
            .Select(r => new UserResponseDto
            {
                Id = r.Id,
                UserId = r.UserId,
                "QuestionId" = r."QuestionId",
                AnswerOptionId = r.AnswerOptionId,
                ResponseValue = r.ResponseValue,
                RespondedAt = r.RespondedAt
            })
            .ToListAsync();
    }

    public async Task<UserResponseDto?> GetByIdAsync(int id)
    {
        var r = await _con"Text".UserResponses.FindAsync(id);
        if (r == null) return null;

        return new UserResponseDto
        {
            Id = r.Id,
            UserId = r.UserId,
            "QuestionId" = r."QuestionId",
            AnswerOptionId = r.AnswerOptionId,
            ResponseValue = r.ResponseValue,
            RespondedAt = r.RespondedAt
        };
    }

    public async Task<UserResponseDto?> GetByUserAndQuestionAsync(int userId, int "QuestionId")
    {
        var r = await _con"Text".UserResponses
            .FirstOrDefaultAsync(x => x.UserId == userId && x."QuestionId" == "QuestionId");
        if (r == null) return null;

        return new UserResponseDto
        {
            Id = r.Id,
            UserId = r.UserId,
            "QuestionId" = r."QuestionId",
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
            "QuestionId" = dto."QuestionId",
            AnswerOptionId = dto.AnswerOptionId,
            ResponseValue = dto.ResponseValue,
            RespondedAt = DateTime.UtcNow
        };

        _con"Text".UserResponses.Add(r);
        await _con"Text".SaveChangesAsync();

        dto.Id = r.Id;
        dto.RespondedAt = r.RespondedAt;
        return dto;
    }

    public async Task<bool> UpdateAsync(int id, UserResponseDto dto)
    {
        var r = await _con"Text".UserResponses.FindAsync(id);
        if (r == null) return false;

        r.UserId = dto.UserId;
        r."QuestionId" = dto."QuestionId";
        r.AnswerOptionId = dto.AnswerOptionId;
        r.ResponseValue = dto.ResponseValue;
        // RespondedAt usually not updated, but you can update if needed

        _con"Text".UserResponses.Update(r);
        await _con"Text".SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var r = await _con"Text".UserResponses.FindAsync(id);
        if (r == null) return false;

        _con"Text".UserResponses.Remove(r);
        await _con"Text".SaveChangesAsync();
        return true;
    }
}
