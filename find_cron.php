<?php
echo "Your current directory path is: " . __DIR__;
echo "<br><br>";
echo "This is the path you should use in your cPanel cron job.";
echo "<br><br>";
echo "Example cron job command:";
echo "<br>";
echo "php " . __DIR__ . "/cron.php";
?>