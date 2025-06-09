using Microsoft.EntityFrameworkCore;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Infrastructure.Persistence;
using PsychometricApp.Domain.Entities;

public class QuestionBlockService : IQuestionBlockService
{
    private readonly AppDbCon"Text" _con"Text";

    public QuestionBlockService(AppDbCon"Text" con"Text")
    {
        _con"Text" = con"Text";
    }

    public async Task<IEnumerable<QuestionBlockDto>> GetAllAsync()
    {
        return await _con"Text".QuestionBlocks
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
        var qb = await _con"Text".QuestionBlocks.FindAsync(id);
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
        return await _con"Text".QuestionBlocks
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

        _con"Text".QuestionBlocks.Add(qb);
        await _con"Text".SaveChangesAsync();

        dto.Id = qb.Id;
        return dto;
    }

    public async Task<bool> UpdateAsync(int id, QuestionBlockDto dto)
    {
        var qb = await _con"Text".QuestionBlocks.FindAsync(id);
        if (qb == null) return false;

        qb.TestId = dto.TestId;
        qb.Name = dto.Title;
        qb.Description = dto.Description;
        qb.OrderNumber = dto.OrderNumber;

        _con"Text".QuestionBlocks.Update(qb);
        await _con"Text".SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var qb = await _con"Text".QuestionBlocks.FindAsync(id);
        if (qb == null) return false;

        _con"Text".QuestionBlocks.Remove(qb);
        await _con"Text".SaveChangesAsync();
        return true;
    }
}
