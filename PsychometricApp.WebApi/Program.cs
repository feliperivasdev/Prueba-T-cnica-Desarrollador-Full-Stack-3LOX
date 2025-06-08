using Microsoft.EntityFrameworkCore;
using PsychometricApp.Application.Interfaces;
using PsychometricApp.Application.Services;
using PsychometricApp.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

// 🧩 Cargar cadena de conexión desde appsettings.json
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// 🔌 Registrar DbContext con PostgreSQL
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

// 📦 Agregar controladores (API RESTful)
builder.Services.AddControllers();

// 📘 Swagger/OpenAPI para documentación y pruebas
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<ITestService, TestService>();
builder.Services.AddScoped<IQuestionBlockService, QuestionBlockService>();
builder.Services.AddScoped<IQuestionService, QuestionService>();

// 🔒 Autenticación y Autorización se configurarán luego (JWT)

// 🚀 Construir la app
var app = builder.Build();

// ⚙️ Middleware
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

// 📌 Mapear controladores
app.MapControllers();

// 🔚 Ejecutar la aplicación
app.Run();