using System;

namespace PsychometricApp.Application.DTOs;

public class BlockResultDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int BlockId { get; set; }
    public decimal TotalScore { get; set; }
    public decimal AverageScore { get; set; }
    public DateTime CompletedAt { get; set; }
}
