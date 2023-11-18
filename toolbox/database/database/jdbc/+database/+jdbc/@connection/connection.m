classdef(CaseInsensitiveProperties=true,Sealed=true)...
    connection<database.relational.connection&...
    matlab.mixin.CustomDisplay

    properties(Constant,Access='public')

        DEFAULT_LOGINTIMEOUT=0;


        DEFAULT_AUTOCOMMIT='on';


        DEFAULT_READONLY='off';


        DEFAULT_DRIVERTYPE='thin';

    end

    properties(SetAccess=private)

        DataSource='';


        UserName='';


        Driver='';


        URL='';

Message


        Type='JDBC Connection Object'
    end

    properties(Access=public)

        AutoCommit='';

        ReadOnly='';
    end

    properties(GetAccess=public,SetAccess=protected)

        Catalogs={};


        Schemas={};
    end

    properties(Access=protected)
        SupportsPreparedStatements=true;
        SupportsDynamicExcludeDuplicates=true;
        SupportsImportOptions=true;
        DefaultVariableNamingRule="modify";
    end

    properties(SetAccess=private)




        LoginTimeout=0;


        MaxDatabaseConnections=-1;


        DefaultCatalog='';


        DatabaseProductName='';


        DatabaseProductVersion='';


        DriverName='';


        DriverVersion='';

        ErrorHandling='';
    end

    properties(SetAccess=private,Hidden=true)



        Instance='';



        TimeOut=0;

    end

    properties(SetAccess=private,Hidden=true,Transient=true)

        Constructor=[];


        Handle=0;
    end

    methods

        function connection=set.AutoCommit(connection,newvalue)

            validateattributes(newvalue,{'char','string'},{'scalartext'});
            toggle=validatestring(newvalue,{'on','off'});

            switch toggle

            case 'on'
                connection.Constructor.setAutoCommit(true);%#ok<*MCSUP>

            case 'off'
                connection.Constructor.setAutoCommit(false);

            end

            checkval=connection.Constructor.getAutoCommit;
            if~strcmpi(toggle,checkval)

                wb=warning('off','backtrace');
                warning(message('database:database:nonConfiguredParameter','AutoCommit',connection.DatabaseProductName));
                warning(wb);
                connection.AutoCommit=database.jdbc.connection.DEFAULT_AUTOCOMMIT;

                return;
            end

            connection.AutoCommit=toggle;

        end

        function connection=set.ReadOnly(connection,newvalue)

            validateattributes(newvalue,{'char','string'},{'scalartext'});
            toggle=validatestring(newvalue,{'on','off'});

            switch toggle
            case 'on'
                connection.Constructor.setReadOnly(true);%#ok<*MCSUP>

            case 'off'
                connection.Constructor.setReadOnly(false);
            end

            checkval=connection.Constructor.isReadOnly;
            if(strcmpi('on',toggle)&&checkval~=true)||(strcmpi('off',toggle)&&checkval~=false)

                wb=warning('off','backtrace');
                warning(message('database:database:nonConfiguredParameter','ReadOnly',connection.DatabaseProductName));
                warning(wb);
                connection.ReadOnly=database.jdbc.connection.DEFAULT_READONLY;

                return;
            end

            connection.ReadOnly=toggle;

        end


    end

    methods(Hidden=true)

        function connection=connection(datasource,username,password,style,varargin)

            connection.ErrorHandling=setdbprefs('ErrorHandling');
            try
                if~isempty(find(cellfun(@(x)strcmpi(x,'ErrorHandling'),varargin),1))
                    if(strcmpi(varargin{find(cellfun(@(x)strcmpi(x,'ErrorHandling'),varargin),1)+1},'store')||...
                        strcmpi(varargin{find(cellfun(@(x)strcmpi(x,'ErrorHandling'),varargin),1)+1},'report'))
                        connection.ErrorHandling=varargin{find(cellfun(@(x)strcmpi(x,'ErrorHandling'),varargin),1)+1};
                    end
                end
            catch
            end

            p=inputParser;
            switch style

            case 'namevalue'

                p.addRequired('datasource',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
                p.addRequired('username',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
                p.addRequired('password',@(x)validateattributes(x,{'char','string'},{'scalartext'}));

                p.addParameter('Driver','',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
                p.addParameter('URL','',@(x)validateattributes(x,{'char','string'},{'scalartext'}));

                p.addParameter('Vendor','',@database.internal.utilities.DatabaseUtils.vendorCheck);
                p.addParameter('Server','',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
                p.addParameter('DriverType','',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
                p.addParameter('PortNumber','',@(x)validateattributes(x,{'numeric'},{'nonempty','scalar','nonnegative'}));
                p.addParameter('AuthType','Server',@(x)strcmpi(x,'Server')||strcmpi(x,'Windows'));
                p.addParameter('AutoCommit',database.jdbc.connection.DEFAULT_AUTOCOMMIT,@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addParameter('LoginTimeout',database.jdbc.connection.DEFAULT_LOGINTIMEOUT,@(x)validateattributes(x,{'numeric'},{'nonempty','scalar','nonnegative'}))
                p.addParameter('ReadOnly',database.jdbc.connection.DEFAULT_READONLY,@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addParameter('ErrorHandling','',@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addParameter('Instance','',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
                p.addParameter('JDBCDriverLocation','',@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addParameter('JDBCConnectionOptions',[],@(x)validateattributes(x,{'struct'},{'scalar'}));
                p.addParameter('PasswordToken',false,@(x)validateattributes(x,{'logical'},{'scalar'}));

                try
                    p.parse(datasource,username,password,varargin{:});
                catch e
                    connection.Message=e.message;
                    database.internal.utilities.DatabaseUtils.errorhandling(connection.Message,connection.ErrorHandling);
                    return;
                end

                try
                    validatestring(p.Results.AutoCommit,["on","off"],"database","AutoCommit");
                    validatestring(p.Results.ReadOnly,["on","off"],"database","AutoCommit");
                catch ME
                    connection.Message=ME.message;
                    database.internal.utilities.DatabaseUtils.errorhandling(connection.Message,connection.ErrorHandling);
                    return;
                end

                datasource=char(p.Results.datasource);
                instance=char(p.Results.Instance);
                orig_instance=char(p.Results.Instance);

                username=char(p.Results.username);
                password=char(p.Results.password);

                logintimeout=p.Results.LoginTimeout;

                driver=char(p.Results.Driver);
                url=char(p.Results.URL);
                vendor=char(p.Results.Vendor);
                drivertype=char(p.Results.DriverType);
                authtype=char(p.Results.AuthType);

                driverloc=char(p.Results.JDBCDriverLocation);
                connectOpts=p.Results.JDBCConnectionOptions;

                tokenUsed=p.Results.PasswordToken;

                server=char(p.Results.Server);
                if isempty(server)
                    server='localhost';
                end

                if any(strcmpi(vendor,{'postgresql','oracle'}))
                    if isempty(instance)
                        instance=datasource;
                    end
                end

                portnumber=p.Results.PortNumber;

                if strcmpi(vendor,'Oracle')
                    if~isempty(drivertype)
                        drivertype=validatestring(drivertype,{'thin','oci'});
                    else
                        drivertype=database.jdbc.connection.DEFAULT_DRIVERTYPE;
                    end
                end

                if(isempty(driver)&&isempty(vendor))
                    m=message('database:database:requiredInput');
                    connection.Message=m.getString;
                    database.internal.utilities.DatabaseUtils.errorhandling(connection.Message,connection.ErrorHandling);
                    return;
                end


                if(isempty(vendor)&&~isempty(driver)&&isempty(url))%#ok<*PROP>
                    m=message('database:database:missingURL');
                    connection.Message=m.getString;
                    database.internal.utilities.DatabaseUtils.errorhandling(connection.Message,connection.ErrorHandling);
                    return;
                end

                if(~isempty(driver)&&~isempty(url))


                    connection=database.jdbc.connection(datasource,username,password,'positional','Driver',driver,'URL',url,'ReadOnly',char(p.Results.ReadOnly),'AutoCommit',char(p.Results.AutoCommit),'LoginTimeout',logintimeout,'Instance',instance,'ErrorHandling',connection.ErrorHandling,'PasswordToken',tokenUsed);
                    return;

                else

                    if(~strcmpi(vendor,'Microsoft SQL Server')&&strcmpi(authtype,'Windows'))
                        warning(message('database:database:ignoreParameter','AuthType','Microsoft SQL Server'));
                        authtype='Server';
                    end


                    if(~strcmpi(vendor,'Oracle')&&~isempty(drivertype))
                        warning(message('database:database:ignoreParameter','DriverType','Oracle'));
                        drivertype='';
                    end

                    driver=database.internal.utilities.DatabaseUtils.mapVendorToDriverURL(vendor);

                    switch(lower(vendor))

                    case{'mysql'}

                        if isempty(portnumber)
                            portnumber=3306;
                        end

                    case{'microsoft sql server'}

                        if isempty(portnumber)
                            portnumber=1433;
                        end

                    case{'oracle'}

                        if isempty(portnumber)
                            portnumber=1521;
                        end

                    case{'postgresql'}

                        if isempty(portnumber)
                            portnumber=5432;
                        end

                    end

                    url=eval(database.internal.utilities.DatabaseUtils.getDatabaseURL(vendor));
                    if strcmpi(vendor,'Microsoft SQL Server')&&strcmpi(authtype,'Windows')
                        url=strcat(url,'integratedSecurity=true;');
                    end
                    url=char(url);

                    if~isempty(driverloc)
                        if strcmpi(vendor,'MySQL')
                            if exist(driverloc,'file')~=2
                                error(message('database:database:jdbcPathNonExistent'));
                            end
                            if exist('com.mysql.cj.jdbc.Driver','class')~=8&&exist(driver,'class')~=8
                                javaaddpath(driverloc);
                            end

                        else
                            database.internal.utilities.addJDBCDriverOnPath(driver,driverloc);
                        end
                    end

                    if strcmpi(vendor,'MySQL')
                        if exist('com.mysql.cj.jdbc.Driver','class')==8
                            driver='com.mysql.cj.jdbc.Driver';
                        end
                    end

                    if isempty(instance)
                        instance=datasource;
                    end


                    props=java.util.Properties;
                    if~isempty(connectOpts)
                        fields=fieldnames(connectOpts);
                        for i=1:numel(fields)
                            props.put(fields{i},connectOpts.(fields{i}));
                        end
                    end

                    connection.LoginTimeout=com.mathworks.toolbox.database.DatabaseConnection.connectionTimeOut(driver,logintimeout);
                    connection.TimeOut=connection.LoginTimeout;
                    if isempty(orig_instance)
                        connection.Constructor=com.mathworks.toolbox.database.DatabaseConnection('',username,password,driver,url,props,'',tokenUsed);
                    else
                        connection.Constructor=com.mathworks.toolbox.database.DatabaseConnection(instance,username,password,driver,url,props,'',tokenUsed);
                    end
                    connection.Driver=driver;
                end



            case 'positional'

                p.addRequired('datasource',@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addRequired('username',@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addRequired('password',@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addParameter('Driver','',@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addParameter('URL','',@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addParameter('AutoCommit',database.jdbc.connection.DEFAULT_AUTOCOMMIT,@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addParameter('LoginTimeout',database.jdbc.connection.DEFAULT_LOGINTIMEOUT,@(x)validateattributes(x,{'numeric'},{'nonempty','scalar','nonnegative'}))
                p.addParameter('ReadOnly',database.jdbc.connection.DEFAULT_READONLY,@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addParameter('ErrorHandling','',@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addParameter('Instance','',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
                p.addParameter('JDBCDriverLocation','',@(x)validateattributes(x,{'char','string'},{'scalartext'}))
                p.addParameter('JDBCConnectionOptions',[],@(x)validateattributes(x,{'struct'},{'scalar'}));
                p.addParameter('PasswordToken',false,@(x)validateattributes(x,{'logical'},{'scalar'}));

                try
                    p.parse(datasource,username,password,varargin{:});
                catch e
                    database.internal.utilities.DatabaseUtils.errorhandling(e.message,connection.ErrorHandling);
                    return;
                end

                try
                    validatestring(p.Results.AutoCommit,["on","off"],"database","AutoCommit");
                    validatestring(p.Results.ReadOnly,["on","off"],"database","AutoCommit");
                catch ME
                    connection.Message=ME.message;
                    database.internal.utilities.DatabaseUtils.errorhandling(connection.Message,connection.ErrorHandling);
                    return;
                end

                datasource=char(p.Results.datasource);
                instance=char(p.Results.Instance);
                orig_instance=char(p.Results.Instance);
                connectOpts=p.Results.JDBCConnectionOptions;
                if isempty(instance)
                    instance=datasource;
                end

                if~isempty(char(p.Results.JDBCDriverLocation))
                    database.internal.utilities.addJDBCDriverOnPath(p.Results.Driver,char(p.Results.JDBCDriverLocation));
                end

                props=java.util.Properties;
                if~isempty(connectOpts)
                    fields=fieldnames(connectOpts);
                    for i=1:numel(fields)
                        props.put(fields{i},connectOpts.(fields{i}));
                    end
                end

                connection.LoginTimeout=com.mathworks.toolbox.database.DatabaseConnection.connectionTimeOut(char(p.Results.Driver),p.Results.LoginTimeout);
                connection.TimeOut=connection.LoginTimeout;
                if isempty(orig_instance)
                    connection.Constructor=com.mathworks.toolbox.database.DatabaseConnection('',char(p.Results.username),char(p.Results.password),char(p.Results.Driver),char(p.Results.URL),props,'',p.Results.PasswordToken);
                else
                    connection.Constructor=com.mathworks.toolbox.database.DatabaseConnection(instance,char(p.Results.username),char(p.Results.password),char(p.Results.Driver),char(p.Results.URL),props,'',p.Results.PasswordToken);
                end
                connection.Driver=char(p.Results.Driver);

            otherwise

                m=message('database:database:invalidNumInputs');
                connection.Message=m.getString;
                return;

            end

            errors=connection.Constructor.getConnectionErrorMessage;

            if isempty(errors)

                connection.Instance=char(p.Results.Instance);
                connection.DataSource=char(p.Results.datasource);
                if isempty(connection.Instance)
                    connection.Instance=connection.DataSource;
                end
                connection.UserName=char(p.Results.username);

                connection.Handle=connection.Constructor.getDatabaseConnection();

                dbmetadata=com.mathworks.toolbox.database.DatabaseDMD(connection.Constructor.getDatabaseConnection());

                connection.URL=dbmetadata.dmdURL();
                connection.MaxDatabaseConnections=dbmetadata.dmdMaxConnections();


                connection.DatabaseProductName=dbmetadata.dmdDatabaseProductName();
                connection.DatabaseProductVersion=dbmetadata.dmdDatabaseProductVersion();
                connection.DriverName=dbmetadata.dmdDriverName();
                connection.DriverVersion=dbmetadata.dmdDriverVersion();


                defcatalog=connection.Constructor.getCatalog();
                if isempty(defcatalog)
                    connection.DefaultCatalog='';
                else
                    connection.DefaultCatalog=defcatalog;
                end

                catalogs=dbmetadata.dmdCatalogs(1)';
                if~isempty(catalogs)
                    connection.Catalogs=catalogs;
                end

                schemas=dbmetadata.dmdSchemas(1)';
                if~isempty(schemas)
                    connection.Schemas=schemas;
                end

                connection.AutoCommit=char(p.Results.AutoCommit);
                connection.ReadOnly=char(p.Results.ReadOnly);

                if connection.LoginTimeout~=p.Results.LoginTimeout
                    wb=warning('off','backtrace');
                    warning(message('database:database:nonConfiguredParameter','LoginTimeout',connection.DatabaseProductName));
                    warning(wb);
                    connection.LoginTimeout=database.jdbc.connection.DEFAULT_LOGINTIMEOUT;
                    connection.TimeOut=connection.LoginTimeout;
                end

            else

                connection.Constructor=[];
                connection.Driver='';
                connection.LoginTimeout=database.jdbc.connection.DEFAULT_LOGINTIMEOUT;
                connection.TimeOut=database.jdbc.connection.DEFAULT_LOGINTIMEOUT;

                m=message('database:database:JDBCDriverError',errors);
                connection.Message=m.getString;
                database.internal.utilities.DatabaseUtils.errorhandling(connection.Message,connection.ErrorHandling);

            end

        end

    end

    methods(Access=protected)
        function identifier=getIdentifier(connect)
            dHandle=com.mathworks.toolbox.database.DatabaseDMD(connect.Constructor.getDatabaseConnection());
            identifier=dHandle.dmdIdentifierQuoteString();
        end
    end

    methods(Access=public)
        results=runsqlscript(connect,sqlfilename,varargin);
        x=runstoredprocedure(c,spcall,inarg,typeout);
        update(connect,tableName,fieldNames,data,whereClause);
        results=executeSQLScript(conn,sqlfilename,varargin);
    end

    methods(Access='protected')

        displayScalarObject(conn);
        closeHook(conn);
        x=isopenHook(conn);
        commitHook(conn);
        rollbackHook(conn);
        executeHook(conn,sqlquery);
        [data,metadata]=fetchHook(conn,second_input,optsObject,isDynamicQuery,dynamicQuery,maxRows,preserveNames,dataReturnFormat);
        [data,metadata]=sqlreadHook(connect,query,optsObject,maxRows,preservenames,isVarNameRuleSpecified);
        data=sqlfindHook(conn,pattern,catalog,schema,findcolumns);
        sqlwriteHook(conn,tablename,data,columnnames,newTableCreated);
        T=sqlinnerjoinHook(connect,query,maxRows,preservenames);
        T=sqlouterjoinHook(connect,query,maxRows,preservenames);
    end

    methods(Access=public,Hidden=true)

        p=ping(connect);
        datainsert(connect,tableName,fieldNames,data);
        fastinsert(connect,tableName,fieldNames,data);
        insert(connect,tableName,fieldNames,data);
        p=columns(connect,c,s,t);
        t=tables(conn,c,s,x);
        curs=exec(connect,sqlQuery,varargin);

    end

    methods(Hidden=true)

        function delete(obj)
            close(obj);
        end

        function p=getColumns(connect,varargin)












            p=inputParser;
            p.addRequired("connect",@(x)validateattributes(x,"database.jdbc.connection",{"scalar"}));
            p.addOptional("catalog","",@(x)validateattributes(x,["char","string"],{"scalartext"}));
            p.addOptional("schema","",@(x)validateattributes(x,["char","string"],{"scalartext"}));
            p.addOptional("table","",@(x)validateattributes(x,["char","string"],{"scalartext"}));

            try
                parse(p,connect,varargin{:});
            catch e
                rethrow(e);
            end


            if~isopen(connect)
                error(message("database:database:invalidConnection"))
            end

            catalog=p.Results.catalog;
            schema=p.Results.schema;
            table=p.Results.table;

            if(isstring(catalog)&&catalog.strlength==0)||(ischar(catalog)&&isempty(catalog))
                catalog=[];
            end

            if(isstring(schema)&&schema.strlength==0)||(ischar(schema)&&isempty(schema))
                schema=[];
            end

            if(isstring(table)&&table.strlength==0)||(ischar(table)&&isempty(table))
                table=[];
            end


            dobj=com.mathworks.toolbox.database.DatabaseDMD(connect.Constructor.getDatabaseConnection());

            ncols=14;
            tmp=dobj.dmdColumns(catalog,schema,table,[]);


            if~(tmp.size)
                p=[];
                return
            end


            y=system_dependent(44,tmp,tmp.size/ncols)';
            z=unique(y(:,3));
            x=cell(length(z),2);


            for i=1:length(z)
                j=strcmp(y(:,3),z(i));
                x{i,1}=z{i};
                x{i,2}=y(j,4)';
            end


            if nargin==4&&~isempty(table)
                j=strcmpi(x(:,1),table);
                try
                    p=x{j,2};
                catch
                    error(message('database:dmd:invalidTable'))
                end
            else
                p=x;
            end
        end
    end
end
