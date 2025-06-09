using PsychometricApp.Application.DTOs;

namespace PsychometricApp.Application.Interfaces;

public interface IBlockResultService
{
    Task<IEnumerable<BlockResultDto>> GetAllAsync();
    Task<BlockResultDto?> GetByIdAsync(int id);
    Task<BlockResultDto?> GetByUserAndBlockAsync(int userId, int blockId);
    Task<BlockResultDto> CreateAsync(BlockResultDto dto);
    Task<bool> UpdateAsync(int id, BlockResultDto dto);
    Task<bool> DeleteAsync(int id);
}
