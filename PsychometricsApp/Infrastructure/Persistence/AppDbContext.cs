using Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Test> Tests => Set<Test>();
    public DbSet<Block> Blocks => Set<Block>();
    public DbSet<Question> Questions => Set<Question>();
    public DbSet<TestResponse> TestResponses => Set<TestResponse>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Relaciones recursivas para corporativo-assessments
        modelBuilder.Entity<User>()
            .HasMany(u => u.Assessments)
            .WithOne(u => u.Corporate)
            .HasForeignKey(u => u.CorporateId)
            .OnDelete(DeleteBehavior.Restrict);

        // Enum mapping
        modelBuilder
            .Entity<User>()
            .Property(u => u.Role)
            .HasConversion<string>(); // Guarda enums como strings
    }
}
