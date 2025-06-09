using Microsoft.EntityFrameworkCore;
using PsychometricApp.Domain.Entities;

namespace PsychometricApp.Infrastructure.Persistence;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Test> Tests => Set<Test>();
    public DbSet<QuestionBlock> QuestionBlocks => Set<QuestionBlock>();
    public DbSet<Question> Questions => Set<Question>();
    public DbSet<AnswerOption> AnswerOptions => Set<AnswerOption>();
    public DbSet<UserResponse> UserResponses => Set<UserResponse>();
    public DbSet<BlockResult> BlockResults => Set<BlockResult>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Tabla Users
        modelBuilder.Entity<User>()
            .HasOne(u => u.Corporate)
            .WithMany(c => c.Assessments)
            .HasForeignKey(u => u.CorporateId)
            .OnDelete(DeleteBehavior.Restrict);

        // Tabla QuestionBlock
        modelBuilder.Entity<QuestionBlock>()
            .HasIndex(qb => new { qb.TestId, qb.OrderNumber })
            .IsUnique();

        // Tabla Question
        modelBuilder.Entity<Question>()
            .HasIndex(q => new { q.BlockId, q.OrderNumber })
            .IsUnique();

        // Tabla AnswerOption
        modelBuilder.Entity<AnswerOption>()
            .HasIndex(ao => new { ao.QuestionId, ao.OrderNumber })
            .IsUnique();

        // Tabla UserResponse
        modelBuilder.Entity<UserResponse>()
            .HasIndex(ur => new { ur.UserId, ur.QuestionId })
            .IsUnique();

        // Tabla BlockResult
        modelBuilder.Entity<BlockResult>()
            .HasIndex(br => new { br.UserId, br.BlockId })
            .IsUnique();
    }
}