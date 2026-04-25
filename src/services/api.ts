const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5001';
const API_FBR_URL = `${API_BASE_URL.replace(/\/$/, '')}/api/fbr/uom`;

export { API_BASE_URL, API_FBR_URL };
