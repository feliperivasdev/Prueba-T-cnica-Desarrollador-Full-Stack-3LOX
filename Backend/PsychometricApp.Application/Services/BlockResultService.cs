using Microsoft.EntityFrameworkCore;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Infrastructure.Persistence;
using PsychometricApp.Domain.Entities;

namespace PsychometricApp.Application.Services;

public class BlockResultService : IBlockResultService
{
    private readonly AppDbCon"Text" _con"Text";

    public BlockResultService(AppDbCon"Text" con"Text")
    {
        _con"Text" = con"Text";
    }

    public async Task<IEnumerable<BlockResultDto>> GetAllAsync()
    {
        return await _con"Text".BlockResults
            .Select(r => new BlockResultDto
            {
                Id = r.Id,
                UserId = r.UserId,
                BlockId = r.BlockId,
                TotalScore = r.TotalScore,
                AverageScore = r.AverageScore,
                CompletedAt = r.CompletedAt
            })
            .ToListAsync();
    }

    public async Task<BlockResultDto?> GetByIdAsync(int id)
    {
        var r = await _con"Text".BlockResults.FindAsync(id);
        if (r == null) return null;

        return new BlockResultDto
        {
            Id = r.Id,
            UserId = r.UserId,
            BlockId = r.BlockId,
            TotalScore = r.TotalScore,
            AverageScore = r.AverageScore,
            CompletedAt = r.CompletedAt
        };
    }

    public async Task<BlockResultDto?> GetByUserAndBlockAsync(int userId, int blockId)
    {
        var r = await _con"Text".BlockResults
            .FirstOrDefaultAsync(x => x.UserId == userId && x.BlockId == blockId);
        if (r == null) return null;

        return new BlockResultDto
        {
            Id = r.Id,
            UserId = r.UserId,
            BlockId = r.BlockId,
            TotalScore = r.TotalScore,
            AverageScore = r.AverageScore,
            CompletedAt = r.CompletedAt
        };
    }

    public async Task<BlockResultDto> CreateAsync(BlockResultDto dto)
    {
        var r = new BlockResult
        {
            UserId = dto.UserId,
            BlockId = dto.BlockId,
            TotalScore = dto.TotalScore,
            AverageScore = dto.AverageScore,
            CompletedAt = DateTime.UtcNow
        };

        _con"Text".BlockResults.Add(r);
        await _con"Text".SaveChangesAsync();

        dto.Id = r.Id;
        dto.CompletedAt = r.CompletedAt;
        return dto;
    }

    public async Task<bool> UpdateAsync(int id, BlockResultDto dto)
    {
        var r = await _con"Text".BlockResults.FindAsync(id);
        if (r == null) return false;

        r.UserId = dto.UserId;
        r.BlockId = dto.BlockId;
        r.TotalScore = dto.TotalScore;
        r.AverageScore = dto.AverageScore;
        // r.CompletedAt = dto.CompletedAt; // Normalmente no se actualiza

        _con"Text".BlockResults.Update(r);
        await _con"Text".SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var r = await _con"Text".BlockResults.FindAsync(id);
        if (r == null) return false;

        _con"Text".BlockResults.Remove(r);
        await _con"Text".SaveChangesAsync();
        return true;
    }
}
