from revoscalepy import RxComputeContext
from revoscalepy import RxInSqlServer
from revoscalepy import RxSqlServerData
from revoscalepy import rx_import


class DataSource():

    def __init__(self, connectionstring):

         """Data source remote compute context


                Args:
                    connectionstring: connection string to the SQL server.
                    
            
          """
         self.__connectionstring = connectionstring
         
    

    def loaddata(self):
        dataSource = RxSqlServerData(sql_query = "select * from dbo.trainingdata", verbose=True,
        #dataSource = RxSqlServerData(sql_query = "select top 10000 * from dbo.trainingdata", verbose=True,
                                     connection_string = self.__connectionstring)

        self.__computeContext = RxInSqlServer(connection_string = self.__connectionstring, auto_cleanup = True)  
        data = rx_import(dataSource)

        return data

    def getcomputecontext(self):
 
        if self.__computeContext is None:
            raise RuntimeError("Data must be loaded before requesting computecontext!")

        return self.__computeContext

