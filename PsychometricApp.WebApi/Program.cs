using Microsoft.EntityFrameworkCore;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Application.Services;
using PsychometricApp.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

// ==========================
// Configuración de Servicios
// ==========================

// Base de datos (PostgreSQL)
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Servicios de aplicación (Inyección de dependencias)
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<ITestService, TestService>();
builder.Services.AddScoped<IQuestionBlockService, QuestionBlockService>();
builder.Services.AddScoped<IQuestionService, QuestionService>();
builder.Services.AddScoped<IAnswerOptionService, AnswerOptionService>();
builder.Services.AddScoped<IUserResponseService, UserResponseService>();
builder.Services.AddScoped<IBlockResultService, BlockResultService>();

// Controladores y Swagger/OpenAPI
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// TODO: Configurar autenticación y autorización (JWT) aquí

// ==========================
// Construcción de la Aplicación
// ==========================
var app = builder.Build();

// ==========================
// Configuración de Middleware
// ==========================
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// TODO: app.UseAuthentication(); // Descomentar cuando se configure autenticación
app.UseAuthorization();

app.MapControllers();

app.Run();