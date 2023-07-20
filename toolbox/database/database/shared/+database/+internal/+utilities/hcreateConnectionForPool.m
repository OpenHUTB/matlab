function c=hcreateConnectionForPool(pool,datasource,username,password)






























    p=inputParser;

    p.addRequired("pool",@(x)validateattributes(x,"parallel.Pool",{"scalar"},"createConnectionForPool","pool"));
    p.addRequired("datasource",@(x)validateattributes(x,["char","string"],{"scalartext"},"createConnectionForPool","datasource"));
    p.addRequired("username",@(x)validateattributes(x,["char","string"],{"scalartext"},"createConnectionForPool","username"));
    p.addRequired("password",@(x)validateattributes(x,["char","string"],{"scalartext"},"createConnectionForPool","password"));

    p.parse(pool,datasource,username,password);

    in_datasource=char(p.Results.datasource);
    poolobj=pool;


    database.internal.utilities.repairOldJDBCDataSources();
    dataSources=listDataSources();
    odbc=dataSources.Name(dataSources.DriverType=="ODBC");
    jdbc=dataSources.Name(dataSources.DriverType=="JDBC");
    mysql_native=dataSources.Name(dataSources.DriverType=="Native"&dataSources.Vendor=="MySQL");
    postgre_native=dataSources.Name(dataSources.DriverType=="Native"&dataSources.Vendor=="PostgreSQL");


    if~isempty(odbc)
        if ismember(in_datasource,odbc)
            try
                database(datasource,username,password,'ErrorHandling','report');
            catch ME
                throwAsCaller(ME)
            end
            c=parallel.pool.Constant(@()database(datasource,username,password),@close);
            return;
        end
    end

    if~isempty(mysql_native)
        if ismember(in_datasource,mysql_native)
            try
                mysql(datasource,username,password);
            catch ME
                throwAsCaller(ME)
            end
            c=parallel.pool.Constant(@()mysql(datasource,username,password),@close);
            return;
        end
    end

    if~isempty(postgre_native)
        if ismember(in_datasource,postgre_native)
            try
                postgresql(datasource,username,password);
            catch ME
                throwAsCaller(ME)
            end
            c=parallel.pool.Constant(@()postgresql(datasource,username,password),@close);
            return;
        end
    end

    if~isempty(jdbc)
        if ismember(in_datasource,jdbc(:,1))

            jdbcinfo=database.internal.utilities.getJDBCDataSources();
            details=jdbcinfo.(1)(char(in_datasource));

            if isempty(char(details.JDBCDriverLocation))
                error(message('database:database:jdbcPathNonExistent'));
            end

            driverlocation=char(details.JDBCDriverLocation);

            if exist(driverlocation,'file')~=2
                error(message('database:database:jdbcPathNonExistent'));
            end

            try
                if strcmpi(details.Vendor,"Other")
                    database.jdbc.connection(datasource,username,password,'positional','Driver',details.Driver,'URL',details.URL,'Instance','','JDBCDriverLocation',driverlocation,'JDBCConnectionOptions',details.getConnectionOptionsAsStruct,'ErrorHandling','report');
                    attachFiles;
                    c=parallel.pool.Constant(@()database.jdbc.connection(datasource,username,password,'positional','Driver',details.Driver,'URL',details.URL,'Instance','','JDBCDriverLocation',driverlocation,'JDBCConnectionOptions',details.getConnectionOptionsAsStruct),@close);
                else
                    AuthType='Server';
                    DriverType='';
                    if strcmpi(details.Vendor,'Microsoft SQL Server')
                        AuthType=details.AuthType;
                    end
                    if strcmpi(details.Vendor,'Oracle')
                        DriverType=details.DriverType;
                    end
                    database.jdbc.connection(datasource,username,password,'namevalue','Vendor',details.Vendor,'Server',details.Server,'PortNumber',details.PortNumber,'AuthType',AuthType,'Instance',details.DatabaseName,'JDBCDriverLocation',driverlocation,'DriverType',DriverType,'JDBCConnectionOptions',details.getConnectionOptionsAsStruct,'ErrorHandling','report');
                    attachFiles;
                    c=parallel.pool.Constant(@()database.jdbc.connection(datasource,username,password,'namevalue','Vendor',details.Vendor,'Server',details.Server,'PortNumber',details.PortNumber,'AuthType',AuthType,'Instance',details.DatabaseName,'JDBCDriverLocation',driverlocation,'DriverType',DriverType,'JDBCConnectionOptions',details.getConnectionOptionsAsStruct),@close);
                end
            catch ME
                throwAsCaller(ME)
            end
            return;
        end
    end

    if ispc
        error(message('database:database:dataSourceNameNotFound'));
    else
        error(message('database:database:dataSourceNameNotFoundUnix'));
    end


    function attachFiles

        alreadyAttachedFiles=poolobj.AttachedFiles;
        if~ismember(char(driverlocation),alreadyAttachedFiles)
            addAttachedFiles(poolobj,{driverlocation});

        end
    end

end
