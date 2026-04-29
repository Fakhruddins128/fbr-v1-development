import { API_BASE_URL } from '../services/api';
import { API_FBR_URL } from '../services/api';

export interface Item {
  itemId: string;
  companyId: string;
  hsCode: string;
  description: string;
  unitPrice: number;
  purchaseTaxValue: number;
  salesTaxValue: number;
  uom: string;
  initialStock: number;
  currentStock: number;
  itemCreateDate: string;
  isActive: boolean;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateItemRequest {
  hsCode: string;
  description: string;
  unitPrice: number;
  purchaseTaxValue: number;
  salesTaxValue: number;
  uom: string;
  initialStock: number;
}

export interface UpdateItemRequest extends CreateItemRequest {
  itemId: string;
}

export interface ItemResponse {
  success: boolean;
  data?: Item | Item[];
  message?: string;
  error?: string;
}

export interface UnitOfMeasurement {
  code: string;
  description?: string;
}

export interface UnitOfMeasurementsResponse {
  success: boolean;
  data?: UnitOfMeasurement[];
  message?: string;
  error?: string;
}

class ItemsApi {
  private getCompanyIdForFbr(): string | null {
    const selectedCompanyId = localStorage.getItem('selectedCompanyId');
    if (selectedCompanyId) return selectedCompanyId;

    const userData = localStorage.getItem('user');
    if (!userData) return null;

    try {
      const user = JSON.parse(userData);
      return typeof user?.companyId === 'string' ? user.companyId : null;
    } catch {
      return null;
    }
  }

  private async fetchFbrTokenFromBackend(companyId: string): Promise<string | null> {
    const response = await fetch(`${API_BASE_URL}/api/companies/${companyId}/fbr-token`, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });

    if (!response.ok) return null;

    const result = await response.json();
    const token = result?.data?.fbrToken;
    return typeof token === 'string' && token.trim().length > 0 ? token.trim() : null;
  }

  private normalizeUomPayload(payload: any): UnitOfMeasurement[] {
    const list = Array.isArray(payload)
      ? payload
      : Array.isArray(payload?.data)
        ? payload.data
        : Array.isArray(payload?.uom)
          ? payload.uom
          : [];

    return list
      .map((row: any) => {
        if (!row || typeof row !== 'object') return null;

        const codeCandidate =
          row?.code ??
          row?.Code ??
          row?.uom ??
          row?.Uom ??
          row?.UOM ??
          row?.uomId ??
          row?.uomID ??
          row?.uom_id ??
          row?.uoM_ID ??
          row?.UoM_ID ??
          row?.UOM_ID ??
          row?.uomCode ??
          row?.UomCode ??
          row?.UOMCode ??
          row?.uoM ??
          row?.UoM ??
          row?.uom_code ??
          row?.UOM_CODE ??
          row?.uomCd ??
          row?.UOM_CD;

        const descriptionCandidate =
          row?.description ??
          row?.Description ??
          row?.name ??
          row?.Name ??
          row?.uomDesc ??
          row?.UomDesc ??
          row?.UOMDesc ??
          row?.uoMDesc ??
          row?.UoMDesc ??
          row?.uom_desc ??
          row?.uoM_DESC ??
          row?.UoM_DESC ??
          row?.UOM_DESC;

        const keys = Object.keys(row);
        const lowerKeyMap = keys.reduce((acc: Record<string, string>, k) => {
          acc[k.toLowerCase()] = k;
          return acc;
        }, {});

        const findByRegex = (regex: RegExp) => {
          const matchLower = Object.keys(lowerKeyMap).find((k) => regex.test(k));
          return matchLower ? (row as any)[lowerKeyMap[matchLower]] : undefined;
        };

        const fallbackCode =
          findByRegex(/uom.*(id|code)$/i) ??
          findByRegex(/(id|code).*uom/i) ??
          findByRegex(/^uom$/i);

        const fallbackDescription =
          findByRegex(/(desc|description|name)$/i) ??
          findByRegex(/uom.*(desc|description|name)/i);

        let code: any = codeCandidate ?? fallbackCode;
        let description: any = descriptionCandidate ?? fallbackDescription;

        if ((code === undefined || code === null || String(code).trim() === '') && keys.length === 2) {
          code = (row as any)[keys[0]];
          description = (row as any)[keys[1]];
        }

        if (code === undefined || code === null || String(code).trim() === '') return null;

        return {
          code: String(code),
          description: description ? String(description) : undefined,
        } as UnitOfMeasurement;
      })
      .filter(Boolean) as UnitOfMeasurement[];
  }

  private async getUnitOfMeasurementsDirectFromFbr(): Promise<UnitOfMeasurementsResponse> {
    try {
      const companyId = this.getCompanyIdForFbr();
      if (!companyId) {
        return { success: false, message: 'Company not selected' };
      }

      const rawToken = await this.fetchFbrTokenFromBackend(companyId);
      if (!rawToken) {
        return { success: false, message: 'No FBR token configured for this company' };
      }

      const authorizationHeader = /^bearer\s+/i.test(rawToken) ? rawToken : `Bearer ${rawToken}`;
      const response = await fetch('https://gw.fbr.gov.pk/pdi/v1/uom', {
        method: 'GET',
        headers: {
          Authorization: authorizationHeader,
          Accept: 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const payload = await response.json();
      return { success: true, data: this.normalizeUomPayload(payload) };
    } catch (error: any) {
      return {
        success: false,
        message: error.message || 'Failed to fetch units of measurement',
        error: error.message,
      };
    }
  }

  private getAuthHeaders() {
    const token = localStorage.getItem('auth_token');
    const selectedCompanyId = localStorage.getItem('selectedCompanyId');
    
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    
    if (selectedCompanyId) {
      headers['X-Company-ID'] = selectedCompanyId;
    }
    
    return headers;
  }

  async getUnitOfMeasurements(): Promise<UnitOfMeasurementsResponse> {
    try {
      const response = await fetch(`${API_FBR_URL}`, {
        method: 'GET',
        headers: this.getAuthHeaders(),
      });

      if (!response.ok) {
        if (response.status === 404) {
          return await this.getUnitOfMeasurementsDirectFromFbr();
        }
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      if (data?.success === true) return data;
      return { success: true, data: this.normalizeUomPayload(data) };
    } catch (error: any) {
      return {
        success: false,
        message: error.message || 'Failed to fetch units of measurement',
        error: error.message,
      };
    }
  }

  async getAllItems(): Promise<ItemResponse> {
    try {
      const response = await fetch(`${API_BASE_URL}/api/items`, {
        method: 'GET',
        headers: this.getAuthHeaders(),
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      return data;
    } catch (error: any) {
      console.error('Error fetching items:', error);
      return {
        success: false,
        message: error.message || 'Failed to fetch items',
        error: error.message
      };
    }
  }

  async createItem(item: CreateItemRequest): Promise<ItemResponse> {
    try {
      const response = await fetch(`${API_BASE_URL}/api/items`, {
        method: 'POST',
        headers: this.getAuthHeaders(),
        body: JSON.stringify(item),
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      return data;
    } catch (error: any) {
      console.error('Error creating item:', error);
      return {
        success: false,
        message: error.message || 'Failed to create item',
        error: error.message
      };
    }
  }

  async updateItem(itemId: string, item: CreateItemRequest): Promise<ItemResponse> {
    try {
      const response = await fetch(`${API_BASE_URL}/api/items/${itemId}`, {
        method: 'PUT',
        headers: this.getAuthHeaders(),
        body: JSON.stringify(item),
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      return data;
    } catch (error: any) {
      console.error('Error updating item:', error);
      return {
        success: false,
        message: error.message || 'Failed to update item',
        error: error.message
      };
    }
  }

  async deleteItem(itemId: string): Promise<ItemResponse> {
    try {
      const response = await fetch(`${API_BASE_URL}/api/items/${itemId}`, {
        method: 'DELETE',
        headers: this.getAuthHeaders(),
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      return data;
    } catch (error: any) {
      console.error('Error deleting item:', error);
      return {
        success: false,
        message: error.message || 'Failed to delete item',
        error: error.message
      };
    }
  }
}

export const itemsApi = new ItemsApi();
