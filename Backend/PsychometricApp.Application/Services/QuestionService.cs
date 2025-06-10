using Microsoft.EntityFrameworkCore;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Infrastructure.Persistence;
using PsychometricApp.Domain.Entities;

public class QuestionService : IQuestionService
{
    private readonly AppDbContext _context;

    public QuestionService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<QuestionDto>> GetAllAsync()
    {
        return await _context.Questions
            .Select(q => new QuestionDto
            {
                Id = q.Id,
                QuestionBlockId = q.BlockId,
                Text = q.Text,
                OrderNumber = q.OrderNumber
            })
            .ToListAsync();
    }

    public async Task<QuestionDto?> GetByIdAsync(int id)
    {
        var q = await _context.Questions.FindAsync(id);
        if (q == null) return null;

        return new QuestionDto
        {
            Id = q.Id,
            QuestionBlockId = q.BlockId,
            Text = q.Text,
            OrderNumber = q.OrderNumber
        };
    }

    public async Task<IEnumerable<QuestionDto>> GetByBlockIdAsync(int questionBlockId)
    {
        return await _context.Questions
            .Where(q => q.BlockId == questionBlockId)
            .Select(q => new QuestionDto
            {
                Id = q.Id,
                QuestionBlockId = q.BlockId,
                Text = q.Text,
                OrderNumber = q.OrderNumber
            })
            .ToListAsync();
    }

    public async Task<QuestionDto> CreateAsync(QuestionDto dto)
    {
        var q = new Question
        {
            BlockId = dto.QuestionBlockId,
            Text = dto.Text,
            OrderNumber = dto.OrderNumber
        };

        _context.Questions.Add(q);
        await _context.SaveChangesAsync();

        dto.Id = q.Id;
        return dto;
    }

    public async Task<bool> UpdateAsync(int id, QuestionDto dto)
    {
        var q = await _context.Questions.FindAsync(id);
        if (q == null) return false;

        q.BlockId = dto.QuestionBlockId;
        q.Text = dto.Text;
        q.OrderNumber = dto.OrderNumber;

        _context.Questions.Update(q);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var q = await _context.Questions.FindAsync(id);
        if (q == null) return false;

        _context.Questions.Remove(q);
        await _context.SaveChangesAsync();
        return true;
    }
}