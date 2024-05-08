import relationalStore from '@ohos.data.relationalStore'
import CommonConstants from '../entryability/CommonConstants';
import Logger from '../entryability/Logger';
import SQLitemodule from '../entryability/sqlitemodule';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private sqlModule =  new SQLitemodule();
  private rdbStore: relationalStore.RdbStore = null;
  private STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'RKSQLite.db',
    securityLevel: relationalStore.SecurityLevel.S1
  }
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
  private dbname = "RKSQLite.db";
  build() {
    Row() {
      Column() {
        Button("打开SQL").onClick(() => {
          let promise = relationalStore.getRdbStore(getContext(),this.STORE_CONFIG);
          promise.then(async (store) => {
            this.rdbStore = store;
            console.log(`Get RdbStore success`);
            this.message = this.message+'\nGet RdbStore success';
            Logger.debug(CommonConstants.TAG, `Get RdbStore success`,);
            this.rdbStore.executeSql(this.VERSION_TABLE_CREATE)
            console.log(`Create table done`);
            this.message = this.message+'\nCreate table done';
            Logger.debug(CommonConstants.TAG, `Create table done.`);
            return this.rdbStore;
          }).catch((err) => {
            console.log(`Get RdbStore failed`);
            this.message = this.message+'\nGet RdbStore failed';
            Logger.debug(CommonConstants.TAG,'Get RdbStore failed');
            throw new Error(`Get RdbStore failed, code is ${err.code},message is ${err.message}`);
          })
        })
        Divider().height(10);
        Button("删除SQL").onClick(() => {
          let promise = relationalStore.deleteRdbStore(getContext(), this.dbname);
          promise.then(async () => {
            this.rdbStore=undefined;
            console.log(`Delete RdbStore successfully.`);
            this.message = this.message+'\nDelete RdbStore successfully';
            Logger.debug(CommonConstants.TAG, `Delete RdbStore successfully.`,);
          }).catch((err) => {
            console.log(`Delete RdbStore failed`);
            this.message = this.message+'\nDelete RdbStore failed';
            Logger.debug(CommonConstants.TAG,'Delete RdbStore failed');
            throw new Error(`Delete RdbStore failed, code is ${err.code},message is ${err.message}`);
          })
        })
        Divider().height(10);
        Button("执行SQL").onClick(() => {
          let querySQL = "SELECT 1 FROM Version LIMIT 1";
          let queryParams = [];
          this.message = this.message+"\nSQLiteDatabase Query "+querySQL;
          this.rdbStore.querySql(querySQL,queryParams,function (err,resultSet){
            if (err) {
              console.log(`SQLiteDatabase Query failed`);
              this.message = this.message+'\nSQLiteDatabase Query failed,code is'+err.code+',message is '+err.message;
            }else{
              let queryResult = new Array();
              let key = '';
              let colCount = resultSet.columnCount;
              while (resultSet.goToNextRow()){
                let row = new Map();
                for (let i = 0; i < colCount; i++) {
                  key =resultSet.getColumnName(i);
                  // row.set(key,resultSet.getValue(i));
                  row.set(key,1);
                }
                queryResult.push(row)
              }
              console.log("\nSQLiteDatabase Query "+querySQL+"\n"+JSON.stringify(queryResult));
              // this.message = "\nSQLiteDatabase Query "+querySQL+"\n"+JSON.stringify(queryResult);
              // 释放数据集的内存
              resultSet.close();
              // this.message = "\n释放数据集的内存";
            }
          });
        })
        Text(this.message)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }

  aboutToAppear(){

  }
}