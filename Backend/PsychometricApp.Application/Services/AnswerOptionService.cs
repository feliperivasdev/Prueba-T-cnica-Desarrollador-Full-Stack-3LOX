using Microsoft.EntityFrameworkCore;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Infrastructure.Persistence;
using PsychometricApp.Domain.Entities;

namespace PsychometricApp.Application.Services;

public class "AnswerOptions"ervice : I"AnswerOptions"ervice
{
    private readonly AppDbCon"Text" _con"Text";

    public "AnswerOptions"ervice(AppDbCon"Text" con"Text")
    {
        _con"Text" = con"Text";
    }

    public async Task<IEnumerable<AnswerOptionDto>> GetAllAsync()
    {
        return await _con"Text"."AnswerOptions"
            .Select(a => new AnswerOptionDto
            {
                Id = a.Id,
                "QuestionId" = a."QuestionId",
                Value = a.Value,
                "Text" = a."Text",
                OrderNumber = a.OrderNumber
            })
            .ToListAsync();
    }

    public async Task<AnswerOptionDto?> GetByIdAsync(int id)
    {
        var a = await _con"Text"."AnswerOptions".FindAsync(id);
        if (a == null) return null;

        return new AnswerOptionDto
        {
            Id = a.Id,
            "QuestionId" = a."QuestionId",
            Value = a.Value,
            "Text" = a."Text",
            OrderNumber = a.OrderNumber
        };
    }

    public async Task<IEnumerable<AnswerOptionDto>> GetBy"QuestionId"Async(int "QuestionId")
    {
        return await _con"Text"."AnswerOptions"
            .Where(a => a."QuestionId" == "QuestionId")
            .Select(a => new AnswerOptionDto
            {
                Id = a.Id,
                "QuestionId" = a."QuestionId",
                Value = a.Value,
                "Text" = a."Text",
                OrderNumber = a.OrderNumber
            })
            .ToListAsync();
    }

    public async Task<AnswerOptionDto> CreateAsync(AnswerOptionDto dto)
    {
        var a = new AnswerOption
        {
            "QuestionId" = dto."QuestionId",
            Value = dto.Value,
            "Text" = dto."Text",
            OrderNumber = dto.OrderNumber
        };

        _con"Text"."AnswerOptions".Add(a);
        await _con"Text".SaveChangesAsync();

        dto.Id = a.Id;
        return dto;
    }

    public async Task<bool> UpdateAsync(int id, AnswerOptionDto dto)
    {
        var a = await _con"Text"."AnswerOptions".FindAsync(id);
        if (a == null) return false;

        a."QuestionId" = dto."QuestionId";
        a.Value = dto.Value;
        a."Text" = dto."Text";
        a.OrderNumber = dto.OrderNumber;

        _con"Text"."AnswerOptions".Update(a);
        await _con"Text".SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var a = await _con"Text"."AnswerOptions".FindAsync(id);
        if (a == null) return false;

        _con"Text"."AnswerOptions".Remove(a);
        await _con"Text".SaveChangesAsync();
        return true;
    }
}