<?php

/**
 * Laravel Scheduler Cron Job Script for cPanel
 * 
 * This script runs Laravel's scheduled tasks.
 * Set this up in cPanel's Cron Jobs section.
 * 
 * Recommended schedule: every 5 minutes
 */

// Get the absolute path to your Laravel application
$laravelPath = __DIR__;

// Change to Laravel directory
chdir($laravelPath);

// Run Laravel scheduler
$command = 'php artisan schedule:run >> /dev/null 2>&1';

// Execute the command
exec($command, $output, $returnCode);

// Log the execution (optional)
if ($returnCode !== 0) {
    error_log("Laravel scheduler failed with code: $returnCode");
} else {
    error_log("Laravel scheduler executed successfully at " . date('Y-m-d H:i:s'));
}

// Output for debugging (remove in production)
echo "Laravel scheduler executed at " . date('Y-m-d H:i:s') . "\n";
echo "Return code: $returnCode\n";
if (!empty($output)) {
    echo "Output: " . implode("\n", $output) . "\n";
} 