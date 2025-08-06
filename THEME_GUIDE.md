# Task Manager App Theme Guide

This guide explains how to use the new theme system that matches the modern, purple-gradient design from the provided image.

## Overview

The theme system consists of:
- **AppTheme** (`lib/config/app_theme.dart`) - Color palette and theme configuration
- **ThemeWidgets** (`lib/widgets/theme_widgets.dart`) - Reusable UI components
- **Sample Screens** - Dashboard and Calendar screens demonstrating the theme

## Color Palette

### Primary Colors
- `primaryPurple`: `#8A2BE2` - Main purple color
- `secondaryPurple`: `#6A5ACD` - Secondary purple
- `darkPurple`: `#4B0082` - Dark purple for gradients
- `lightPurple`: `#9370DB` - Light purple

### Background Colors
- `backgroundColor`: `#F5F5F5` - Light grey background
- `cardBackground`: `#FFFFFF` - White card background

### Text Colors
- `textPrimary`: `#2C2C2C` - Main text color
- `textSecondary`: `#6B6B6B` - Secondary text color
- `textLight`: `#9E9E9E` - Light text color

## Using the Theme

### 1. Basic Theme Usage

The theme is automatically applied in `main.dart`:

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  // ... other properties
)
```

### 2. Using Theme Colors

```dart
// Access theme colors
Container(
  color: AppTheme.primaryPurple,
  child: Text('Purple background'),
)

// Use gradient decoration
Container(
  decoration: AppTheme.purpleGradientDecoration,
  child: Text('Gradient background'),
)
```

### 3. Using ThemeWidgets

#### Gradient Button
```dart
ThemeWidgets.gradientButton(
  text: 'Login',
  onPressed: () {},
  isLoading: false,
  icon: Icons.login,
)
```

#### Project Card
```dart
ThemeWidgets.projectCard(
  title: 'Front-End Development',
  subtitle: 'Project 1',
  icon: Icons.psychology,
  onTap: () {},
  date: 'October 20, 2020',
)
```

#### Task Card
```dart
ThemeWidgets.taskCard(
  title: 'Design Changes',
  subtitle: '2 Days ago',
  icon: Icons.description,
  onTap: () {},
  onMoreTap: () {},
)
```

#### Filter Chips
```dart
ThemeWidgets.filterChip(
  label: 'My Tasks',
  isSelected: true,
  onTap: () {},
)
```

#### Calendar Day
```dart
ThemeWidgets.calendarDay(
  day: 'Tu',
  date: '4',
  isSelected: true,
  isToday: true,
  onTap: () {},
)
```

#### Add Task Button
```dart
ThemeWidgets.addTaskButton(
  onPressed: () {},
)
```

#### Section Header
```dart
ThemeWidgets.sectionHeader(
  title: 'Tasks',
  trailing: IconButton(
    icon: Icon(Icons.add),
    onPressed: () {},
  ),
)
```

#### Progress Dots
```dart
ThemeWidgets.progressDots(
  total: 3,
  current: 1,
)
```

## Text Styles

Use the theme's text styles:

```dart
Text(
  'Hello Rohan!',
  style: Theme.of(context).textTheme.displaySmall,
)

Text(
  'Have a nice day.',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: AppTheme.textSecondary,
  ),
)
```

## Custom Decorations

### Purple Gradient
```dart
Container(
  decoration: AppTheme.purpleGradientDecoration,
  child: Text('Gradient background'),
)
```

### Card Decoration
```dart
Container(
  decoration: AppTheme.cardDecoration,
  child: Text('Card with shadow'),
)
```

### Selected Tab
```dart
Container(
  decoration: AppTheme.selectedTabDecoration,
  child: Text('Selected tab'),
)
```

### Unselected Tab
```dart
Container(
  decoration: AppTheme.unselectedTabDecoration,
  child: Text('Unselected tab'),
)
```

## Sample Screens

### Dashboard Screen
Located at `lib/screens/dashboard/dashboard_screen.dart`

Features:
- Greeting section with user name
- Horizontal scrolling project cards
- Filter chips for task categories
- Task list with progress indicators
- Bottom navigation

### Calendar Screen
Located at `lib/screens/calendar/calendar_screen.dart`

Features:
- Week calendar view
- Add task button
- Task list for selected date
- Bottom navigation

## Key Design Principles

1. **Light Background**: Uses `#F5F5F5` for the main background
2. **Purple Accents**: Purple gradient for important elements
3. **Rounded Corners**: Consistent 12-16px border radius
4. **Card-based Layout**: White cards with subtle shadows
5. **Typography Hierarchy**: Clear text size and weight hierarchy
6. **Interactive Elements**: Purple highlights for selected states

## Migration from Old Theme

If you have existing screens, update them to use:

1. Replace hardcoded colors with `AppTheme` constants
2. Use `ThemeWidgets` for common UI components
3. Apply the theme's text styles instead of custom styles
4. Use the gradient decorations for important elements

## Best Practices

1. **Consistency**: Always use the theme colors and components
2. **Accessibility**: Ensure sufficient contrast ratios
3. **Responsive**: Components adapt to different screen sizes
4. **Performance**: Reuse `ThemeWidgets` instead of creating custom components
5. **Maintainability**: Keep theme changes centralized in `AppTheme`

## Customization

To modify the theme:

1. Edit `AppTheme` class in `lib/config/app_theme.dart`
2. Update color constants for new palette
3. Modify `ThemeWidgets` for new component styles
4. Test changes across all screens

The theme system provides a consistent, modern design that matches the provided image while maintaining flexibility for future enhancements. 