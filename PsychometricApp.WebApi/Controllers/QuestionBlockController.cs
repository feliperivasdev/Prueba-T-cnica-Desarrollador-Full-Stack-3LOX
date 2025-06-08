using Microsoft.AspNetCore.Mvc;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;

[ApiController]
[Route("api/[controller]")]
public class QuestionBlockController : ControllerBase
{
    private readonly IQuestionBlockService _service;

    public QuestionBlockController(IQuestionBlockService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var blocks = await _service.GetAllAsync();
        return Ok(blocks);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var block = await _service.GetByIdAsync(id);
        if (block == null) return NotFound();
        return Ok(block);
    }

    [HttpGet("ByTest/{testId}")]
    public async Task<IActionResult> GetByTestId(int testId)
    {
        var blocks = await _service.GetByTestIdAsync(testId);
        return Ok(blocks);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] QuestionBlockDto dto)
    {
        var createdBlock = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = createdBlock.Id }, createdBlock);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] QuestionBlockDto dto)
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