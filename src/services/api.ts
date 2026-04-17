const envApiBaseUrl = process.env.REACT_APP_API_URL;
let resolvedApiBaseUrl = envApiBaseUrl || 'http://localhost:5001';

if (process.env.NODE_ENV === 'development' && typeof window !== 'undefined') {
  const isLocalFrontend =
    window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';

  if (isLocalFrontend && envApiBaseUrl && /onrender\.com/i.test(envApiBaseUrl)) {
    resolvedApiBaseUrl = 'http://localhost:5001';
  }
}

export const API_BASE_URL = resolvedApiBaseUrl;
