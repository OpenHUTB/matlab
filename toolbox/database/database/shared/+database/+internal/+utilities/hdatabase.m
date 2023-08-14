function connection=hdatabase(varargin)

























































    try

        if(mod((length(varargin)),2)==0)
            error(message('database:database:invalidNumInputs'));
        end

        if nargin==1
            p=inputParser;
            p.addRequired("dsnless",@(x)validateattributes(x,["char","string"],{"scalartext"},"database","dsnless"));
            p.parse(varargin{:});

            connection=database.odbc.connection(p.Results.dsnless,'','','DSNLessConnection',true);
            logInfo(connection);
            return;
        end

        if isnumeric(varargin{2})&&isempty(varargin{2})
            varargin{2}='';
        end

        if isnumeric(varargin{3})&&isempty(varargin{3})
            varargin{3}='';
        end

        in_datasource=varargin{1};
        database.internal.utilities.repairOldJDBCDataSources;
        dataSources=listDataSources();
        odbc=dataSources.Name(dataSources.DriverType=="ODBC");
        jdbc=dataSources.Name(dataSources.DriverType=="JDBC");

        if~isempty(odbc)




            if any(strcmpi(in_datasource,odbc))

                checkInputs(varargin{:});
                connection=database.odbc.connection(varargin{:});
                logInfo(connection);
                return;
            end
        end

        if~isempty(jdbc)
            if any(strcmpi(in_datasource,jdbc))
                checkInputs(varargin{:});
                connection=database.internal.utilities.connectJDBCDataSource(varargin{:});
                logInfo(connection);
                return;
            end
        end

        if nargin==3||...
            nargin==5&&strcmpi(varargin{4},'ErrorHandling')
            if ispc
                error(message('database:database:dataSourceNameNotFound'));
            else
                error(message('database:database:dataSourceNameNotFoundUnix'));
            end
        end

        if(iscellstr({varargin{1:5}})||any(cellfun(@isstring,varargin(1:5))))&&~any(ismember(cellstr({varargin{1:5}}),{'DriverType','Vendor','Server','PortNumber','AuthType','Driver','URL','AutoCommit','ReadOnly','LoginTimeout','ErrorHandling'}))
            if nargin==5
                connection=database.jdbc.connection(varargin{1},varargin{2},varargin{3},'positional','Instance',varargin{1},'Driver',varargin{4},'URL',varargin{5});
            else
                connection=database.jdbc.connection(varargin{1},varargin{2},varargin{3},'positional','Instance',varargin{1},'Driver',varargin{4},'URL',varargin{5},varargin{6:end});
            end
            logInfo(connection);
            return;
        else
            if~any(ismember(cellstr({varargin{4:2:end}}),{'Vendor','DriverType','Server','PortNumber','AuthType','Driver','URL'}))
                if ispc
                    error(message('database:database:dataSourceNameNotFound'));
                else
                    error(message('database:database:dataSourceNameNotFoundUnix'));
                end
            end
            connection=database.jdbc.connection(varargin{1},varargin{2},varargin{3},'namevalue','Instance',varargin{1},varargin{4:end});
            logInfo(connection);
            return;
        end




    catch ME
        throwAsCaller(ME)
    end

end



function checkInputs(varargin)

    p=inputParser;
    p.addRequired('datasource',@(x)validateattributes(x,["char","string"],{"scalartext"}));
    p.addRequired('username',@(x)validateattributes(x,["char","string"],{"scalartext"}));
    p.addRequired('password',@(x)validateattributes(x,["char","string"],{"scalartext"}));
    p.addParameter('AutoCommit',database.jdbc.connection.DEFAULT_AUTOCOMMIT,@(x)validateattributes(x,["char","string"],{"scalartext"},"database","AutoCommit"))
    p.addParameter('ReadOnly',database.jdbc.connection.DEFAULT_AUTOCOMMIT,@(x)validateattributes(x,["char","string"],{"scalartext"},"database","ReadOnly"))
    p.addParameter('LoginTimeout',database.jdbc.connection.DEFAULT_AUTOCOMMIT,@(x)validateattributes(x,"numeric",{"nonempty","scalar","nonnegative"},"database","LoginTimeout"))
    p.addParameter('ErrorHandling',setdbprefs('ErrorHandling'),@(x)validateattributes(x,["char","string"],{"scalartext"},"database","ErrorHandling"));

    try
        p.parse(varargin{:});
    catch ME
        switch ME.identifier
        case{'MATLAB:InputParser:UnmatchedParameter'}
            if any(ismember(cellstr({varargin{4:2:end}}),{'Vendor','DriverType','Server','PortNumber','AuthType','Driver','URL'}))
                error(message('database:database:invalidParameterVerbose',varargin{1}));
            else
                error(message('database:database:invalidParameter'));
            end

        otherwise
            rethrow(ME)
        end
    end

end


function logInfo(connection)



    persistent loggedNames

    name=string(connection.DatabaseProductName);
    if~any(strcmp(name,loggedNames))

        try
            logger=database.internal.DBDDUXLogger();
            status=logger.logDBProductName(name);
            if status==0
                loggedNames=[loggedNames;name];
            end
        catch

        end
    end
end



