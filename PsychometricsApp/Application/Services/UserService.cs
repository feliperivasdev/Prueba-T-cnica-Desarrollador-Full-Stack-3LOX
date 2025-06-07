using Application.Interfaces;
using Domain.Entities;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Application.Services;

public class UserService : IUserService
{
    private readonly AppDbContext _context;

    public UserService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<User>> GetAllAsync() =>
        await _context.Users.Include(u => u.Corporate).ToListAsync();

    public async Task<User?> GetByIdAsync(Guid id) =>
        await _context.Users.Include(u => u.Corporate).FirstOrDefaultAsync(u => u.Id == id);

    public async Task<User> CreateAsync(User user)
    {
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }

    public async Task<bool> UpdateAsync(Guid id, User user)
    {
        var existing = await _context.Users.FindAsync(id);
        if (existing == null) return false;

        existing.FullName = user.FullName;
        existing.Email = user.Email;
        existing.Role = user.Role;
        existing.CorporateId = user.CorporateId;

        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var existing = await _context.Users.FindAsync(id);
        if (existing == null) return false;

        _context.Users.Remove(existing);
        await _context.SaveChangesAsync();
        return true;
    }
}
