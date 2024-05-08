import relationalStore from '@ohos.data.relationalStore'

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private rdbStore: relationalStore.RdbStore = null;
  private STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'RKSQLite.db',
    securityLevel: relationalStore.SecurityLevel.S1
  }
  static TABLE_CATALYST = "catalystLocalStorage";
  static KEY_COLUMN = "key";
  static VALUE_COLUMN = "value"
  private DATABASE_VERSION = 1;
  private SLEEP_TIME_MS = 30;;
  private dbname = "RKSQLite.db";
  param: Record<string, Object>;
  build() {
    Row() {
      Column() {
        Button("打开SQL").onClick(() => {
          let promise = relationalStore.getRdbStore(getContext(),this.STORE_CONFIG);
          promise.then(async (store) => {
            this.rdbStore = store;
            console.log(`Get RdbStore success`);
            this.message = this.message+'\nGet RdbStore success';
            return this.rdbStore;
          }).catch((err) => {
            console.log(`Get RdbStore failed`);
            this.message = this.message+'\nGet RdbStore failed';
            throw new Error(`Get RdbStore failed, code is ${err.code},message is ${err.message}`);
          })
        })
        Divider().height(10);
        Button("插入SQL").onClick(() => {

          let table = this.extractTableNameFromSql('INSERT INTO Offices (name, longtitude, latitude) VALUES ("Denver", 59.8,  34.);');
          const  values = this.extractInsertObject('INSERT INTO Offices (name, longtitude, latitude) VALUES ("Denver", 59.8,  34.);')
          console.log(table);
          console.log(JSON.stringify(values));
          console.log(values.tableName);
          this.message = this.message+'\n'+JSON.stringify(values);
          for (let i = 0; i < values.fields.length; i++) {
            // mapParam.set(values.fields[i],values.values[i]);
            // this.param.
            let info = "key: "+values.fields[i]+"    value: "+values.values[i];
            console.log(info);
          }

          const valueBucket = {
            "NAME": "Lisa",
            "AGE": 18,
            "SALARY": 100.5,
            "CODES": new Uint8Array([1, 2, 3, 4, 5]),
          };
          this.rdbStore.insert(values.tableName,valueBucket,function (err,rowId){

          });
        })
        Divider().height(10);
        Button("删除SQL").onClick(() => {
          let promise = relationalStore.deleteRdbStore(getContext(), this.dbname);
          promise.then(async () => {
            this.rdbStore=undefined;
            console.log(`Delete RdbStore successfully.`);
            this.message = this.message+'\nDelete RdbStore successfully';
          }).catch((err) => {
            console.log(`Delete RdbStore failed`);
            this.message = this.message+'\nDelete RdbStore failed';
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
  extractTableNameFromSql(sql: string): string | undefined {
    const createTablePattern = /CREATE TABLE IF NOT EXISTS (\w+)/i;
    const insertIntoPattern = /INSERT INTO (\w+)/i;
    const selectPattern = /FROM (\w+)/i;

    const createTableMatch = createTablePattern.exec(sql);
    const insertIntoMatch = insertIntoPattern.exec(sql);
    const selectMatch = selectPattern.exec(sql);

    if (createTableMatch) {
      return createTableMatch[1];
    } else if (insertIntoMatch) {
      return insertIntoMatch[1];
    } else if (selectMatch) {
      return selectMatch[1];
    }

    console.warn('Could not extract table name from the provided SQL statement.');
    return undefined;
  }
  extractInsertObject(sql: string): { tableName: string, fields: string[], values: string[] } | null {
    const insertPattern = /INSERT INTO\s+(\w+)\s*\((.*?)\)\s*VALUES\s*\((.*?)\)/i;
    const match = sql.match(insertPattern);

    if (match) {
      const tableName = match[1];
      const fields = match[2].split(',').map(field => field.trim());
      const valueStrings = match[3].split(',').map(value => value.trim());

      // 如果需要进一步解析值（比如从字符串转为实际类型），这里可以添加逻辑
      return { tableName, fields, values: valueStrings };
    }

    return null; // 如果不匹配返回null
  }
}
