import { relStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export interface PetStatus {
  id: number;
  love: number;
  hungry: number;
  wash: number;
}

const STORE_CONFIG: relStore.StoreConfig = {
  name: 'PetStore.db',
  securityLevel: relStore.SecurityLevel.S1
};

const SQL_CREATE_TABLE = 'CREATE TABLE IF NOT EXISTS PET_STATUS (ID INTEGER PRIMARY KEY, LOVE INTEGER, HUNGRY INTEGER, WASH INTEGER)';

export class DbHelper {
  private static instance: DbHelper;
  private store: relStore.RdbStore | null = null;

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
      this.store = await relStore.getRdbStore(context, STORE_CONFIG);
      await this.store.executeSql(SQL_CREATE_TABLE);
      console.info('Database initialized successfully');
    } catch (err) {
      console.error(`Failed to initialize database. Code: ${err.code}, message: ${err.message}`);
    }
  }

  public async getStatus(): Promise<PetStatus | null> {
    if (!this.store) return null;
    let predicates = new relStore.RdbPredicates('PET_STATUS');
    predicates.equalTo('ID', 1);
    let resultSet: relStore.ResultSet | null = null;
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
      console.error(`Failed to query status. Code: ${err.code}, message: ${err.message}`);
    } finally {
      if (resultSet) {
        resultSet.close();
      }
    }
    return null;
  }

  public async updateStatus(status: PetStatus): Promise<void> {
    if (!this.store) return;
    const valueBucket: relStore.ValuesBucket = {
      'ID': 1,
      'LOVE': status.love,
      'HUNGRY': status.hungry,
      'WASH': status.wash
    };
    let predicates = new relStore.RdbPredicates('PET_STATUS');
    predicates.equalTo('ID', 1);
    let resultSet: relStore.ResultSet | null = null;
    try {
      resultSet = await this.store.query(predicates);
      if (resultSet.rowCount > 0) {
        await this.store.update(valueBucket, predicates);
      } else {
        await this.store.insert('PET_STATUS', valueBucket);
      }
    } catch (err) {
      console.error(`Failed to update status. Code: ${err.code}, message: ${err.message}`);
    } finally {
      if (resultSet) {
        resultSet.close();
      }
    }
  }
}
