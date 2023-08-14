classdef sqlite<database.relational.connection


















    properties(SetAccess='protected')
        Database char
        IsReadOnly logical
    end

    properties(SetAccess='public')
        AutoCommit='on';
    end

    properties(GetAccess='public',SetAccess='private',Hidden=true)
        IsOpen logical
    end

    properties(GetAccess='public',SetAccess='protected',Hidden=true)
        Catalogs={};
        Schemas={};
        DatabaseProductName="sqlite";
    end

    properties(Access='private',Hidden=true)
Connection
    end

    properties(Access=protected)
        SupportsPreparedStatements=false;
        SupportsDynamicExcludeDuplicates=true;
        SupportsImportOptions=false;
        DefaultVariableNamingRule="preserve";
    end

    methods

        function set.AutoCommit(connect,flag)






            validateattributes("flag",["string","char"],"scalartext");
            flag=char(validatestring(flag,["on","off"]));
            if strcmpi(flag,'on')
                connect.Connection.AutoTransactionsEnabled=true;%#ok<*MCSUP> 
                connect.AutoCommit=flag;
            else
                connect.Connection.AutoTransactionsEnabled=false;
                connect.AutoCommit=flag;
            end
        end
    end

    methods(Hidden=true)

        function delete(s)




            s.Connection.disconnect;
        end

    end

    methods(Access=protected)
        function identifier=getIdentifier(~)
            identifier="""";
        end
    end

    methods(Access='public')

        function s=sqlite(filename,varargin)

            p=inputParser;

            try
                p.addRequired('filename',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
                p.addOptional('connmode','connect',@(x)validateattributes(x,{'char','string'},{'scalartext'}));

                p.parse(filename,varargin{:});

                connmode=validatestring(char(p.Results.connmode),{'create','connect','readonly'});

            catch e
                rethrow(e)
            end

            filename=char(p.Results.filename);
            connmode=char(connmode);

            s.Connection=matlab.depfun.internal.database.SqlDbConnector;
            s.IsOpen=false;
            s.IsReadOnly=false;


            switch lower(connmode)

            case 'create'

                if~exist(filename,'file')
                    try
                        s.Connection.createDatabase(filename);
                    catch e
                        error(message('database:sqlite:interfaceError',e.message));
                    end
                else
                    error(message('database:sqlite:fileExists'))
                end

            case 'connect'

                if exist(filename,'file')
                    try
                        s.Connection.connect(filename);
                    catch e
                        error(message('database:sqlite:interfaceError',e.message))
                    end
                else
                    error(message('database:sqlite:invalidFile'))
                end

            case 'readonly'

                if exist(filename,'file')
                    try
                        s.Connection.connectReadOnly(filename);
                        s.IsReadOnly=true;
                    catch e
                        error(message('database:sqlite:interfaceError',e.message));
                    end
                else
                    error(message('database:sqlite:invalidFile'));
                end

            otherwise

                error(message('database:sqlite:invalidMode',connmode))

            end

            s.Database=filename;
            s.IsOpen=true;


        end

        function exec(connect,sqlquery)









            p=inputParser;

            p.addRequired('s',@(x)validateattributes(x,{'sqlite'},{'scalar'}));
            p.addRequired('sqlquery',@(x)validateattributes(x,{'char','string'},{'scalartext'}));

            p.parse(connect,sqlquery);

            sqlquery=char(sqlquery);
            validateattributes(sqlquery,{'char'},{'nonempty'},'','sqlquery');

            if~connect.IsOpen
                error(message('database:sqlite:invalidConnection'))
            end

            try
                if strcmpi(connect.AutoCommit,"on")

                    connect.Connection.doSql(sqlquery,true)
                else


                    connect.Connection.doSql(sqlquery,false)
                end
            catch e
                try






                    if strcmpi(connect.AutoCommit,"on")
                        connect.Connection.rollbackTransaction('');
                    end
                catch
                end
                error(message("database:sqlite:interfaceError",e.message))
            end

        end

        function insert(connect,tableName,fieldNames,data)











            narginchk(4,4);

            p=inputParser;

            try
                p.addRequired('connect',@(x)validateattributes(x,{'sqlite'},{'scalar'}));
                p.addRequired('tableName',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
                p.addRequired('fieldNames',@database.internal.utilities.DatabaseUtils.fieldnamesCheck);
                p.addRequired('data',@(x)validateattributes(x,{'double','int64','int32','struct','table','cell'},{'nonempty'}));

                p.parse(connect,tableName,fieldNames,data);

            catch e
                rethrow(e)
            end

            connect=p.Results.connect;
            tableName=char(p.Results.tableName);
            validateattributes(tableName,{'char'},{'nonempty'},'','tableName');

            fieldNames=cellstr(p.Results.fieldNames);

            if connect.IsOpen==false
                error(message('database:sqlite:invalidConnection'))
            end

            switch class(data)

            case 'cell'

                numCols=size(data,2);


                if(numCols~=length(fieldNames))
                    error(message('database:sqlite:insertDimensionMismatch'))
                end

                inputArgs=cell(1,numCols*2);

                for i=1:numCols
                    inputArgs{i*2-1}=fieldNames{i};
                    if isnumeric(data{1,i})
                        inputArgs{i*2}=[data{:,i}]';
                    else
                        inputArgs{i*2}=data(:,i);
                    end
                end

            case{'double','int32','int64'}

                numCols=size(data,2);

                if(numCols~=length(fieldNames))
                    error(message('database:sqlite:insertDimensionMismatch'))
                end

                inputArgs=cell(1,numCols*2);

                for i=1:numCols
                    inputArgs{i*2-1}=fieldNames{i};
                    inputArgs{i*2}=data(:,i);
                end

            case 'struct'

                f=fieldnames(data);
                xFields=setdiff(f,fieldNames);
                if isempty(xFields)
                    xFields=setdiff(fieldNames,f);
                end
                if~isempty(xFields)
                    fieldStr=[];
                    for i=1:length(xFields)
                        fieldStr=[fieldStr,' ',xFields{i}];%#ok
                    end
                    error(message('database:sqlite:insertFieldMismatch',fieldStr))
                end
                numCols=length(f);
                inputArgs=cell(1,numCols*2);


                for i=1:numCols
                    inputArgs{i*2-1}=f{i};
                    inputArgs{i*2}=data.(f{i});
                end

            case 'table'

                f=data.Properties.VariableNames;
                xFields=setdiff(f,fieldNames);
                if isempty(xFields)
                    xFields=setdiff(fieldNames,f);
                end
                if~isempty(xFields)
                    fieldStr=[];
                    for i=1:length(xFields)
                        fieldStr=[fieldStr,' ',xFields{i}];%#ok
                    end
                    error(message('database:sqlite:insertFieldMismatch',fieldStr))
                end
                numCols=width(data);
                inputArgs=cell(1,numCols*2);
                for i=1:length(f)
                    inputArgs{i*2-1}=f{i};
                    inputArgs{i*2}=data.(f{i});
                end

            otherwise

                error(message('database:sqlite:invalidWriteDataType'))

            end





            try
                if strcmpi(connect.AutoCommit,"off")
                    connect.Connection.beginTransaction('');
                end
            catch
            end

            try
                connect.Connection.insertUsingPreparedStatement(tableName,inputArgs{:})
            catch e
                error(message('database:sqlite:interfaceError',e.message))
            end

        end
    end

    methods(Access=protected)
        function closeHook(connect)
            if~connect.IsOpen
                return;
            end
            connect.Connection.disconnect;
            connect.IsOpen=false;
        end

        function open=isopenHook(connect)
            open=connect.IsOpen;
        end

        function commitHook(connect)
            try
                connect.Connection.commitTransaction('');
            catch e
                try


                    connect.Connection.doSql('COMMIT TRANSACTION')
                catch
                    error(message('database:sqlite:interfaceError',e.message))
                end
            end
        end

        function rollbackHook(connect)
            try
                connect.Connection.rollbackTransaction('');
            catch e
                try


                    connect.Connection.doSql('ROLLBACK TRANSACTION')
                catch
                    error(message('database:sqlite:interfaceError',e.message))
                end
            end
        end

        function executeHook(connect,sqlquery)
            sqlquery=char(sqlquery);
            try
                if strcmpi(connect.AutoCommit,"on")

                    connect.Connection.doSql(sqlquery,true)
                else


                    connect.Connection.doSql(sqlquery,false)
                end
            catch e
                try






                    if strcmpi(connect.AutoCommit,"on")
                        connect.Connection.rollbackTransaction('');
                    end
                catch
                end
                error(message("database:sqlite:interfaceError",e.message))
            end
        end

        function T=sqlfindHook(connect,pattern,~,~,findcolumns)
            T=table([],[],[],[],[],'VariableNames',{'Catalog','Schema','Table','Columns','Type'});


            tablenames=string(connect.Connection.getTableNames()');

            if isempty(tablenames)
                return;
            end

            if pattern.strlength>0

                pattern=extractBetween(pattern,2,strlength(pattern)-1);
                tablenames=tablenames(contains(tablenames,pattern));
            end

            if isempty(tablenames)
                return;
            end

            T=table(repmat("",[numel(tablenames),1]),...
            repmat("",[numel(tablenames),1]),...
            tablenames,...
            repmat("",[numel(tablenames),1]),...
            repmat("",[numel(tablenames),1]),...
            'VariableNames',...
            {'Catalog','Schema','Table','Columns','Type'});

            if~findcolumns
                return;
            end

            for i=1:numel(tablenames)
                columns{i}=string(connect.Connection.getTableColumnNames(char(tablenames(i))));
            end

            T.Columns=columns';
        end

        function T=fetchHook(connect,sqlquery,~,~,~,rowlimit,varnamerule,returnType)

            try


                connect.Connection.doSql(char(sqlquery),true);
            catch e
                error(message('database:sqlite:interfaceError',e.message));
            end

            colnames=connect.Connection.getColumnNames();
            if strcmpi(varnamerule,"modify")
                colnames=database.internal.utilities.makeValidVariableNames(colnames);
            end

            colnames=matlab.lang.makeUniqueStrings(colnames,{},namelengthmax);


            data=connect.Connection.fetchRows(rowlimit);
            if isempty(data)
                if returnType=="table"
                    T=cell2table(cell(0,numel(colnames)),'VariableNames',colnames);
                else
                    T=[];
                end
                return;
            end

            rows=size(data,2);
            cols=size(data{1},2);
            data=reshape([data{:}],cols,rows)';

            if returnType=="cellarray"
                T=data;
                return;
            end

            T=cell2table(data,'VariableNames',colnames);

            for i=1:width(T)
                if iscellstr(T.(i))%#ok<*ISCLSTR> 
                    T.(i)(cellfun('isempty',T.(i)))={missing};
                    T.(i)=string(T.(i));
                end
            end

            if returnType=="structure"
                T=table2struct(T,"ToScalar",true);
                return;
            end
        end

        function T=sqlreadHook(connect,sqlquery,~,maxrows,varnamerule,~)
            T=fetch(connect,sqlquery,"MaxRows",maxrows,"VariableNamingRule",varnamerule);
        end

        function sqlwriteHook(connect,tablename,data,columnnames,newTableCreated)


            querybuilder=database.internal.utilities.SQLQueryBuilder;
            testquery=querybuilder.select("*").from(tablename).SQLQuery;
            execute(connect,testquery);

            coltypes=connect.Connection.getColumnTypeNames();
            transformedTable=database.internal.utilities.TypeMapper.dataTypeConverter(connect,coltypes,data);

            numcols=width(data);

            dataToInsert=cell(1,numcols*2);

            for i=1:numcols
                dataToInsert{i*2-1}=char(columnnames{i});
                dataToInsert{i*2}=transformedTable.(i);
            end





            try
                if strcmpi(connect.AutoCommit,"off")
                    connect.Connection.beginTransaction('');
                end
            catch
            end

            try
                connect.Connection.insertUsingPreparedStatement(char(tablename),dataToInsert{:})
            catch e
                if newTableCreated
                    try
                        execute(connect,['DROP TABLE ',char(tablename)]);
                    catch
                    end
                end
                error(message('database:sqlite:interfaceError',e.message))
            end
        end
    end


end
