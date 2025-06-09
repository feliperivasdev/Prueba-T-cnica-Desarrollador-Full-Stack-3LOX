using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;


[Authorize(Roles = "assessment,corporate,admin")]
[ApiController]
[Route("api/[controller]")]
public class QuestionController : ControllerBase
{
    private readonly IQuestionService _service;

    public QuestionController(IQuestionService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var questions = await _service.GetAllAsync();
        return Ok(questions);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var question = await _service.GetByIdAsync(id);
        if (question == null) return NotFound();
        return Ok(question);
    }

    [HttpGet("ByBlock/{blockId}")]
    public async Task<IActionResult> GetByBlockId(int blockId)
    {
        var questions = await _service.GetByBlockIdAsync(blockId);
        return Ok(questions);
    }

    [HttpPost]
    [Authorize(Roles = "admin,corporate")]
    public async Task<IActionResult> Create([FromBody] QuestionDto dto)
    {
        var created = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "admin,corporate")]
    public async Task<IActionResult> Update(int id, [FromBody] QuestionDto dto)
    {
        if (id != dto.Id) return BadRequest();

        var updated = await _service.UpdateAsync(id, dto);
        if (!updated) return NotFound();

        return NoContent();
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "admin,corporate")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await _service.DeleteAsync(id);
        if (!deleted) return NotFound();

        return NoContent();
    }
}