# internal_plugin_service

An example of using the platform channel in project with `flutter_foreground_task`.

> [!CAUTION]
> The platform-specific code that you want to use with flutter_foreground_task should not be implemented in MainActivity.
> If the service starts in the background, the platform channel cannot be initialized because Activity was not created.
> This causes MissingPluginException, so we need to solve this problem through internal plugin implementation.

## Getting started

If you created a project, create an internal plugin using the flutter command.

```text
cd your_project_path
flutter create --template=plugin --platforms=android,ios plugins/internal_plugin
```

Go to `pubspec.yaml` file and add the internal plugin you created.

```yaml
dependencies:
  internal_plugin:
    path: plugins/internal_plugin
```

And add `flutter_foreground_task` plugin. If you want to know more about `flutter_foreground_task`, go to this [page](https://github.com/Dev-hwang/flutter_foreground_task).

```yaml
dependencies:
  flutter_foreground_task: ^8.10.4
```

Run example!!
