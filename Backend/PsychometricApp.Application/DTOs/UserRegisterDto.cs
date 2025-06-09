namespace PsychometricApp.Application.DTOs;

public class UserRegisterDto
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string UserType { get; set; } = "assessment"; // o el valor por defecto que prefieras
    public int? CorporateId { get; set; }
}
