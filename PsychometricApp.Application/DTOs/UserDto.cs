namespace PsychometricApp.Application.DTOs;

public class UserDto
{
    public int Id { get; set; }
    public string Email { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string UserType { get; set; }
    public int? CorporateId { get; set; }
}