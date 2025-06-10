using Microsoft.EntityFrameworkCore;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Infrastructure.Persistence;
using PsychometricApp.Domain.Entities;

public class QuestionBlockService : IQuestionBlockService
{
    private readonly AppDbContext _context;

    public QuestionBlockService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<QuestionBlockDto>> GetAllAsync()
    {
        return await _context.QuestionBlocks
            .Select(qb => new QuestionBlockDto
            {
                Id = qb.Id,
                TestId = qb.TestId,
                Title = qb.Name,
                Description = qb.Description,
                OrderNumber = qb.OrderNumber
            })
            .ToListAsync();
    }

    public async Task<QuestionBlockDto?> GetByIdAsync(int id)
    {
        var qb = await _context.QuestionBlocks.FindAsync(id);
        if (qb == null) return null;

        return new QuestionBlockDto
        {
            Id = qb.Id,
            TestId = qb.TestId,
            Title = qb.Name,
            Description = qb.Description,
            OrderNumber = qb.OrderNumber
        };
    }

    public async Task<IEnumerable<QuestionBlockDto>> GetByTestIdAsync(int testId)
    {
        return await _context.QuestionBlocks
            .Where(qb => qb.TestId == testId)
            .Select(qb => new QuestionBlockDto
            {
                Id = qb.Id,
                TestId = qb.TestId,
                Title = qb.Name,
                Description = qb.Description,
                OrderNumber = qb.OrderNumber
            })
            .ToListAsync();
    }

    public async Task<QuestionBlockDto> CreateAsync(QuestionBlockDto dto)
    {
        var qb = new QuestionBlock
        {
            TestId = dto.TestId,
            Name = dto.Title,
            Description = dto.Description,
            OrderNumber = dto.OrderNumber
        };

        _context.QuestionBlocks.Add(qb);
        await _context.SaveChangesAsync();

        dto.Id = qb.Id;
        return dto;
    }

    public async Task<bool> UpdateAsync(int id, QuestionBlockDto dto)
    {
        var qb = await _context.QuestionBlocks.FindAsync(id);
        if (qb == null) return false;

        qb.TestId = dto.TestId;
        qb.Name = dto.Title;
        qb.Description = dto.Description;
        qb.OrderNumber = dto.OrderNumber;

        _context.QuestionBlocks.Update(qb);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var qb = await _context.QuestionBlocks.FindAsync(id);
        if (qb == null) return false;

        _context.QuestionBlocks.Remove(qb);
        await _context.SaveChangesAsync();
        return true;
    }
}
