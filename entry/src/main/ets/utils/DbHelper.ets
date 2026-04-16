import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export interface PetStatus {
  id: number;
  love: number;
  hungry: number;
  wash: number;
}

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'PetStore.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const SQL_CREATE_TABLE = 'CREATE TABLE IF NOT EXISTS PET_STATUS (ID INTEGER PRIMARY KEY, LOVE INTEGER, HUNGRY INTEGER, WASH INTEGER)';

export class DbHelper {
  private static instance: DbHelper;
  private store: relationalStore.RdbStore | null = null;

  private constructor() {}

  public static getInstance(): DbHelper {
    if (!DbHelper.instance) {
      DbHelper.instance = new DbHelper();
    }
    return DbHelper.instance;
  }

  public async init(context: common.Context): Promise<void> {
    if (this.store) return;
    try {
      this.store = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await this.store.executeSql(SQL_CREATE_TABLE);
      console.info('Database initialized successfully');
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to initialize database. Code: ${error.code}, message: ${error.message}`);
    }
  }

  public async getStatus(): Promise<PetStatus | null> {
    if (!this.store) return null;
    let predicates = new relationalStore.RdbPredicates('PET_STATUS');
    predicates.equalTo('ID', 1);
    let resultSet: relationalStore.ResultSet | null = null;
    try {
      resultSet = await this.store.query(predicates);
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        const status: PetStatus = {
          id: resultSet.getLong(resultSet.getColumnIndex('ID')),
          love: resultSet.getLong(resultSet.getColumnIndex('LOVE')),
          hungry: resultSet.getLong(resultSet.getColumnIndex('HUNGRY')),
          wash: resultSet.getLong(resultSet.getColumnIndex('WASH'))
        };
        return status;
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to query status. Code: ${error.code}, message: ${error.message}`);
    } finally {
      if (resultSet) {
        resultSet.close();
      }
    }
    return null;
  }

  public async updateStatus(status: PetStatus): Promise<void> {
    if (!this.store) return;
    const valueBucket: relationalStore.ValuesBucket = {
      'ID': 1,
      'LOVE': status.love,
      'HUNGRY': status.hungry,
      'WASH': status.wash
    };
    let predicates = new relationalStore.RdbPredicates('PET_STATUS');
    predicates.equalTo('ID', 1);
    let resultSet: relationalStore.ResultSet | null = null;
    try {
      resultSet = await this.store.query(predicates);
      if (resultSet.rowCount > 0) {
        await this.store.update(valueBucket, predicates);
      } else {
        await this.store.insert('PET_STATUS', valueBucket);
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to update status. Code: ${error.code}, message: ${error.message}`);
    } finally {
      if (resultSet) {
        resultSet.close();
      }
    }
  }
}
