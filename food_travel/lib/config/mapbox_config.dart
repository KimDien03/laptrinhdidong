/// Central place to manage the Mapbox access token used across the app.
///
/// Update this value when rotating credentials or configure a `--dart-define`
/// to override it at runtime if you need environment-specific tokens.
const String mapboxAccessToken = String.fromEnvironment(
  'MAPBOX_ACCESS_TOKEN',
  defaultValue:
      'pk.eyJ1Ijoia3V1aGFrdTEyODQiLCJhIjoiY21ndnIycjhlMHVoMTJzb2JtbGIyNndwdSJ9.ALikXkqeORf-18TFf4tBFQ',
);
