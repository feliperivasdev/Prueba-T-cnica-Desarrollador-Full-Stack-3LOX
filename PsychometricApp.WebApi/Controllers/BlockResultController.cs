using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;

namespace PsychometricApp.WebApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BlockResultController : ControllerBase
{
    private readonly IBlockResultService _service;

    public BlockResultController(IBlockResultService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var results = await _service.GetAllAsync();
        return Ok(results);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await _service.GetByIdAsync(id);
        if (result == null) return NotFound();
        return Ok(result);
    }

    [HttpGet("ByUserAndBlock")]
    public async Task<IActionResult> GetByUserAndBlock([FromQuery] int userId, [FromQuery] int blockId)
    {
        var result = await _service.GetByUserAndBlockAsync(userId, blockId);
        if (result == null) return NotFound();
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] BlockResultDto dto)
    {
        var created = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] BlockResultDto dto)
    {
        if (id != dto.Id) return BadRequest();

        var updated = await _service.UpdateAsync(id, dto);
        if (!updated) return NotFound();

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await _service.DeleteAsync(id);
        if (!deleted) return NotFound();

        return NoContent();
    }
}
