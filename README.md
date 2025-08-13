# Baby Monitor Client

A Qt6/QML-based client application for monitoring baby cameras and environmental sensors. This application provides real-time camera streaming, camera control, and sensor data monitoring.

## Features

### Camera Streaming & Control
- **Multi-device support**: Connect to different rpicm5 devices
- **Real-time streaming**: MJPEG video streaming via WebEngine
- **Camera controls**: Adjust brightness, contrast, exposure, white balance, and more

### Sensor Monitoring
- **Temperature sensing**: Real-time temperature readings
- **Light level monitoring**: Ambient light measurement in lux
- **Automatic lighting**: Smart LED control based on configurable light thresholds
- **Data logging**: Automatic CSV logging of sensor data
- **Brightness control**: Adjustable LED brightness settings

### Security Features
- **SSL/TLS encryption**: Secure HTTPS communication
- **Self-signed certificate**: Custom certificate handling for local devices

## Dependencies
- **Qt 6.9** with the following modules:
  - Qt Quick
  - Qt Network
  - Qt WebEngine
  - Qt Quick Controls 2
  - Qt Quick Dialogs 2

## Configuration

### Device Certificates
Place your device certificates in the application directory:
- `ncwl-a01-e03-1.crt` - Certificate for the first device

The application will automatically load the appropriate certificate when connecting to a device.

## Usage

### Camera Streaming
1. **Select Device**: Choose your rpicm5 device from the dropdown
2. **Configure Camera**: 
   - Select the camera ID
   - Adjust camera controls (brightness, contrast, etc.)
   - Choose resolution and frame rate
   - Select camera eye (Left/Right for stereo setups)
3. **Start Stream**: Click "Start Stream" to begin video streaming
4. **Control**: Use the sliders and controls to adjust camera settings in real-time

### Sensor Monitoring
1. Switch to the "Sensor Data" tab
2. **Monitor readings**: View real-time temperature and light level data
3. **Configure threshold**: Set the light threshold for automatic LED control
4. **Adjust LED brightness**: Use the slider to control LED brightness
5. **View status**: Monitor the lamp status and connection state

### Data Logging
Sensor data is automatically logged to `sensor_log.csv` in the application directory with the format:
```csv
timestamp,lux_value,temp_value
```

## API Endpoints

The application communicates with the following REST API endpoints:

### Camera Endpoints
- `GET /cameras` - List available cameras
- `PUT /cameras/{id}/controls` - Update camera controls
- `PUT /cameras/{id}/reset` - Reset camera controls to defaults

### Streaming Endpoints
- `POST /stream/config/start` - Start video stream
- `PUT /stream/config/stop` - Stop video stream

### Sensor Endpoints
- `GET /sensors` - Get current sensor readings
- `PUT /sensors/lux_threshold` - Update light threshold
- `PUT /sensors/led_brightness` - Update LED brightness


### Adding New Features
**New camera controls**: Add new properties to `Camera` class and update UI