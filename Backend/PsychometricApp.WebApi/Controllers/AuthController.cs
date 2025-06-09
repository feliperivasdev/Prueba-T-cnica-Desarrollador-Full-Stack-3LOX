using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PsychometricApp.Application.DTOs;
using PsychometricApp.Application.Interfaces;

namespace PsychometricApp.WebApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<IActionResult> Register([FromBody] UserRegisterDto dto)
    {
        // Forzar UserType a "assessment" aquí si es registro público
        dto.UserType = "assessment";
        var result = await _authService.RegisterAsync(dto);
        if (!result) return BadRequest("El correo ya está registrado.");
        return Ok("Usuario registrado correctamente.");
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] UserLoginDto dto)
    {
        var user = await _authService.GetUserByEmailAsync(dto.Email); // Nuevo método que debes agregar
        var token = await _authService.LoginAsync(dto);
        if (token == null || user == null) return Unauthorized("Credenciales inválidas.");
        return Ok(new
        {
            token,
            id = user.Id,
            firstName = user.FirstName,
            lastName = user.LastName,
            userType = user.UserType
        });
    }
}
