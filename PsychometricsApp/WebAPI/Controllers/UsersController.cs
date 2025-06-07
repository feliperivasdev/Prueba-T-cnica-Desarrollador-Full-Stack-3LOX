using Application.DTOs;
using Application.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization; 
using Domain.Entities;
using Microsoft.AspNetCore.Identity;

namespace WebAPI.Controllers;

[Authorize(Roles = "Admin")] 
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _userService.GetAllAsync());

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var user = await _userService.GetByIdAsync(id);
        return user == null ? NotFound() : Ok(user);
    }

    [HttpPost]
    public async Task<IActionResult> Create(RegisterRequest request)
    {
        var user = new User
        {
            Email = request.Email,
            Role = Enum.Parse<UserRole>(request.Role)
            // otros campos...
        };

        var hasher = new PasswordHasher<User>();
        user.PasswordHash = hasher.HashPassword(user, request.Password);

        var created = await _userService.CreateAsync(user);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, User user) =>
        await _userService.UpdateAsync(id, user) ? NoContent() : NotFound();

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id) =>
        await _userService.DeleteAsync(id) ? NoContent() : NotFound();
}
