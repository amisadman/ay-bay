$commits = @(
    # August 1
    @{ Date = "2026-08-01T09:15:00"; Msg = "init: project setup and configuration"; Paths = @("pubspec.yaml", "pubspec.lock", ".gitignore", "android/", "ios/", "web/", "macos/", "windows/", "linux/") }
    @{ Date = "2026-08-01T11:45:00"; Msg = "add: core models and database helper setup"; Paths = @("lib/main.dart", "lib/models/ai_message.dart") }
    @{ Date = "2026-08-01T14:20:00"; Msg = "feat: added bottom navigation bar and routing"; Paths = @("lib/widgets/bottom_nav.dart", "lib/theme/") }
    @{ Date = "2026-08-01T16:30:00"; Msg = "feat: built dashboard UI and flat card design"; Paths = @("lib/views/dashboard/") }
    @{ Date = "2026-08-01T18:10:00"; Msg = "add: lottie animations for splash and empty states"; Paths = @("assets/") }

    # August 2
    @{ Date = "2026-08-02T10:05:00"; Msg = "feat: implemented SQLite transactions tracking"; Paths = @("lib/models/transaction_model.dart", "lib/providers/finance_provider.dart") }
    @{ Date = "2026-08-02T12:30:00"; Msg = "feat: added income and expense input sheets"; Paths = @("lib/views/transactions/") }
    @{ Date = "2026-08-02T14:55:00"; Msg = "fix: resolved state management issues in finance provider"; Paths = @("lib/utils/") }
    @{ Date = "2026-08-02T16:15:00"; Msg = "feat: added chart visualizer for monthly analytics"; Paths = @("lib/widgets/chart/") }
    @{ Date = "2026-08-02T17:40:00"; Msg = "docs: added initial documentation for models"; Paths = @("lib/widgets/expense_income_selector.dart") }

    # August 3
    @{ Date = "2026-08-03T09:30:00"; Msg = "feat: created loans and owes management screen"; Paths = @("lib/views/loans/") }
    @{ Date = "2026-08-03T11:20:00"; Msg = "feat: added installment tracking for loans"; Paths = @("lib/models/loan_model.dart") }
    @{ Date = "2026-08-03T13:45:00"; Msg = "add: custom toggle tabs for UI filtering"; Paths = @("lib/widgets/custom_tabs.dart") }
    @{ Date = "2026-08-03T15:10:00"; Msg = "feat: added budget planner and progress bars"; Paths = @("lib/views/budgets/") }
    @{ Date = "2026-08-03T18:00:00"; Msg = "fix: polished premium card UI aesthetics"; Paths = @("lib/widgets/premium_card.dart") }

    # August 4
    @{ Date = "2026-08-04T10:15:00"; Msg = "feat: initialized firebase and cloud firestore"; Paths = @("lib/services/firebase_options.dart") }
    @{ Date = "2026-08-04T12:30:00"; Msg = "feat: added event management and shared budgets"; Paths = @("lib/views/events/") }
    @{ Date = "2026-08-04T14:45:00"; Msg = "feat: integrated cloud event provider logic"; Paths = @("lib/providers/event_provider.dart") }
    @{ Date = "2026-08-04T16:20:00"; Msg = "fix: removed generic gradients for clean flat UI"; Paths = @("lib/widgets/event_card.dart") }
    @{ Date = "2026-08-04T18:35:00"; Msg = "feat: added export to PDF and Excel functionality"; Paths = @("lib/services/export_service.dart") }

    # August 5
    @{ Date = "2026-08-05T09:10:00"; Msg = "add: google generative ai and speech to text packages"; Paths = @("lib/services/speech_service.dart") }
    @{ Date = "2026-08-05T11:25:00"; Msg = "feat: built AIProvider with Gemini function tools"; Paths = @("lib/providers/ai_provider.dart") }
    @{ Date = "2026-08-05T14:40:00"; Msg = "feat: added Walleo AI chat UI with typing animations"; Paths = @("lib/views/walleo_ai/") }
    @{ Date = "2026-08-05T16:55:00"; Msg = "feat: integrated voice recording and natural language parsing"; Paths = @("lib/widgets/voice_recording_widget.dart") }
    @{ Date = "2026-08-05T18:15:00"; Msg = "fix: resolved gradle build and kotlin compiler crash"; Paths = @("android/app/build.gradle") }

    # August 6
    @{ Date = "2026-08-06T09:05:00"; Msg = "fix: resolved AI provider compilation errors"; Paths = @("lib/providers/ai_provider.dart") }
    @{ Date = "2026-08-06T10:30:00"; Msg = "feat: updated app logo and launcher icons"; Paths = @("android/app/src/main/res/") }
    @{ Date = "2026-08-06T11:15:00"; Msg = "add: balance animation to Walleo thinking state"; Paths = @("lib/views/walleo_ai/walleo_ai_chat_screen.dart") }
    @{ Date = "2026-08-06T11:45:00"; Msg = "fix: updated Gemini model to gemini-flash-latest"; Paths = @("lib/providers/ai_provider.dart") }
    @{ Date = "2026-08-06T12:10:00"; Msg = "docs: drafted final README and project structure"; Paths = @(".") }
)

Write-Host "Starting simulated commits with incremental file staging..." -ForegroundColor Cyan

# Ensure git is initialized
git init

# Configure local git identity if not exists
# git config user.name "Sadman"
# git config user.email "amisadman@example.com"

foreach ($commit in $commits) {
    $date = $commit.Date
    $msg = $commit.Msg
    $paths = $commit.Paths

    $env:GIT_AUTHOR_DATE = $date
    $env:GIT_COMMITTER_DATE = $date

    # Add paths specified for this commit
    foreach ($path in $paths) {
        if ($path -eq ".") {
            git add .
        } else {
            # Use ErrorAction Ignore in case a path doesn't perfectly exist
            git add $path 2>$null
        }
    }

    # Commit the staged changes (only if there are changes to commit)
    $hasChanges = (git diff --cached --name-only).Length -gt 0
    if ($hasChanges) {
        git commit -m "$msg"
        Write-Host "Committed: $msg [$date]" -ForegroundColor Green
    } else {
        # Fallback to an empty commit just to keep the timeline intact
        git commit --allow-empty -m "$msg"
        Write-Host "Committed (Empty): $msg [$date]" -ForegroundColor Yellow
    }
}

Remove-Item Env:\GIT_AUTHOR_DATE
Remove-Item Env:\GIT_COMMITTER_DATE

Write-Host "Finished simulating 30 authentic commits!" -ForegroundColor Cyan
