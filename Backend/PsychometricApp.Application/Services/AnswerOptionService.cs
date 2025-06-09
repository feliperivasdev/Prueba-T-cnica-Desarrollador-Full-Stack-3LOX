using Microsoft.EntityFrameworkCore;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Infrastructure.Persistence;
using PsychometricApp.Domain.Entities;

namespace PsychometricApp.Application.Services;

public class AnswerOptionService : IAnswerOptionService
{
    private readonly AppDbContext _context;

    public AnswerOptionService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<AnswerOptionDto>> GetAllAsync()
    {
        return await _context.AnswerOptions
            .Select(a => new AnswerOptionDto
            {
                Id = a.Id,
                QuestionId = a.QuestionId,
                Value = a.Value,
                Text = a.Text,
                OrderNumber = a.OrderNumber
            })
            .ToListAsync();
    }

    public async Task<AnswerOptionDto?> GetByIdAsync(int id)
    {
        var a = await _context.AnswerOptions.FindAsync(id);
        if (a == null) return null;

        return new AnswerOptionDto
        {
            Id = a.Id,
            QuestionId = a.QuestionId,
            Value = a.Value,
            Text = a.Text,
            OrderNumber = a.OrderNumber
        };
    }

    public async Task<IEnumerable<AnswerOptionDto>> GetByQuestionIdAsync(int questionId)
    {
        return await _context.AnswerOptions
            .Where(a => a.QuestionId == questionId)
            .Select(a => new AnswerOptionDto
            {
                Id = a.Id,
                QuestionId = a.QuestionId,
                Value = a.Value,
                Text = a.Text,
                OrderNumber = a.OrderNumber
            })
            .ToListAsync();
    }

    public async Task<AnswerOptionDto> CreateAsync(AnswerOptionDto dto)
    {
        var a = new AnswerOption
        {
            QuestionId = dto.QuestionId,
            Value = dto.Value,
            Text = dto.Text,
            OrderNumber = dto.OrderNumber
        };

        _context.AnswerOptions.Add(a);
        await _context.SaveChangesAsync();

        dto.Id = a.Id;
        return dto;
    }

    public async Task<bool> UpdateAsync(int id, AnswerOptionDto dto)
    {
        var a = await _context.AnswerOptions.FindAsync(id);
        if (a == null) return false;

        a.QuestionId = dto.QuestionId;
        a.Value = dto.Value;
        a.Text = dto.Text;
        a.OrderNumber = dto.OrderNumber;

        _context.AnswerOptions.Update(a);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var a = await _context.AnswerOptions.FindAsync(id);
        if (a == null) return false;

        _context.AnswerOptions.Remove(a);
        await _context.SaveChangesAsync();
        return true;
    }
}