using System;

public static void Run(TimerInfo myTimer, TraceWriter log)
{
    log.Info($"C# Timer trigger function executed at: {DateTime.Now}");
}

public static class ADAuthentication
{
    const String SqlResource = "https://database.windows.net/";

    public static Task<String> GetSqlTokenAsync()
    {
        var provider = new AzureServiceTokenProvider();
        return provider.GetAccessTokenAsync(SqlResource);
    }
}

public async Task<ActionResult> UsingSP()
{
    String cs = ConfigurationManager.ConnectionStrings["SqlDb"].ConnectionString;

    var token = await ADAuthentication.GetSqlTokenAsync();

    var user = await GetSqlUserName(cs, token);
    ViewBag.SqlUserName = user;
    return View("UserContext");
}

private async Task<String> GetSqlUserName(String connectionString, String token)
{
    using (var conn = new SqlConnection(connectionString))
    {
        conn.AccessToken = token;
        await conn.OpenAsync();
        String text = "SELECT SUSER_SNAME()"; 
        using (var cmd = new SqlCommand(text, conn))
        {
            var result = await cmd.ExecuteScalarAsync();
            return result as String;
        }
    }
}