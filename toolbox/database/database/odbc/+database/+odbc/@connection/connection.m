classdef(CaseInsensitiveProperties=true,Sealed=true)...
    connection<database.relational.connection&...
    matlab.mixin.CustomDisplay

    properties(Constant,Access='private')
        DEFAULT_LOGINTIMEOUT=0;
        DEFAULT_AUTOCOMMIT='on';
        DEFAULT_READONLY='off';
    end

    properties(SetAccess=private,GetAccess=public)

        DataSource='';
        UserName='';
Message
        Type='ODBC Connection Object'
    end


    properties(Access=public)
        AutoCommit='';
        ReadOnly='';
    end


    properties(SetAccess=protected)
        Catalogs={};
        Schemas={};
    end

    properties(SetAccess=private,GetAccess=public)
        LoginTimeout=0;
        MaxDatabaseConnections=-1;
        DefaultCatalog='';
        DatabaseProductName='';
        DatabaseProductVersion='';
        DriverName='';
        DriverVersion='';
    end


    properties(Access=protected)
        SupportsPreparedStatements=false;
        SupportsDynamicExcludeDuplicates=true;
        SupportsImportOptions=true;
        DefaultVariableNamingRule="modify";
    end

    properties(SetAccess=private,Hidden=true)
        Instance='';
        ErrorHandling='';
    end

    properties(SetAccess=private,Hidden=true,Transient=true)
        Handle=0;
    end

    properties(SetAccess=private,Hidden=true)
        TimeOut=0;
    end


    methods

        function connection=set.AutoCommit(connection,newvalue)

            validateattributes(newvalue,{'char','string'},{'scalartext'});
            toggle=validatestring(newvalue,{'on','off'});

            switch toggle
            case 'on'
                connection.Handle.setAutoCommit(1);%#ok<*MCSUP>

            case 'off'
                connection.Handle.setAutoCommit(0);
            end
            checkval=connection.Handle.getAutoCommit;
            if(strcmpi('on',toggle)&&checkval~=true)||(strcmpi('off',toggle)&&checkval~=false)
                wb=warning('off','backtrace');
                warning(message('database:database:nonConfiguredParameter','AutoCommit',connection.DatabaseProductName));
                connection.AutoCommit=database.odbc.connection.DEFAULT_AUTOCOMMIT;
                warning(wb);

                return;
            end

            connection.AutoCommit=toggle;

        end


        function connection=set.ReadOnly(connection,newvalue)

            validateattributes(newvalue,{'char','string'},{'scalartext'});
            toggle=validatestring(newvalue,{'on','off'});

            switch toggle
            case 'on'
                connection.Handle.setReadOnly(1);%#ok<*MCSUP>

            case 'off'
                connection.Handle.setReadOnly(0);
            end
            checkval=connection.Handle.isReadOnly();
            if(strcmpi('on',toggle)&&checkval~=1)||(strcmpi('off',toggle)&&checkval~=0)
                wb=warning('off','backtrace');
                warning(message('database:database:nonConfiguredParameter','ReadOnly',connection.DatabaseProductName));
                connection.ReadOnly=database.odbc.connection.DEFAULT_READONLY;
                warning(wb);

                return;
            end

            connection.ReadOnly=toggle;

        end

    end


    methods(Access=public,Hidden=true)

        p=ping(connect)
        insert(connect,tableName,fieldNames,data);
        fastinsert(connect,tableName,fieldNames,data);
        datainsert(connect,tableName,fieldNames,data);
        p=tables(connect,varargin);
        p=columns(connect,varargin);
        curs=exec(conn,sqlQuery,varargin);
    end


    methods(Hidden=true)
        function connectObj=connection(instance,username,password,varargin)

            narginchk(3,13);
            connectObj.ErrorHandling=setdbprefs('ErrorHandling');
            try
                if~isempty(find(cellfun(@(x)strcmpi(x,'ErrorHandling'),varargin),1))
                    if(strcmpi(varargin{find(cellfun(@(x)strcmpi(x,'ErrorHandling'),varargin),1)+1},'store')||...
                        strcmpi(varargin{find(cellfun(@(x)strcmpi(x,'ErrorHandling'),varargin),1)+1},'report'))
                        connectObj.ErrorHandling=varargin{find(cellfun(@(x)strcmpi(x,'ErrorHandling'),varargin),1)+1};
                    end
                end
            catch
            end

            p=inputParser;
            p.addRequired('instance',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.addRequired('username',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.addRequired('password',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('AutoCommit',database.odbc.connection.DEFAULT_AUTOCOMMIT,@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('ReadOnly',database.odbc.connection.DEFAULT_READONLY,@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter('LoginTimeout',database.odbc.connection.DEFAULT_LOGINTIMEOUT,@(x)validateattributes(x,{'numeric'},{'nonempty','scalar','nonnegative'}));
            p.addParameter('ErrorHandling','',@(x)validateattributes(x,{'char','string'},{'scalartext'}))
            p.addParameter('DSNLessConnection',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
            p.addParameter('ByPassUnixCheck',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
            p.addParameter('PasswordToken',false,@(x)validateattributes(x,{'logical'},{'scalar'}));

            try
                p.parse(instance,username,password,varargin{:});
            catch e
                connectObj.Message=e.message;
                connectObj.Handle=0;
                database.internal.utilities.DatabaseUtils.errorhandling(connectObj.Message,connectObj.ErrorHandling);
                return;
            end

            try
                validatestring(p.Results.AutoCommit,["on","off"],"database","AutoCommit");
                validatestring(p.Results.ReadOnly,["on","off"],"database","AutoCommit");
            catch ME
                connectObj.Message=ME.message;
                connectObj.Handle=0;
                database.internal.utilities.DatabaseUtils.errorhandling(connectObj.Message,connectObj.ErrorHandling);
                return;
            end
            instance=char(p.Results.instance);
            username=char(p.Results.username);
            password=char(p.Results.password);
            autocommit=char(p.Results.AutoCommit);
            readonly=char(p.Results.ReadOnly);
            connHandle=database.internal.ODBCConnectHandle();
            try
                if p.Results.DSNLessConnection
                    connHandle.openDSNLessConnection(instance);
                elseif p.Results.PasswordToken
                    connHandle.openConnectionWithToken(instance,username,password,p.Results.LoginTimeout)
                else
                    connHandle.openConnection(instance,username,password,p.Results.LoginTimeout);
                end
                connectObj.Handle=connHandle;

                if p.Results.DSNLessConnection
                    connectObj.DataSource='';
                else
                    connectObj.DataSource=instance;
                end
                connectObj.Instance=instance;
                connectObj.UserName=username;
                connectObj.DefaultCatalog=connectObj.Handle.getCatalog();
                dbmetadata=connectObj.Handle.getDatabaseMetadata();

                t=dbmetadata.getCatalogs();
                t=cellstr(t)';

                if length(t)==1&&isempty(t{1})
                    connectObj.Catalogs={};
                else
                    connectObj.Catalogs=t;
                end

                t=dbmetadata.getSchemas();
                t=cellstr(t)';

                if length(t)==1&&isempty(t{1})
                    connectObj.Schemas={};
                else
                    connectObj.Schemas=t;
                end
                connectObj.AutoCommit=autocommit;
                connectObj.MaxDatabaseConnections=dbmetadata.getMaxConnections();
                connectObj.DatabaseProductName=dbmetadata.getDatabaseProductName();
                connectObj.DatabaseProductVersion=dbmetadata.getDatabaseProductVersion();
                connectObj.DriverName=dbmetadata.getDriverName();
                connectObj.DriverVersion=dbmetadata.getDriverVersion();
                timeout=connectObj.Handle.getLoginTimeout;
                if p.Results.LoginTimeout~=0&&(timeout~=p.Results.LoginTimeout)
                    wb=warning('off','backtrace');
                    warning(message('database:database:nonConfiguredParameter','LoginTimeout',connectObj.DatabaseProductName));
                    warning(wb);
                    connectObj.LoginTimeout=database.odbc.connection.DEFAULT_LOGINTIMEOUT;
                else
                    connectObj.LoginTimeout=timeout;
                end
                connectObj.TimeOut=connectObj.LoginTimeout;
                connectObj.ReadOnly=readonly;

            catch e
                connectObj.Message=e.message;
                database.internal.utilities.DatabaseUtils.errorhandling(connectObj.Message,connectObj.ErrorHandling);
                return;
            end

        end

    end


    methods(Hidden=true)
        function delete(obj)
            close(obj);
        end


        function p=getColumns(connect,varargin)

            p=inputParser;
            p.addRequired("connect",@(x)validateattributes(x,"database.odbc.connection",{"scalar"}));
            p.addOptional("catalog","",@(x)validateattributes(x,["char","string"],{"scalartext"}));
            p.addOptional("schema","",@(x)validateattributes(x,["char","string"],{"scalartext"}));
            p.addOptional("table","",@(x)validateattributes(x,["char","string"],{"scalartext"}));

            try
                parse(p,connect,varargin{:});
            catch e
                rethrow(e);
            end

            catalog=char(p.Results.catalog);
            schema=char(p.Results.schema);
            table=char(p.Results.table);

            if~isopen(connect)
                error(message('database:database:invalidConnection'))
            end

            try
                if nargin==1

                    p=[];
                    tab_list=sqlfind(connect,"","FindColumns",false);
                    if~isempty(tab_list)
                        for j=1:numel(tab_list.Table)
                            cols=getColumns(connect,'','',tab_list.Table{j});
                            if~isempty(cols)
                                info{1,1}=tab_list.Table{j};
                                info{1,2}=cols;
                                p=[p;info];
                            end
                        end
                    end

                elseif nargin==2

                    p=[];
                    tab_list=sqlfind(connect,"","Catalog",catalog,"FindColumns",false);
                    if~isempty(tab_list)
                        for j=1:numel(tab_list.Table)
                            cols=getColumns(connect,catalog,'',tab_list.Table{j});
                            if~isempty(cols)
                                info{1,1}=tab_list.Table{j};
                                info{1,2}=cols;
                                p=[p;info];
                            end
                        end
                    end

                elseif nargin==3

                    p=[];
                    tab_list=sqlfind(connect,"","Catalog",catalog,"Schema",schema,"FindColumns",false);
                    if~isempty(tab_list)
                        for j=1:numel(tab_list.Table)
                            cols=getColumns(connect,catalog,schema,tab_list.Table{j});
                            if~isempty(cols)
                                info{1,1}=tab_list.Table{j};
                                info{1,2}=cols;
                                p=[p;info];%#ok<*AGROW>
                            end
                        end
                    end

                elseif nargin==4

                    p=[];
                    dbmetadata=connect.Handle.getDatabaseMetadata;
                    cols=cellstr(dbmetadata.getColumns(catalog,schema,table,'%',4))';
                    if~isempty(cols)
                        p=cols;
                    end

                else

                    p=[];
                end

            catch e
                error(message('database:odbc:driverError',e.message))

            end
        end


        function curs=hexec(conn,sqlQuery,varargin)
            curs=database.odbc.cursor();
            p=inputParser;
            p.addRequired('conn',@(x)validateattributes(x,{'database.odbc.connection'},{'scalar'}));
            p.addRequired('sqlQuery',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.addOptional('qTimeOut',0,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'}));
            p.addOptional('cursorType','forward_only',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.addOptional('maxRows',0,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'}));

            try
                p.parse(conn,sqlQuery,varargin{:});
                cursortype=validatestring(p.Results.cursorType,{'forward_only','scrollable'});
            catch e

                if strcmpi(setdbprefs('ErrorHandling'),'report')

                    e.rethrow();
                end
                curs.Message=e.message;

                return;
            end

            if(~isempty(conn.Message))
                m=message('database:database:connectionFailure',conn.Message);

                if strcmpi(setdbprefs('ErrorHandling'),'report')
                    error(m);
                end

                curs.Message=m.getString();

                return;
            end

            try
                curs.SQLQuery=char(sqlQuery);

                connHandle=conn.Handle;
                stmtObj=connHandle.createStatement();
                curs.Statement=stmtObj;
                curs.DatabaseConnection=conn;

                if p.Results.maxRows>0
                    stmtObj.setMaxRows(p.Results.maxRows);
                end

                qtimeout=p.Results.qTimeOut;


                if nargin==3
                    qtimeout=varargin{1};
                end
                stmtObj.setQueryTimeout(qtimeout);
                stmtObj.setCursorType(upper(cursortype));

                if strcmpi(cursortype,'scrollable')
                    curs.Scrollable=true;
                end
                if(database.internal.utilities.isSingleDeleteQuery(curs.SQLQuery)||...
                    database.internal.utilities.isSingleInsertQuery(curs.SQLQuery)||...
                    database.internal.utilities.isSingleUpdateQuery(curs.SQLQuery))
                    curs.Resultset=stmtObj.executeQueryV3(curs.SQLQuery);

                else
                    curs.Resultset=stmtObj.executeQueryV2(curs.SQLQuery,conn.DatabaseProductName);
                end
                curs.ResultsetMetadata=curs.Resultset.getResultsetMetadata();

                stmtObj.setMaxRows(0);

            catch e

                if strcmpi(setdbprefs('ErrorHandling'),'report')

                    close(curs);
                    e.rethrow();
                end
                curs.Message=e.message;
                return;
            end
        end


        function OK=qtimeoutCheck(QTimeOut)

            if(~isnumeric(QTimeOut)||~isscalar(QTimeOut)||mod(QTimeOut,1)~=0)
                error(message('database:runsqlscript:inputParameterError','qTimeOut'))
            else
                OK=true;
            end
        end
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

    methods(Access='protected')
        function identifier=getIdentifier(connect)
            dHandle=connect.Handle.getDatabaseMetadata();
            identifier=dHandle.getIdentifierQuoteString();
        end
    end

end
