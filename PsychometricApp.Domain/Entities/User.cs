namespace PsychometricApp.Domain.Entities;

public class User
{
    public int Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string UserType { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Relaciones
    public int? CorporateId { get; set; }
    public User? Corporate { get; set; }
    public ICollection<User>? Assessments { get; set; }
    public ICollection<Test>? CreatedTests { get; set; }
    public ICollection<BlockResult>? BlockResults { get; set; }
    public ICollection<UserResponse>? Responses { get; set; }
}