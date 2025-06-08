using Microsoft.AspNetCore.Mvc;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;

[ApiController]
[Route("api/[controller]")]


public class TestController : ControllerBase
{
    private readonly ITestService _service;
    public TestController(ITestService service)
    {
        _service = service;
    }
    
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var tests = await _service.GetAllAsync();
        return Ok(tests);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var test = await _service.GetByIdAsync(id);
        if (test == null) return NotFound();
        return Ok(test);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TestDto dto)
    {
        var createdTest = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = createdTest.Id }, createdTest);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] TestDto dto)
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