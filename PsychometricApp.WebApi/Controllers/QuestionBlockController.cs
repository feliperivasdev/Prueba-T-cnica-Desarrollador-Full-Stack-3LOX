using Microsoft.AspNetCore.Mvc;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;

namespace PsychometricApp.WebApi.Controllers;

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
    public async Task<ActionResult<IEnumerable<QuestionBlockDto>>> GetAll()
    {
        var blocks = await _service.GetAllAsync();
        return Ok(blocks);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<QuestionBlockDto>> GetById(int id)
    {
        var block = await _service.GetByIdAsync(id);
        if (block == null) return NotFound();
        return Ok(block);
    }

    [HttpGet("by-test/{testId}")]
    public async Task<ActionResult<IEnumerable<QuestionBlockDto>>> GetByTestId(int testId)
    {
        var blocks = await _service.GetByTestIdAsync(testId);
        return Ok(blocks);
    }

    [HttpPost]
    public async Task<ActionResult<QuestionBlockDto>> Create(QuestionBlockDto dto)
    {
        var created = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, QuestionBlockDto dto)
    {
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