<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Ping a Host</title>
<style>
        body {
            background-color: #1e1e1e;
            color: #f1f1f1;
            font-family: Consolas, monospace;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }
 
        form {
            margin-bottom: 20px;
        }
 
        input[type="text"] {
            padding: 8px;
            width: 300px;
            border: none;
            border-radius: 4px;
            font-size: 16px;
        }
 
        input[type="submit"] {
            padding: 8px 16px;
            margin-left: 10px;
            border: none;
            border-radius: 4px;
            background-color: #4caf50;
            color: white;
            font-size: 16px;
            cursor: pointer;
        }
 
        pre {
            background-color: #111;
            padding: 15px;
            border-radius: 6px;
            width: 80%;
            max-width: 800px;
            overflow-x: auto;
            white-space: pre-wrap;
        }
</style>
</head>
<body>
 
<h2>🖥️ Ping a Host</h2>
 
<form method="GET">
<input type="text" name="ip" placeholder="Enter IP address...">
<input type="submit" value="Ping">
</form>
 
<?php
if (isset($_GET['ip'])) {
    $ip = $_GET['ip'];
    // ⚠️ ثغرة: لا يتم التحقق من قيمة ip
    $output = shell_exec("ping -c 1 $ip");
    echo "<pre>$output</pre>";
}
?>
 
</body>
</html>