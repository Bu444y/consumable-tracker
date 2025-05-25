CONSUMABLE TRACKER - UPDATE SUMMARY
===================================

VERSION: 1.1.0
DATE: November 2024

MAJOR CHANGES IMPLEMENTED:

1. UNITS SYSTEM (Fixed)
   - Added support for multiple units: count, lbs, oz, kg, g, l, ml, percent
   - Quantity now uses actual units instead of just percentages
   - "Empty by" calculation now works correctly based on units and decrease rate
   - Decrease button now reduces by 1 unit (not 10%)

2. AUTO-DECREASE FUNCTIONALITY (Fixed)
   - Runs automatically every hour
   - Tracks last decrease time to handle missed periods
   - Manual trigger available in settings
   - Properly calculates based on day/week/month intervals

3. VIEWS AND UI IMPROVEMENTS
   - Added Grid/List view toggle
   - Added "All Consumables" view showing items across all categories
   - Added "All Tasks" view showing tasks across all categories
   - Dark mode support with toggle button
   - Mobile-responsive with collapsible sidebar
   - Sorting options:
     * Consumables: Name, Quantity, Empty Date
     * Tasks: Name, Due Date, Priority

4. RECURRING TASKS (Fixed)
   - Single task entry that updates due date when completed
   - No duplicate tasks created
   - Tracks last completion date
   - Completion history stored (for future reporting)

5. REFILL FUNCTIONALITY
   - Refill button now opens modal to set new quantity
   - Edit modal shows "Refill to" field when editing consumables
   - Maintains all other settings when refilling

6. VM INSTALLATION (Fixed)
   - Updated scripts for non-root users
   - Better permission handling
   - Node.js installation fix for VMs
   - Clear error messages for permission issues

7. NEW FEATURES ADDED
   - Image URL support for consumables
   - Notes field for additional details
   - Low stock indicators with color coding
   - Force auto-decrease button in settings
   - Category display in "All" views
   - Last completed date for recurring tasks

BREAKING CHANGES:
- Database schema updated (quantity replaces currentAmount/initialAmount)
- API endpoints updated for new schema
- Frontend completely rewritten for new features

MIGRATION NOTES:
- Old data will need to be migrated to new schema
- Run add-sample-data.sh to test new features
- Clear browser cache if UI looks wrong

FILES CHANGED:
- Backend models (consumable, task)
- All API routes
- Frontend App.js (complete rewrite)
- All component files updated
- New sample data script
- Installation scripts updated

KNOWN ISSUES:
- Image upload not implemented (URL only)
- No data migration script from old schema
- Email/Telegram alerts not yet implemented

NEXT STEPS:
1. Upload all files to GitHub
2. Pull changes on VM
3. Run: docker-compose down
4. Run: ./pre-install.sh
5. Run: ./install.sh
6. Run: ./add-sample-data.sh (optional)

For questions or issues, see TROUBLESHOOTING.md
