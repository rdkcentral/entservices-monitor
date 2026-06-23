---
applyTo: "**/*.conf.in"
---

### Plugin Configuration

### Requirement

Each plugin must define a `<PluginName>.conf.in` file that includes the following mandatory properties:

- **autostart**: Indicates whether the plugin should start automatically when the framework boots. This should be set to `false` by default.

- **callsign**: A unique identifier used to reference the plugin within the framework. Every callsign should be defined with a prefix of `org.rdk` followed by the ENT Service name written in PascalCase (e.g., `org.rdk.PersistentStore`).

- **configuration**: A JSON object containing plugin-specific configuration parameters. This is passed during activation via `PluginHost::IShell::ConfigLine()`.

#### Optional Common Properties

The following properties are commonly defined but not mandatory:

- **startuporder**: Specifies the order in which plugins are started, relative to others.

- **precondition**: A list of Thunder subsystems that must be active before the plugin can activate. If these aren't met, the plugin stays in the Preconditions state and activates automatically once they are satisfied. This can also be set via the Plugin::Metadata in the C++ code.

### Configuration Structure

#### The "root" Element

The `configuration` JSON object MAY contain a `root` element that specifies how the plugin executes:

- **REQUIRED** when the plugin has a separate implementation shared object (typically detected by an additional `add_library()` call in CMakeLists.txt, involving `*Implementation.cpp/h` files).

- **OPTIONAL** for plugins without an implementation shared object (uncommon, but allowed for advanced use cases).

- **OMITTED** for simple in-process plugins without an implementation shared object (most common pattern).

When present, the `root` element contains:

- **mode**: Execution mode of the plugin
  - `"Off"` = in-process execution
  - `"Local"` = out-of-process execution
  - If the `root` element is omitted entirely, the plugin defaults to in-process.

- **locator**: The name of the library (`.so`) that contains the plugin implementation code.

### Examples

#### Example 1: Plugin WITH Implementation Shared Object (requires root)

```python
precondition = ["Platform"]
callsign = "org.rdk.HdcpProfile"
autostart = "@PLUGIN_HDCPPROFILE_AUTOSTART@"
startuporder = "@PLUGIN_HDCPPROFILE_STARTUPORDER@"

configuration = JSON()

# root object is REQUIRED for plugins with implementation SO
rootobject = JSON()
rootobject.add("mode", "@PLUGIN_HDCPPROFILE_MODE@")
rootobject.add("locator", "lib@PLUGIN_IMPLEMENTATION@.so")
configuration.add("root", rootobject)

# Additional plugin-specific configuration
configuration.add("key", "value")
```

##### Example 2: Plugin WITHOUT Implementation Shared Object (no root)

```python
callsign = "org.rdk.Monitor"
autostart = "@PLUGIN_MONITOR_AUTOSTART@"
startuporder = "@PLUGIN_MONITOR_STARTUPORDER@"

configuration = JSON()

# No root object needed - plugin runs in-process by default
# Additional plugin-specific configuration
configuration.add("key", "value")
```
