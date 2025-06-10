using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;

namespace PsychometricApp.WebApi.Controllers;


[ApiController]
[Route("api/[controller]")]
public class UserResponseController : ControllerBase
{
    private readonly IUserResponseService _service;

    public UserResponseController(IUserResponseService service)
    {
        _service = service;
    }

    [HttpGet]
    [Authorize(Roles = "assessment,corporate,admin")]
    public async Task<IActionResult> GetAll()
    {
        var responses = await _service.GetAllAsync();
        return Ok(responses);
    }

    [HttpGet("{id}")]
    [Authorize(Roles = "assessment,corporate,admin")]
    public async Task<IActionResult> GetById(int id)
    {
        var response = await _service.GetByIdAsync(id);
        if (response == null) return NotFound();
        return Ok(response);
    }

    [HttpPost]
    [Authorize(Roles = "assessment")]
    public async Task<IActionResult> Create([FromBody] UserResponseDto dto)
    {
        var created = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> Update(int id, [FromBody] UserResponseDto dto)
    {
        if (id != dto.Id) return BadRequest();

        var updated = await _service.UpdateAsync(id, dto);
        if (!updated) return NotFound();

        return NoContent();
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await _service.DeleteAsync(id);
        if (!deleted) return NotFound();

        return NoContent();
    }
}
