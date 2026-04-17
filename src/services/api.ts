const envApiBaseUrl = process.env.REACT_APP_API_URL;
let resolvedApiBaseUrl = envApiBaseUrl || 'http://localhost:5001';

if (process.env.NODE_ENV === 'development' && typeof window !== 'undefined') {
  const envIsLocalApi =
    typeof envApiBaseUrl === 'string' &&
    (envApiBaseUrl.startsWith('http://localhost') || envApiBaseUrl.startsWith('http://127.0.0.1'));

  resolvedApiBaseUrl = envIsLocalApi ? envApiBaseUrl! : '';
}

export const API_BASE_URL = resolvedApiBaseUrl;
