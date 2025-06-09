using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;

namespace PsychometricApp.WebApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TestController : ControllerBase
{
    private readonly ITestService _testService;

    public TestController(ITestService testService)
    {
        _testService = testService;
    }

    [HttpGet]
    [Authorize(Roles = "assessment,corporate,admin")]
    public async Task<ActionResult<IEnumerable<TestDto>>> GetAll()
    {
        var tests = await _testService.GetAllAsync();
        return Ok(tests);
    }

    [HttpGet("{id}")]
    [Authorize(Roles = "assessment,corporate,admin")]
    public async Task<ActionResult<TestDto>> GetById(int id)
    {
        var test = await _testService.GetByIdAsync(id);
        if (test == null) return NotFound();
        return Ok(test);
    }

    [HttpPost]
    [Authorize(Roles = "admin,corporate")]
    public async Task<ActionResult<TestDto>> Create(TestDto dto)
    {
        var created = await _testService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "admin,corporate")]
    public async Task<IActionResult> Update(int id, TestDto dto)
    {
        var updated = await _testService.UpdateAsync(id, dto);
        if (!updated) return NotFound();
        return NoContent();
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "admin,corporate")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await _testService.DeleteAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }
}