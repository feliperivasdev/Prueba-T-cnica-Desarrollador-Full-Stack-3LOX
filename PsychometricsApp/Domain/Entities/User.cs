namespace Domain.Entities;

public class User
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string FullName { get; set; } = default!;
    public string Email { get; set; } = default!;
    public string PasswordHash { get; set; } = default!;
    
    public UserRole Role { get; set; } = UserRole.Assessment;

    // Solo para usuarios tipo "Assessment": permite asociarlos a un "Corporativo"
    public Guid? CorporateId { get; set; }
    public User? Corporate { get; set; }

    // Solo para usuarios tipo "Corporativo": listado de usuarios assessment asociados
    public ICollection<User>? Assessments { get; set; }

    // Respuestas a tests (solo para tipo "Assessment")
    public ICollection<TestResponse> TestResponses { get; set; } = new List<TestResponse>();

}
