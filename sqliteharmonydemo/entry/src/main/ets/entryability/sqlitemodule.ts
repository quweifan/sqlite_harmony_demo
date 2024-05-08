import relationalStore from '@ohos.data.relationalStore'
import Logger from './Logger';
import CommonConstants from './CommonConstants';
import common from '@ohos.app.ability.common';
import UIAbility from '@ohos.app.ability.UIAbility';

export default class SQLitemodule{
  rdbStore: relationalStore.RdbStore = null;
  rdbMap: Map<string,relationalStore.RdbStore>;
  static TABLE_CATALYST = "catalystLocalStorage";
  static KEY_COLUMN = "key";
  static VALUE_COLUMN = "value"
  private DATABASE_VERSION = 1;
  private SLEEP_TIME_MS = 30;
  private VERSION_TABLE_CREATE =
    "CREATE TABLE IF NOT EXISTS " + SQLitemodule.TABLE_CATALYST + " (" +
    SQLitemodule.KEY_COLUMN + " TEXT PRIMARY KEY, " +
    SQLitemodule.VALUE_COLUMN + " TEXT NOT NULL" +
      ")";

  private STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'RKSQLite.db',
    securityLevel: relationalStore.SecurityLevel.S1
  }

  open(context: common.Context,dbname:string){
    if (this.rdbMap.get(dbname)!=null) {
      this.rdbStore = this.rdbMap.get(dbname);
      Logger.debug(CommonConstants.TAG, `Get RdbStore success`,);
      this.rdbStore.executeSql(this.VERSION_TABLE_CREATE)
      Logger.debug(CommonConstants.TAG, `Create table done.`);
      return this.rdbStore;
    }else{
      this.STORE_CONFIG.name = dbname;
      let promise = relationalStore.getRdbStore(context,this.STORE_CONFIG);
      promise.then(async (store) => {
        this.rdbStore = store;
        this.rdbMap.set(dbname,this.rdbStore);
        Logger.debug(CommonConstants.TAG, `Get RdbStore success`,);
        this.rdbStore.executeSql(this.VERSION_TABLE_CREATE)
        Logger.debug(CommonConstants.TAG, `Create table done.`);
        return this.rdbStore;
      }).catch((err) => {
        Logger.debug(CommonConstants.TAG,'Get RdbStore failed');
        throw new Error(`Get RdbStore failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }
}