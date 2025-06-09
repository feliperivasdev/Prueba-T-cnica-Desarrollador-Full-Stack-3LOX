using Microsoft.AspNetCore.Mvc;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;

namespace PsychometricApp.WebApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AnswerOptionController : ControllerBase
{
    private readonly IAnswerOptionService _service;

    public AnswerOptionController(IAnswerOptionService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var options = await _service.GetAllAsync();
        return Ok(options);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var option = await _service.GetByIdAsync(id);
        if (option == null) return NotFound();
        return Ok(option);
    }

    [HttpGet("ByQuestion/{questionId}")]
    public async Task<IActionResult> GetByQuestionId(int questionId)
    {
        var options = await _service.GetByQuestionIdAsync(questionId);
        return Ok(options);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AnswerOptionDto dto)
    {
        var created = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] AnswerOptionDto dto)
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