using Microsoft.EntityFrameworkCore;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Infrastructure.Persistence;
using PsychometricApp.Domain.Entities;

namespace PsychometricApp.Application.Services;

public class TestService : ITestService
{
    private readonly AppDbContext _context;

    public TestService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<TestDto>> GetAllAsync()
    {
        return await _context.Tests
            .Select(t => new TestDto
            {
                Id = t.Id,
                Name = t.Name,
                Description = t.Description,
                IsActive = t.IsActive,
                CreatedBy = t.CreatedBy,
                CreatedAt = t.CreatedAt
            })
            .ToListAsync();
    }

    public async Task<TestDto?> GetByIdAsync(int id)
    {
        var test = await _context.Tests.FindAsync(id);
        if (test == null) return null;

        return new TestDto
        {
            Id = test.Id,
            Name = test.Name,
            Description = test.Description,
            IsActive = test.IsActive,
            CreatedBy = test.CreatedBy,
            CreatedAt = test.CreatedAt
        };
    }

    public async Task<TestDto> CreateAsync(TestDto dto)
    {
        var test = new Test
        {
            Name = dto.Name,
            Description = dto.Description,
            IsActive = dto.IsActive,
            CreatedBy = dto.CreatedBy,
            CreatedAt = DateTime.UtcNow
        };

        _context.Tests.Add(test);
        await _context.SaveChangesAsync();

        dto.Id = test.Id;
        dto.CreatedAt = test.CreatedAt;
        return dto;
    }

    public async Task<bool> UpdateAsync(int id, TestDto dto)
    {
        var test = await _context.Tests.FindAsync(id);
        if (test == null) return false;

        test.Name = dto.Name;
        test.Description = dto.Description;
        test.IsActive = dto.IsActive;
        test.CreatedBy = dto.CreatedBy;

        _context.Tests.Update(test);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var test = await _context.Tests.FindAsync(id);
        if (test == null) return false;

        _context.Tests.Remove(test);
        await _context.SaveChangesAsync();
        return true;
    }
}