function connection=hodbc(varargin)




















































    try

        if(mod((length(varargin)),2)==0)
            error(message('database:database:invalidNumInputs'));
        end

        if nargin==1
            p=inputParser;
            p.addRequired("dsnless",@(x)validateattributes(x,["char","string"],{'scalartext'},"odbc","dsnless"));
            p.parse(varargin{:});

            connection=database.odbc.connection(p.Results.dsnless,'','','DSNLessConnection',true);
            logInfo(connection);
            return;
        end

        in_datasource=varargin{1};
        dataSources=listDataSources();
        odbc=dataSources.Name(dataSources.DriverType=="ODBC");

        if~isempty(odbc)
            if ismember(in_datasource,odbc)
                checkInputs(varargin{:});
                connection=database.odbc.connection(varargin{:});
                logInfo(connection);
                return;
            end
        end

        if ispc
            error(message('database:odbc:dataSourceNameNotFoundWindows'));
        else
            error(message('database:odbc:dataSourceNameNotFoundUnix'));
        end

    catch ME
        throwAsCaller(ME)
    end

end



function checkInputs(varargin)

    p=inputParser;
    p.addRequired('datasource',@(x)validateattributes(x,["char","string"],{'scalartext'}));
    p.addRequired('username',@(x)validateattributes(x,["char","string"],{'scalartext'}));
    p.addRequired('password',@(x)validateattributes(x,["char","string"],{'scalartext'}));
    p.addParameter('AutoCommit',database.jdbc.connection.DEFAULT_AUTOCOMMIT,@(x)validateattributes(x,["char","string"],{'scalartext'},"odbc","AutoCommit"))
    p.addParameter('ReadOnly',database.jdbc.connection.DEFAULT_AUTOCOMMIT,@(x)validateattributes(x,["char","string"],{'scalartext'},"odbc","ReadOnly"))
    p.addParameter('LoginTimeout',database.jdbc.connection.DEFAULT_AUTOCOMMIT,@(x)validateattributes(x,"numeric",{'nonempty','scalar','nonnegative'},"odbc","LoginTimeout"))

    p.parse(varargin{:});

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
