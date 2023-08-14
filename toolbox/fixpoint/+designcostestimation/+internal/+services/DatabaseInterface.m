classdef DatabaseInterface<designcostestimation.internal.services.Service




    properties(Constant)
        DatabaseName='profiling.db';
    end

    properties
        Design char
        Query char
        Result cell
    end

    methods

        function obj=DatabaseInterface(ModelName)
            obj.Design=ModelName;
        end



        function runService(obj)

            db_connect=matlab.depfun.internal.database.SqlDbConnector;
            db_connect.connect(obj.DatabaseName);

            db_connect.doSql(obj.Query);
            obj.Result=db_connect.fetchRows;
            db_connect.disconnect();
        end
    end
end


