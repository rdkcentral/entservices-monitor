# Monitor Plugin - Architecture Documentation

## Overview

The Monitor plugin is a WPEFramework (Thunder) plugin designed to track and monitor resource usage of other plugins running in the framework. It provides real-time memory and process statistics, restart limit management, and automatic recovery mechanisms for monitored plugins.

## System Architecture

### Component Structure

```
┌─────────────────────────────────────────────────────┐
│           WPEFramework (Thunder)                    │
│  ┌───────────────────────────────────────────────┐  │
│  │         Monitor Plugin (PluginHost)           │  │
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │     HTTP RESTful API (IWeb)             │  │  │
│  │  ├─────────────────────────────────────────┤  │  │
│  │  │     JSON-RPC API (JSONRPC)              │  │  │
│  │  ├─────────────────────────────────────────┤  │  │
│  │  │     Monitor Core (ObserverImpl)         │  │  │
│  │  │  - Memory tracking                      │  │  │
│  │  │  - Process monitoring                   │  │  │
│  │  │  - Restart management                   │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
│                       │                             │
│                       ▼                             │
│  ┌───────────────────────────────────────────────┐  │
│  │      IShell (PluginHost Services)             │  │
│  │  - Plugin lifecycle notifications             │  │
│  │  - Plugin state management                    │  │
│  │  - Configuration management                   │  │
│  └───────────────────────────────────────────────┘  │
│                       │                             │
│                       ▼                             │
│  ┌───────────────────────────────────────────────┐  │
│  │      Monitored Plugins                        │  │
│  │  (WebKitBrowser, Netflix, Cobalt, etc.)      │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Core Components

#### 1. Monitor Plugin Class
- **Inherits from**: `PluginHost::IPlugin`, `PluginHost::IWeb`, `PluginHost::JSONRPC`
- **Responsibilities**:
  - Plugin lifecycle management (Initialize/Deinitialize)
  - API endpoint registration and handling
  - Coordination between monitoring subsystems

#### 2. ObserverImpl (Monitoring Engine)
- **Key Features**:
  - Real-time memory usage tracking (resident, allocated, shared memory)
  - Process statistics monitoring (CPU usage, thread count)
  - Configurable restart limits per plugin
  - Automatic plugin restart on failure
  - Event notification system

#### 3. MetaData Collection
- **Metrics Tracked**:
  - **Allocated Memory**: Total memory allocated by the plugin
  - **Resident Memory**: Physical memory currently in use
  - **Shared Memory**: Memory shared with other processes
  - **Process Statistics**: CPU usage, active threads
  - **Statistical Analysis**: Min, Max, Average, Last values for each metric

## Data Flow

### Monitoring Cycle

```
1. Configuration Loading
   ↓
2. Plugin Registration
   ↓
3. Periodic Measurement Collection (IMemory interface)
   ↓
4. Statistical Analysis & Storage
   ↓
5. Threshold Evaluation
   ↓
6. Action Execution (if needed)
   ↓
7. Event Notification
```

### API Request Flow

#### REST API (HTTP)
- **GET /Service/Monitor**: Retrieve all plugin statistics
- **GET /Service/Monitor/{callsign}**: Retrieve specific plugin statistics
- **PUT /Service/Monitor/{callsign}**: Reset statistics for a plugin
- **POST /Service/Monitor**: Update restart limits

#### JSON-RPC API
- **status**: Query memory and process statistics
- **restartlimits**: Configure restart behavior
- **resetstats**: Reset collected statistics
- **action** (event): Notification of monitoring actions taken

## Plugin Framework Integration

### WPEFramework Interfaces

#### IPlugin Interface
- **Initialize()**: Plugin startup, configuration loading, observer setup
- **Deinitialize()**: Clean shutdown, unregister observers
- **Information()**: Plugin metadata

#### IWeb Interface
- **Process()**: HTTP request handling
- **Inbound()**: Request preprocessing

#### JSONRPC Interface
- Provides JSON-RPC 2.0 compliant API
- Automatic parameter validation and serialization
- Event notification framework

### IMemory Interface Usage
The Monitor plugin queries other plugins through the `IMemory` interface to collect:
- Current memory usage statistics
- Process resource consumption
- Operational state

## Configuration Model

### Configuration Schema
```json
{
  "observables": [
    {
      "callsign": "PluginName",
      "memory": {
        "limit": 614400
      },
      "restart": {
        "window": 60,
        "limit": 3
      }
    }
  ]
}
```

### Restart Management
- **Window**: Time period (seconds) for restart counting
- **Limit**: Maximum restarts allowed within the window
- **Behavior**: Automatic plugin restart on crash/hang within limits

## Technical Implementation Details

### Threading Model
- Main thread: HTTP/JSON-RPC request handling
- Observer thread: Periodic monitoring and data collection
- Thread-safe data structures for concurrent access

### Memory Management
- Proxy pool pattern for JSON body objects
- Efficient memory allocation for measurement data
- Automatic resource cleanup on plugin shutdown

### Error Handling
- Graceful degradation when plugins don't implement IMemory
- Timeout protection for unresponsive plugins
- Comprehensive error reporting through status API

## Dependencies

### Framework Dependencies
- **WPEFramework Core**: Base framework functionality
- **WPEFramework Plugins**: Plugin subsystem
- **CompileSettingsDebug**: Debug configuration

### Interface Dependencies
- `IMemory`: Memory statistics collection
- `IShell`: Plugin host services
- `JSONRPC`: JSON-RPC functionality

## Build System

- **CMake-based** build configuration
- **Modular design** allowing standalone compilation
- **Configuration options** for monitored plugin list
- **Memory limit customization** per plugin

## Security Considerations

- Read-only access to other plugin statistics
- Optional security token validation (can be disabled)
- No direct memory manipulation of monitored plugins
- Event-based architecture prevents direct plugin interaction

---

**Version**: 1.1.0  
**API Compatibility**: Thunder R4.4+  
**License**: Apache 2.0
