classdef connection<handle&matlab.mixin.CustomDisplay

    properties(Access=private)

CassandraHandle
    end

    properties(Access=private,Hidden,Constant)
        ConsistencyLevels=["ALL","ANY","EACH_QUORUM","LOCAL_ONE","LOCAL_QUORUM",...
        "LOCAL_SERIAL","ONE","QUORUM","SERIAL","THREE","TWO"];
    end

    properties(GetAccess=public,SetAccess=private)

        Cluster string
        HostAddresses string
        LocalDataCenter string
        RequestTimeout int32
    end


    properties(Dependent,SetAccess=private)
        Keyspaces string
    end

    properties(Hidden,GetAccess=public,SetAccess=private)
        CassandraVersion string
    end


    methods
        function this=connection(varargin)

            narginchk(3,inf);            [varargin{:}]=convertCharsToStrings(varargin{:});

            if nargin==3

                dataSource=varargin{1};
                validateattributes(dataSource,'string',{'scalartext'},'apacheCassandra','dataSource');
                username=varargin{2};
                validateattributes(username,'string',{'scalartext'},'apacheCassandra','username');
                password=varargin{3};
                validateattributes(password,'string',{'scalartext'},'apacheCassandra','password');

                database.internal.utilities.repairOldJDBCDataSources();

                if~ispref('DatabaseToolbox',database.options.SQLConnectionOptions.PREFERENCE_NAME)
                    error(message('database:database:dataSourceNameNotFound'))
                end
                currentConfigurations=getpref('DatabaseToolbox',database.options.SQLConnectionOptions.PREFERENCE_NAME);
                currentConfigurations=currentConfigurations(cellfun(@(x)x.Vendor=="Cassandra"&&x.CONNECTION_TYPE=="native",...
                currentConfigurations.DataSourceInformation),:);
                CassandraDataSourceNames=currentConfigurations.Properties.RowNames;

                if isempty(CassandraDataSourceNames)
                    error(message('database:cassandra:NoDataSources'));
                end

                str='';
                for i=1:numel(CassandraDataSourceNames)
                    if i==numel(CassandraDataSourceNames)
                        str=[str,'',sprintf('''%s'' ',CassandraDataSourceNames{i})];%#ok<AGROW>
                        break;
                    end
                    if mod(i,4)==0
                        str=[str,'',sprintf('''%s'',\n ',CassandraDataSourceNames{i})];%#ok<AGROW>
                    else
                        str=[str,'',sprintf('''%s'', ',CassandraDataSourceNames{i})];%#ok<AGROW>
                    end
                end

                if~any(strcmpi(dataSource,CassandraDataSourceNames))
                    error(message('database:configureJDBCDataSource:InvalidMatch',str,dataSource));
                end

                opts=databaseConnectionOptions(dataSource);

                contactPoints=opts.ContactPoints;
                contactPoints=strjoin(contactPoints,",");
                portNumber=opts.PortNumber;
                enableSSL=opts.SSLEnabled;
                loginTimeout=opts.LoginTimeout;
                this.RequestTimeout=opts.RequestTimeout;
            else

                p=inputParser;
                p.addRequired('username',@(x)validateattributes(x,{'string'},{'scalar'},'apacheCassandra','username'));
                p.addRequired('password',@(x)validateattributes(x,{'string'},{'scalar'},'apacheCassandra','password'));
                p.addParameter('ContactPoints',"localhost",@(x)validateattributes(x,{'string'},{'vector'},'apacheCassandra','ContactPoints'));
                p.addParameter('PortNumber',9042,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'},'apacheCassandra','PortNumber'));
                p.addParameter('SSLEnabled',false,@(x)validateattributes(x,{'logical'},{'scalar'},'apacheCassandra','SSLEnabled'));
                p.addParameter('LoginTimeout',5,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'},'apacheCassandra','LoginTimeout'));
                p.addParameter('RequestTimeout',12,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'},'apacheCassandra','RequestTimeout'));

                p.parse(varargin{:});
                username=p.Results.username;
                password=p.Results.password;
                contactPoints=p.Results.ContactPoints;
                contactPoints=strjoin(contactPoints,",");
                portNumber=p.Results.PortNumber;
                enableSSL=p.Results.SSLEnabled;
                loginTimeout=p.Results.LoginTimeout;
                this.RequestTimeout=p.Results.RequestTimeout;
            end
            this.CassandraHandle=apachecassandra.internal.Connection();
            this.CassandraHandle.openConnection(contactPoints,username,password,portNumber,enableSSL,loginTimeout*1000,this.RequestTimeout*1000);
           stmt=apachecassandra.internal.Statement();
            stmt.createStatement("SELECT rpc_address FROM system.local",0);
            stmt.setConsistency("ONE");
            localAddressResultset=this.CassandraHandle.fetch(stmt);
            localAddressResultset.parse();
            localAddress=string(fetchData(localAddressResultset,1));
            peerStmt=apachecassandra.internal.Statement();
            peerStmt.createStatement("SELECT peer FROM system.peers",0);
            peerStmt.setConsistency("ONE");
            peerStmt.setHost(localAddress,portNumber);
            peerAddressResultset=this.CassandraHandle.fetch(peerStmt);
            peerAddressResultset.parse();
            peerAddresses=string(fetchData(peerAddressResultset,1));
            this.HostAddresses=sort([localAddress;peerAddresses]);
            this.LocalDataCenter=this.CassandraHandle.getLocalDataCenter();
            this.Cluster=this.CassandraHandle.getClusterName();
            this.CassandraVersion=this.CassandraHandle.getCassandraVersion();
        end


        function delete(this)
            close(this)
        end


        function close(this)

            if isopen(this)
                close(this.CassandraHandle);
            end
        end


        function val=isopen(this)
            val=isvalid(this)&&isopen(this.CassandraHandle);
        end


        function keyspaces=get.Keyspaces(this)
            if~isopen(this)
                keyspaces="";
                return;
            end

            keyspaces=string(this.CassandraHandle.getKeyspaces());
        end


        function t=tablenames(this,keyspace)
            if~isopen(this)
                error(message('database:cassandra:InvalidCassandraConnection'));
            end

            if nargin==1
                t=table('Size',[0,2],'VariableTypes',{'string','string'},'VariableNames',{'Keyspace','Table'});
                for n=1:length(this.Keyspaces)
                    tablesInKeyspace=string(this.CassandraHandle.getTableNames(this.Keyspaces(n)));
                    keyspace=repmat(this.Keyspaces(n),length(tablesInKeyspace),1);
                    t=[t;table(keyspace,tablesInKeyspace,'VariableNames',{'Keyspace','Table'})];%#ok<AGROW>
                end
            else

                validateattributes(keyspace,{'char','string'},{'scalartext'},'tablenames','keyspace');
                keyspace=convertCharsToStrings(keyspace);
                if~any(lower(keyspace)==lower(this.Keyspaces))
                    error(message("database:cassandra:KeyspaceDoesNotExist",keyspace));
                end
                t=string(this.CassandraHandle.getTableNames(keyspace));
            end
        end

        function[columnMetaData,keyValues]=columninfo(this,keyspace,tableName)
            if~isopen(this)
                error(message('database:cassandra:InvalidCassandraConnection'));
            end


            validateattributes(keyspace,{'char','string'},{'scalartext'},'columninfo','keyspace');
            validateattributes(tableName,{'char','string'},{'scalartext'},'columninfo','tableName');
            [keyspace,tableName]=convertCharsToStrings(keyspace,tableName);


            if~any(lower(keyspace)==lower(this.Keyspaces))
                error(message("database:cassandra:KeyspaceDoesNotExist",keyspace));
            end


            keyspace=this.Keyspaces(lower(keyspace)==lower(this.Keyspaces));


            try
                allTables=this.tablenames(keyspace);
            catch ME
                throw(ME);
            end
            if~any(lower(tableName)==lower(allTables))
                error(message("database:cassandra:TableDoesNotExist",tableName,keyspace));
            end


            tableName=allTables(lower(tableName)==lower(allTables));

            colInfo=this.CassandraHandle.getColumnInfo(keyspace,tableName);

            colNames=string(colInfo(:,1));
            colTypes=string(colInfo(:,2));
            partitionKeys=strcmp(colInfo(:,3),'partitionKey');
            clusterColumns=string(colInfo(:,3));
            clusterColumns(clusterColumns~="ASC"&clusterColumns~="DESC")="";

            columnMetaData=table(colNames,colTypes,partitionKeys,clusterColumns,...
            'VariableNames',{'Name','DataType','PartitionKey','ClusteringColumn'});

            if nargout>1
                partitionKeyNames=columnMetaData.Name(partitionKeys);
                query="SELECT DISTINCT "+strjoin(partitionKeyNames,", ")+" FROM "+keyspace+"."+tableName+";";
                keyValues=executecql(this,query,'ConsistencyLevel','ONE');
            end
        end

        function data=executecql(this,query,varargin)





































            if~isopen(this)
                error(message('database:cassandra:InvalidCassandraConnection'));
            end



            p=inputParser;
            p.addRequired('query',@(x)validateattributes(x,{'string','char'},{'scalartext'},'executecql'));
            p.addParameter('ConsistencyLevel',"ONE",@(x)~isempty(validatestring(x,this.ConsistencyLevels,'executecql','ConsistencyLevel')));
            p.addParameter('RequestTimeout',this.RequestTimeout,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'},'executecql','RequestTimeout'));
            p.parse(query,varargin{:});
            consistencyLevel=p.Results.ConsistencyLevel;
            consistencyLevel=validatestring(consistencyLevel,this.ConsistencyLevels);
            requestTimeout=p.Results.RequestTimeout;

            stmt=apachecassandra.internal.Statement;
            stmt.createStatement(query,0);
            stmt.setConsistency(consistencyLevel);
            stmt.setTimeout(requestTimeout*1000);

            result=this.CassandraHandle.fetch(stmt);
            data=readCassandraResult(result);
            result.close();
        end

        function data=partitionRead(this,keyspace,tableName,varargin)























































            if~isopen(this)
                error(message('database:cassandra:InvalidCassandraConnection'));
            end


            validateattributes(keyspace,{'char','string'},{'scalartext'},'columns','keyspace');
            validateattributes(tableName,{'char','string'},{'scalartext'},'columns','tableName');
            [keyspace,tableName]=convertCharsToStrings(keyspace,tableName);


            try
                columns=columninfo(this,keyspace,tableName);
                partitionKeys=columns(columns.PartitionKey==true,:);
                clusteringColumns=columns(columns.ClusteringColumn~="",:);
                primaryKeys=[partitionKeys;clusteringColumns];
            catch ME
                throw(ME);
            end


            primaryKeyNames=primaryKeys.Name;
            primaryKeyTypes=primaryKeys.DataType;
            numPartitionKeys=height(partitionKeys);
            numPrimaryKeys=height(primaryKeys);



            [varargin{:}]=convertCharsToStrings(varargin{:});


            allTables=tablenames(this,keyspace);
            tableName=allTables(lower(tableName)==lower(allTables));


            firstNameValue=find(cellfun(@(x)isStringScalar(x)&&(x=="ConsistencyLevel"||x=="RequestTimeout"),varargin),1);
            if isempty(firstNameValue)


                keyValues=varargin;
                consistencyLevel="ONE";
                requestTimeout=this.RequestTimeout;
            else


                keyValues=varargin(1:firstNameValue-1);

                p=inputParser;
                p.addParameter('ConsistencyLevel',"ONE",@(x)validateattributes(x,{'string','char','cell'},{'scalartext'},'partitionRead','ConsistencyLevel'));
                p.addParameter('RequestTimeout',this.RequestTimeout,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'},'partitionRead','RequestTimeout'));
                p.parse(varargin{firstNameValue:end});
                consistencyLevel=string(p.Results.ConsistencyLevel);
                consistencyLevel=validatestring(consistencyLevel,this.ConsistencyLevels,'partitionRead','ConsistencyLevel');
                requestTimeout=int32(p.Results.RequestTimeout);
            end

            if~isempty(keyValues)&&length(keyValues)<numPartitionKeys

                error(message('database:cassandra:AllPartitionKeysRequired',numPartitionKeys));
            end

            if length(keyValues)>numPrimaryKeys


                error(message('database:cassandra:TooManyKeyValues',...
                tableName,numPrimaryKeys,length(keyValues)));
            end

            query="SELECT * FROM "+keyspace+"."+tableName;
            numParameters=0;
            parameters=cell.empty;
            parameterTypes=apachecassandra.internal.DataType.empty();
            missingVals=logical.empty;
            cassandraDataTypes=apachecassandra.internal.DataType.empty();

            for n=1:length(keyValues)




                for m=1:length(keyValues{n})
                    missingVals=[missingVals;isempty(keyValues{n}(m))||(~iscell(keyValues{n}(m))&&ismissing(keyValues{n}(m)))];%#ok<AGROW>
                end

                cassandraDataTypes(n)=this.CassandraHandle.getColumnDataType(keyspace,tableName,primaryKeyNames(n));
                keyValues{n}=convertMATLABToCassandraType(keyValues{n},cassandraDataTypes(n));

                [query,numParameters]=buildWhereCondition(query,numParameters,primaryKeyNames{n},keyValues{n});
                if isrow(keyValues{n})
                    keyValues{n}=keyValues{n}';
                end
                parameters=[parameters;num2cell(keyValues{n})];%#ok<AGROW>
                parameterTypes=[parameterTypes;repmat(cassandraDataTypes(n),length(keyValues{n}),1)];%#ok<AGROW>
            end

            stmt=apachecassandra.internal.Statement();
            stmt.createStatement(query,numParameters);
            stmt.setConsistency(consistencyLevel);
            stmt.setTimeout(requestTimeout*1000);

            for n=1:length(parameters)
                index=uint32(n);
                if missingVals(n)
                    stmt.bindNull(index);
                else
                    switch(parameterTypes(n).getType())
                    case{"ascii","text","varchar"}
                        stmt.bindString(index,parameters{n});
                    case{"bigint","time","timestamp"}
                        stmt.bindInt64(index,parameters{n});
                    case "blob"
                        stmt.bindBytes(index,parameters{n}{1},uint32(length(parameters{n}{1})));
                    case "boolean"
                        stmt.bindBool(index,parameters{n});
                    case "date"
                        stmt.bindUInt32(index,parameters{n});
                    case "decimal"
                        stmt.bindDecimal(index,parameters{n});
                    case "double"
                        stmt.bindDouble(index,parameters{n});
                    case "float"
                        stmt.bindFloat(index,parameters{n});
                    case "int"
                        stmt.bindInt32(index,parameters{n});
                    case "inet"
                        stmt.bindInet(index,parameters{n});
                    case "smallint"
                        stmt.bindInt16(index,parameters{n});
                    case "tinyint"
                        stmt.bindInt8(index,parameters{n});
                    case{"timeuuid","uuid"}
                        stmt.bindUUID(index,parameters{n});
                    case "varint"
                        stmt.bindVarint(index,parameters{n});
                    end
                end
            end

            result=this.CassandraHandle.fetch(stmt);
            data=readCassandraResult(result);
            result.close();
        end

        function upsert(this,keyspace,tableName,data,varargin)







































            if~isopen(this)
                error(message('database:cassandra:InvalidCassandraConnection'));
            end


            p=inputParser;
            p.addRequired('keyspace',@(x)validateattributes(x,{'char','string'},{'scalartext'},'upsert','keyspace'));
            p.addRequired('tableName',@(x)validateattributes(x,{'char','string'},{'scalartext'},'upsert','tableName'));
            p.addRequired('data',@(x)validateattributes(x,{'table'},{'nonempty'},'upsert','data'));
            p.addParameter('ConsistencyLevel',"ONE",@(x)~isempty(validatestring(x,this.ConsistencyLevels,'upsert')));
            p.addParameter('RequestTimeout',this.RequestTimeout,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'},'upsert','RequestTimeout'));
            p.parse(keyspace,tableName,data,varargin{:});

            consistencyLevel=p.Results.ConsistencyLevel;
            consistencyLevel=validatestring(consistencyLevel,this.ConsistencyLevels);
            requestTimeout=int32(p.Results.RequestTimeout);




            try
                columns=columninfo(this,keyspace,tableName);
                keyCheck=columns.PartitionKey==true|strlength(columns.ClusteringColumn)~=0;
                primaryKeys=columns.Name(keyCheck,:);
            catch ME
                throw(ME);
            end


            allTables=tablenames(this,keyspace);
            tableName=allTables(lower(tableName)==lower(allTables));

            if any(columns.DataType=="counter")


                error(message('database:cassandra:CounterUpsertNotSupported'));
            end

            columnsToSet=data.Properties.VariableNames;
            if~isempty(setdiff(lower(primaryKeys),lower(columnsToSet)))

                error(message('database:cassandra:UpsertRequiresPrimaryKeys',"("+join(primaryKeys,',')+")"));
            end



            allColumns=columns.Name;
            if~isempty(setdiff(lower(columnsToSet),lower(allColumns)))


                error(message('database:cassandra:VariableNotInCassandraTable'));
            end


            missingdata=ismissing(data);




            cassandraDataType=apachecassandra.internal.DataType.empty();
            for n=1:length(columnsToSet)
                columnName=allColumns(lower(allColumns)==lower(columnsToSet{n}));
                cassandraDataType(n)=this.CassandraHandle.getColumnDataType(keyspace,tableName,columnName);
                data.(columnsToSet{n})=convertMATLABToCassandraType(data.(columnsToSet{n}),cassandraDataType(n));
            end


            query="INSERT INTO "+keyspace+"."+tableName+" ("+strjoin(columnsToSet,",")+") VALUES("+...
            strjoin(repmat("?",length(columnsToSet),1),",")+")";

            batchStatement=apachecassandra.internal.Batch();
            batchStatement.setConsistency(consistencyLevel);
            for n=1:height(data)
                stmt=apachecassandra.internal.Statement();
                stmt.createStatement(query,length(columnsToSet));
                stmt.setTimeout(requestTimeout);
                for m=1:width(data)
                    index=uint32(m);
                    if missingdata(n,m)
                        stmt.bindNull(index);
                    else
                        switch cassandraDataType(m).getType()
                        case{"ascii","text","varchar"}
                            stmt.bindString(index,data{n,m});
                        case{"bigint","time","timestamp"}
                            stmt.bindInt64(index,data{n,m});
                        case "blob"
                            stmt.bindBytes(index,data{n,m}{:},uint32(length(data{n,m}{:})));
                        case "boolean"
                            stmt.bindBool(index,data{n,m});
                        case "date"
                            stmt.bindUInt32(index,data{n,m});
                        case "decimal"
                            stmt.bindDecimal(index,data{n,m});
                        case "double"
                            stmt.bindDouble(index,data{n,m});
                        case "float"
                            stmt.bindFloat(index,data{n,m});
                        case "int"
                            stmt.bindInt32(index,data{n,m});
                        case "inet"
                            stmt.bindInet(index,data{n,m});
                        case "smallint"
                            stmt.bindInt16(index,data{n,m});
                        case "tinyint"
                            stmt.bindInt8(index,data{n,m});
                        case{"timeuuid","uuid"}
                            stmt.bindUUID(index,data{n,m});
                        case "varint"
                            stmt.bindVarint(index,data{n,m});
                        case{"list","set","map"}
                            stmt.bindCollection(index,data{n,m});
                        case "tuple"
                            stmt.bindTuple(index,data{n,m});
                        case "udt"
                            stmt.bindUserType(index,data{n,m});
                        otherwise

                        end
                    end
                end

                batchStatement.addStatement(stmt);
            end

            this.CassandraHandle.executeBatch(batchStatement);
        end
    end

    methods(Hidden)
        function deleteRow(this,keyspace,tableName,varargin)







































            validateattributes(keyspace,{'char','string'},{'scalartext'},'deleteRow','keyspace');
            validateattributes(tableName,{'char','string'},{'scalartext'},'deleteRow','tableName');

            try
                allColumns=columninfo(this,keyspace,tableName);
                partitionKeys=allColumns(allColumns.PartitionKey==true,:);
                clusteringColumns=allColumns(allColumns.ClusteringColumn~="",:);
                primaryKeys=[partitionKeys;clusteringColumns];
            catch ME
                throw(ME)
            end

            primaryKeyNames=primaryKeys.Name;
            primaryKeyTypes=primaryKeys.DataType;
            numPartitionKeys=height(partitionKeys);
            numClusteringColumns=height(clusteringColumns);

            [varargin{:}]=convertCharsToStrings(varargin{:});


            firstNameValue=find(cellfun(@(x)isStringScalar(x)&&(strcmpi(x,"ConsistencyLevel")||strcmpi(x,"RequestTimeout")||strcmpi(x,"Columns")),varargin),1);
            if isempty(firstNameValue)


                keyValues=varargin;
                consistencyLevel="ONE";
                requestTimeout=this.RequestTimeout;
                columns=[];
            else


                keyValues=varargin(1:firstNameValue-1);

                p=inputParser;
                p.addParameter('ConsistencyLevel',"ONE",@(x)validateattributes(x,{'string','char','cell'},{'scalartext'},'deleteRow','ConsistencyLevel'));
                p.addParameter('RequestTimeout',this.RequestTimeout,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnegative'},'deleteRow','RequestTimeout'));
                p.addParameter('Columns',[],@(x)validateattributes(x,{'string','char','cell'},{},'deleteRow'));
                p.parse(varargin{firstNameValue:end});
                consistencyLevel=string(p.Results.ConsistencyLevel);
                consistencyLevel=validatestring(consistencyLevel,this.ConsistencyLevels,'deleteRow','ConsistencyLevel');
                requestTimeout=int32(p.Results.RequestTimeout);
                columns=string(p.Results.Columns);
            end

            if length(keyValues)<numPartitionKeys

                error(message('database:cassandra:AllPartitionKeysRequired',numPartitionKeys));
            end

            if length(keyValues)>numPartitionKeys+numClusteringColumns


                error(message('database:cassandra:TooManyKeyValues',...
                tableName,numPartitionKeys+numClusteringColumns,length(keyValues)));
            end


            if~isempty(columns)&&any(~ismember(columns,allColumns.Name))
                error(message('database:cassandra:ColumnNotInTable',tableName));
            end


            allTables=tablenames(this,keyspace);
            tableName=allTables(lower(tableName)==lower(allTables));

            query="DELETE ";
            if~isempty(columns)
                query=query+strjoin(columns,", ");
            end
            query=query+" FROM "+keyspace+"."+tableName+" ";
            numParameters=0;
            parameters=cell.empty;
            parameterTypes=apachecassandra.internal.DataType.empty();
            missingVals=logical.empty;
            cassandraDataType=apachecassandra.internal.DataType.empty();


            for n=1:length(keyValues)




                if istable(keyValues{n})
                    missingVals=[missingVals;false(height(keyValues{n}),1)];%#ok<AGROW>
                else
                    for m=1:length(keyValues{n})
                        missingVals=[missingVals;isempty(keyValues{n}(m))||(~iscell(keyValues{n}(m))&&ismissing(keyValues{n}(m)))];%#ok<AGROW>
                    end
                end

                cassandraDataType(n)=this.CassandraHandle.getColumnDataType(keyspace,tableName,primaryKeyNames(n));
                keyValues{n}=convertMATLABToCassandraType(keyValues{n},cassandraDataType(n));

                [query,numParameters]=buildWhereCondition(query,numParameters,primaryKeyNames{n},keyValues{n});
                if isrow(keyValues{n})
                    keyValues{n}=keyValues{n}';
                end
                parameters=[parameters;num2cell(keyValues{n})];%#ok<AGROW>
                parameterTypes=[parameterTypes;repmat(cassandraDataType(n),length(keyValues{n}),1)];%#ok<AGROW>
            end

            stmt=apachecassandra.internal.Statement();
            stmt.createStatement(query,numParameters);
            stmt.setConsistency(consistencyLevel);
            stmt.setTimeout(requestTimeout*1000);

            for n=1:length(parameters)
                index=uint32(n);
                if missingVals(n)
                    stmt.bindNull(index);
                else
                    switch(parameterTypes(n).getType())
                    case{"ascii","text","varchar"}
                        stmt.bindString(index,parameters{n});
                    case{"bigint","time","timestamp"}
                        stmt.bindInt64(index,parameters{n});
                    case "blob"
                        stmt.bindBytes(index,parameters{n}{1},uint32(length(parameters{n}{1})));
                    case "boolean"
                        stmt.bindBool(index,parameters{n});
                    case "date"
                        stmt.bindUInt32(index,parameters{n});
                    case "decimal"
                        stmt.bindDecimal(index,parameters{n});
                    case "double"
                        stmt.bindDouble(index,parameters{n});
                    case "float"
                        stmt.bindFloat(index,parameters{n});
                    case "int"
                        stmt.bindInt32(index,parameters{n});
                    case "inet"
                        stmt.bindInet(index,parameters{n});
                    case "smallint"
                        stmt.bindInt16(index,parameters{n});
                    case "tinyint"
                        stmt.bindInt8(index,parameters{n});
                    case{"timeuuid","uuid"}
                        stmt.bindUUID(index,parameters{n});
                    case "varint"
                        stmt.bindVarint(index,parameters{n});
                    case{"list","set","map"}
                        stmt.bindCollection(index,parameters{n});
                    case "tuple"
                        stmt.bindTuple(index,parameters{n});
                    case "udt"
                        stmt.bindUserType(index,parameters{n});
                    end
                end
            end

            result=this.CassandraHandle.fetch(stmt);
            result.close;
        end
    end
end

function data=readCassandraResult(result)
    result.parse();
    columnNames=result.getColumnNames();
    data=table;
    for n=1:length(columnNames)
        data.(columnNames{n})=result.fetchData(n);
    end

    missingIndices=result.getMissingData();
    columnTypes=string(result.getColumnTypes());
    if~isempty(data)
        for n=1:width(data)
            missingIdx=missingIndices(:,2)==n;
            missingRows=missingIndices(missingIdx,1);
            allRows=1:height(data);
            missingRows=ismember(allRows,missingRows);
            switch string(columnTypes(n))
            case{"ascii","text","varchar","inet","uuid","timeuuid","decimal","varint"}
                data.(data.Properties.VariableNames{n})=string(data{:,n});
                data.(data.Properties.VariableNames{n})(missingRows)=string(missing);
            case "blob"
                if~iscell(data.(data.Properties.VariableNames{n}))
                    data.(data.Properties.VariableNames{n})=mat2cell(data.(data.Properties.VariableNames{n}),ones(length(data.(data.Properties.VariableNames{n})),1));
                end
            case "timestamp"
                data.(data.Properties.VariableNames{n})=datetime(1970,1,1,0,0,0,'TimeZone','UTC')+milliseconds(data{:,n});
                data.(data.Properties.VariableNames{n})(missingRows)=NaT;
            case "time"
                data.(data.Properties.VariableNames{n})=duration(0,0,0,data{:,n}/1000000);
                data.(data.Properties.VariableNames{n})(missingRows)=duration(NaN,NaN,NaN);
            case "date"
                data.(data.Properties.VariableNames{n})=datetime(1970,1,1)+days(data{:,n}-uint32(2^31));
                data.(data.Properties.VariableNames{n})(missingRows)=NaT;
            case{"list","set"}
                if~iscell(data.(data.Properties.VariableNames{n}))
                    data.(data.Properties.VariableNames{n})=mat2cell(data.(data.Properties.VariableNames{n}),ones(height(data)),1);%#ok<MMTC>
                end
                data.(data.Properties.VariableNames{n})=parseSetOrList(data.(data.Properties.VariableNames{n}),result.getDataType(n).getSubType(1));
            case{"tuple","udt"}


                data.(data.Properties.VariableNames{n})=struct2table(data.(data.Properties.VariableNames{n}),'AsArray',true);
                data.(data.Properties.VariableNames{n})=parseTupleOrUDT(data.(data.Properties.VariableNames{n}),result.getDataType(n),missingRows);
            case "map"

                if~iscell(data.(data.Properties.VariableNames{n}))
                    data.(data.Properties.VariableNames{n})=mat2cell(data.(data.Properties.VariableNames{n}),length(data.(data.Properties.VariableNames{n})));
                end
                emptyIdx=cellfun(@isempty,data.(data.Properties.VariableNames{n}));
                data.(data.Properties.VariableNames{n})(emptyIdx)={table([],[],'VariableNames',{'Keys','Values'})};
                data.(data.Properties.VariableNames{n})(~emptyIdx)=cellfun(@(x)struct2table(x,'AsArray',true),data.(data.Properties.VariableNames{n})(~emptyIdx),'UniformOutput',false);
                data.(data.Properties.VariableNames{n})(~emptyIdx)=cellfun(@(x)parseTupleOrUDT(x,result.getDataType(n),false(1,height(x))),...
                data.(data.Properties.VariableNames{n})(~emptyIdx),'UniformOutput',false);
            end
        end
    end
end

function data=parseSetOrList(data,dataType)
    typeName=string(dataType.getType());
    switch typeName
    case{"ascii","text","varchar","inet","uuid","timeuuid","decimal","varint"}
        data=cellfun(@string,data,'UniformOutput',false);
    case{"bigint","counter"}
        emptyIdx=cellfun(@isempty,data);
        data(emptyIdx)={int64.empty};
    case "blob"
        emptyIdx=cellfun(@isempty,data);
        data(emptyIdx)={uint8.empty};
    case "double"
        emptyIdx=cellfun(@isempty,data);
        data(emptyIdx)={double.empty};
    case "float"
        emptyIdx=cellfun(@isempty,data);
        data(emptyIdx)={single.empty};
    case "int"
        emptyIdx=cellfun(@isempty,data);
        data(emptyIdx)={int32.empty};
    case "smallint"
        emptyIdx=cellfun(@isempty,data);
        data(emptyIdx)={int16.empty};
    case "timestamp"
        emptyIdx=cellfun(@isempty,data);
        data(emptyIdx)={datetime.empty};
        func=@(x)datetime(1970,1,1,0,0,0,'TimeZone','GMT')+milliseconds(x);
        data(~emptyIdx)=cellfun(func,data(~emptyIdx),'UniformOutput',false);
    case "time"
        emptyIdx=cellfun(@isempty,data);
        data(emptyIdx)={duration.empty};
        func=@(x)duration(0,0,0,x/1000000);
        data(~emptyIdx)=cellfun(func,data(~emptyIdx),'UniformOutput',false);
    case "tinyint"
        emptyIdx=cellfun(@isempty,data);
        data(emptyIdx)={int8.empty};
    case "date"
        emptyIdx=cellfun(@isempty,data);
        data(emptyIdx)={datetime.empty};
        func=@(x)datetime(1970,1,1)+days(x-uint32(2^31));
        data(~emptyIdx)=cellfun(func,data(~emptyIdx),'UniformOutput',false);
    case{"list","set"}

        for n=1:length(data)
            subCell=data{n};
            if isempty(subCell)
                data{n}={};
            else
                if~iscell(subCell)
                    data{n}=mat2cell(subCell,ones(length(subCell)),1);%#ok<MMTC>
                end
                subType=dataType.getSubType(1);


                data(n)=parseSetOrList(data(n),subType);
            end
        end
    case{"tuple","udt"}
        emptyIdx=cellfun(@isempty,data);
        data(emptyIdx)={table.empty};
        func=@(x)struct2table(x,'AsArray',true);
        data(~emptyIdx)=cellfun(func,data(~emptyIdx),'UniformOutput',false);
        func=@(x)parseTupleOrUDT(x,dataType,false(1,height(x)));
        data(~emptyIdx)=cellfun(func,data(~emptyIdx),'UniformOutput',false);
    case{"map"}
        for n=1:length(data)
            if isempty(data{n})
                data(n)={table.empty};
                break;
            end
            func=@(x)struct2table(x,'AsArray',true);
            data{n}=cellfun(func,data{n},'UniformOutput',false);
            func=@(x)parseTupleOrUDT(x,dataType,false(1,height(x)));
            data{n}=cellfun(func,data{n},'UniformOutput',false);
        end
    end
end

function data=parseTupleOrUDT(data,dataType,missingRows)
    missingIdx=data{:,end};
    data(:,end)=[];
    numFields=width(data);
    for n=1:numFields
        subType=string(dataType.getSubType(n).getType());
        missingFields=missingIdx(:,n);
        switch subType
        case{"ascii","text","varchar","inet","uuid","timeuuid","decimal","varint"}
            data.(data.Properties.VariableNames{n})=string(data{:,n});
            data.(data.Properties.VariableNames{n})(missingRows|missingFields')=string(missing);
        case "timestamp"
            data.(data.Properties.VariableNames{n})=datetime(1970,1,1,0,0,0,'TimeZone','UTC')+milliseconds(data{:,n});
            data.(data.Properties.VariableNames{n})(missingRows|missingFields')=datetime(NaN,NaN,NaN,'TimeZone','UTC');
        case "time"
            data.(data.Properties.VariableNames{n})=duration(0,0,0,data{:,n}/1000000);
            data.(data.Properties.VariableNames{n})(missingRows|missingFields')=duration(NaN,NaN,NaN);
        case "date"
            data.(data.Properties.VariableNames{n})=datetime(1970,1,1)+days(data{:,n}-uint32(2^31));
            data.(data.Properties.VariableNames{n})(missingRows|missingFields')=NaT;
        case{"list","set"}
            if~iscell(data.(data.Properties.VariableNames{n}))
                data.(data.Properties.VariableNames{n})=mat2cell(data.(data.Properties.VariableNames{n}),ones(height(data),1));
            end

            data.(data.Properties.VariableNames{n})=parseSetOrList(data.(data.Properties.VariableNames{n}),dataType.getSubType(n).getSubType(1));
        case{"tuple","udt"}

            data.(data.Properties.VariableNames{n})=struct2table(data.(data.Properties.VariableNames{n}),'AsArray',true);
            data.(data.Properties.VariableNames{n})=parseTupleOrUDT(data.(data.Properties.VariableNames{n}),dataType.getSubType(n),missingRows);
        case "map"
            data.(data.Properties.VariableNames{n})(missingRows|missingFields')={table([],[],'VariableNames',{'Keys','Values'})};
            data.(data.Properties.VariableNames{n})(~(missingRows|missingFields'))=cellfun(@(x)struct2table(x,'AsArray',true),data.(data.Properties.VariableNames{n})(~missingRows),'UniformOutput',false);
            data.(data.Properties.VariableNames{n})(~(missingRows|missingFields'))=cellfun(@(x)parseTupleOrUDT(x,dataType.getSubType(n),false(1,sum(~missingRows))),...
            data.(data.Properties.VariableNames{n})(~(missingRows|missingFields')),'UniformOutput',false);
        end
    end
end

function[query,numParameters]=buildWhereCondition(query,numParameters,primaryKeyName,keyValues)
    if numParameters==0
        query=query+" WHERE ";
    else
        query=query+" AND ";
    end

    query=query+primaryKeyName;

    if length(keyValues)==1
        query=query+" = ?";
    else
        query=query+" IN ("+strjoin(repmat("?",length(keyValues),1),",")+")";
    end

    numParameters=numParameters+length(keyValues);
end

function data=convertMATLABToCassandraType(data,dataType)
    switch dataType.getType()
    case{"ascii","text","varchar","inet","timeuuid","uuid"}
        if(~isstring(data)&&~iscellstr(data)&&...
            ~ischar(data))||~isvector(data)
            error(message('database:cassandra:InvalidTextKeyValue',dataType.getType));
        end

        data=string(data);
    case "bigint"
        try
            validateattributes(data,{'numeric','logical'},{'vector'});
        catch
            error(message('database:cassandra:InvalidNumericKeyValue',dataType.getType));
        end
        data=int64(data);
    case "blob"
        if isnumeric(data)&&isrow(data)
            data={uint8(data)};
        elseif isnumeric(data)&&(iscolumn(data)||ismatrix(data))
            [rows,~]=size(data);
            data=mat2cell(uint8(data),ones(1,rows));
        elseif iscell(data)&&all(cellfun(@isnumeric,data))
            data=cellfun(@uint8,data,'UniformOutput',false);
        else
            error(message('database:cassandra:InvalidBlobValue',dataType.getType));
        end
    case "boolean"
        try
            validateattributes(data,{'numeric','logical'},{'vector'});
        catch
            error(message('database:cassandra:InvalidBooleanKeyValue',dataType.getType));
        end
        data=fillmissing(data,'constant',0);
        data=logical(data);
    case "date"
        if(~isdatetime(data)&&~isstring(data)&&...
            ~iscellstr(data)&&~ischar(data))||...
            ~isvector(data)
            error(message('database:cassandra:InvalidDatetimeKeyValue',dataType.getType));
        end


        data=datetime(data);


        data=uint32(days(data-datetime(1970,1,1)))+uint32(2^31);
    case{"decimal","varint"}
        dataClass=class(data);
        try
            validateattributes(data,{'numeric','sym','string','cell','char','logical'},{'vector'});
            if iscell(data)
                cellfun(@(x)validateattributes(x,{'char'},{'vector'}),data);
            end
        catch ME
            error(message('database:cassandra:InvalidNumericKeyValue',dataType.getType));
        end

        if isnumeric(data)
            if dataType.getType()=="varint"
                data=round(data);
            end
            data=string(arrayfun(@(x)num2str(x,'%f'),data,'UniformOutput',false));
        elseif islogical(data)
            data=string(double(data));
        else
            data=string(data);
        end

        strtrim(data);
        if(dataClass=="string"||dataClass=="cell"||dataClass=="char")&&any(~ismissing(data)&isnan(str2double(data)))
            error(message('database:cassandra:stringToDecimalFailure',dataType.getType));
        end


        if any(cellfun(@(x)isempty(regexp(x,'^(-?\d+(\.\d+)?)|NaN$','once')),data))
            error(message('database:cassandra:stringToDecimalFailure',dataType.getType));
        end

        if dataType=="varint"
            if any(contains(data,"."))
                error(message('database:cassandra:varintDecimalFailure'));
            end
        end

    case "double"
        try
            validateattributes(data,{'numeric','logical'},{});
        catch
            error(message('database:cassandra:InvalidNumericKeyValue',dataType.getType));
        end

        data=double(data);
    case "float"
        try
            validateattributes(data,{'numeric','logical'},{'vector'});
        catch
            error(message('database:cassandra:InvalidNumericKeyValue',dataType.getType));
        end

        data=single(data);
    case "int"
        try
            validateattributes(data,{'numeric','logical'},{'vector'});
        catch
            error(message('database:cassandra:InvalidNumericKeyValue',dataType.getType));
        end

        data=int32(data);
    case "smallint"
        try
            validateattributes(data,{'numeric','logical'},{'vector'});
        catch
            error(message('database:cassandra:InvalidNumericKeyValue',dataType.getType));
        end

        data=int16(data);
    case "time"
        if(~isduration(data)&&~isstring(data)&&...
            ~iscellstr(data)&&~ischar(data))||...
            ~isvector(data)
            error(message('database:cassandra:InvalidDurationKeyValue',dataType.getType));
        end

        dur=duration(data);
        durMS=milliseconds(dur);
        data=int64(durMS*10^6);
    case "timestamp"
        if(~isdatetime(data)&&~isstring(data)&&...
            ~iscellstr(data)&&~ischar(data))||...
            ~isvector(data)
            error(message('database:cassandra:InvalidDatetimeKeyValue',dataType.getType));
        end

        dt=datetime(data);
        if dt.TimeZone==""
            dt.TimeZone="UTC";
        end

        data=milliseconds(dt-datetime(1970,1,1,0,0,0,0,'TimeZone','GMT'));
    case "tinyint"
        try
            validateattributes(data,{'numeric','logical'},{'vector'});
        catch
            error(message('database:cassandra:InvalidNumericKeyValue',dataType.getType));
        end

        data=int8(data);
    case "list"
        validateattributes(data,{'cell'},{'vector'});
        subDataType=dataType.getSubType(1);
        data=cellfun(@(x)cell2Collection(x,subDataType,'list'),data);
    case "set"
        validateattributes(data,{'cell'},{'vector'});
        subDataType=dataType.getSubType(1);
        data=cellfun(@(x)cell2Collection(x,subDataType,'set'),data);
    case "map"

        validateattributes(data,{'cell'},{'vector'});

        cellfun(@(x)validateattributes(x,{'table'},{'ncols',2}),data);

        varNameCheck=cellfun(@(x)all(strcmp(x.Properties.VariableNames,...
        {'Keys','Values'})),data);
        if~all(varNameCheck)
            error(message('database:cassandra:InvalidMapVariableNames'));
        end
        keyDataType=dataType.getSubType(1);
        valueDataType=dataType.getSubType(2);
        data=cellfun(@(x)table2Collection(x,keyDataType,valueDataType),data);
    case "tuple"

        validateattributes(data,{'table'},{});
        numItems=dataType.getSubTypeCount();
        if width(data)~=numItems
            error(message('database:cassandra:InvalidTupleFieldNumber'));
        end
        subTypes=apachecassandra.internal.DataType.empty();
        for n=1:numItems
            subTypes(n)=dataType.getSubType(n);
        end
        data=table2Tuple(data,subTypes);
    case "udt"

        validateattributes(data,{'table'},{});
        subTypeNames=dataType.getSubTypeNames();
        if~isequal(sort(data.Properties.VariableNames),sort(subTypeNames)')
            error(message('database:cassandra:InvalidUDTVariableNames'));
        end
        data=table2udt(data,dataType);
    otherwise
        error(message('database:cassandra:InvalidKeyType',dataType,tableName));
    end
end

function collection=cell2Collection(data,dataType,collectionType)
    data=convertMATLABToCassandraType(data,dataType);
    collection=apachecassandra.internal.Collection();
    collection.initializeCollection(collectionType,uint32(length(data)));

    for n=1:length(data)
        appendCollection(collection,data(n),dataType);
    end
end

function collection=table2Collection(data,keyDataType,valueDataType)
    collection=apachecassandra.internal.Collection();
    collection.initializeCollection("map",uint32(height(data)));
    if~isempty(data)
        keys=convertMATLABToCassandraType(data.Keys,keyDataType);
        values=convertMATLABToCassandraType(data.Values,valueDataType);
        for n=1:height(data)
            appendCollection(collection,keys(n),keyDataType);
            appendCollection(collection,values(n),valueDataType)
        end
    end
end

function appendCollection(collection,data,dataType)
    switch(dataType.getType())
    case{"ascii","text","varchar"}
        collection.appendString(data);
    case{"bigint","time","timestamp"}
        collection.appendInt64(data);
    case{"blob"}
        collection.appendBytes(data{1},uint32(length(data{1})));
    case{"boolean"}
        collection.appendBool(data);
    case{"date"}
        collection.appendUInt32(data);
    case{"decimal"}
        collection.appendDecimal(data);
    case{"double"}
        collection.appendDouble(data);
    case{"float"}
        collection.appendFloat(data);
    case{"inet"}
        collection.appendInet(data);
    case{"int"}
        collection.appendInt32(data);
    case{"smallint"}
        collection.appendInt16(data);
    case{"timeuuid","uuid"}
        collection.appendUUID(data);
    case{"tinyint"}
        collection.appendInt8(data);
    case{"varint"}
        collection.appendVarint(data);
    case{"list","set","map"}
        collection.appendCollection(data);
    case{"tuple"}
        collection.appendTuple(data);
    case{"udt"}
        collection.appendUserType(data);
    end
end

function tuple=table2Tuple(data,subTypes)

    missingVals=ismissing(data);

    for n=1:length(subTypes)
        data.(data.Properties.VariableNames{n})=convertMATLABToCassandraType(data{:,n},subTypes(n));
    end

    tuple=apachecassandra.internal.Tuple.empty();
    for n=1:height(data)
        tuple(n,1)=apachecassandra.internal.Tuple();
        tuple(n,1).initializeTuple(uint32(width(data)));
        for m=1:width(data)
            if ismissing(missingVals(n,m))
                tuple(n,1).setNull(uint32(m));
            else
                switch subTypes(m).getType()
                case{"ascii","text","varchar"}
                    tuple(n,1).setString(uint32(m),data{n,m});
                case{"bigint","time","timestamp"}
                    tuple(n,1).setInt64(uint32(m),data{n,m});
                case{"blob"}
                    tuple(n,1).setBytes(uint32(m),data{n,m}{1},uint32(length(data{n,m}{1})));
                case{"boolean"}
                    tuple(n,1).setBool(uint32(m),data{n,m});
                case{"date"}
                    tuple(n,1).setUInt32(uint32(m),data{n,m});
                case{"decimal"}
                    tuple(n,1).setDecimal(uint32(m),data{n,m});
                case{"double"}
                    tuple(n,1).setDouble(uint32(m),data{n,m});
                case{"float"}
                    tuple(n,1).setFloat(uint32(m),data{n,m});
                case{"inet"}
                    tuple(n,1).setInet(uint32(m),data{n,m});
                case{"int"}
                    tuple(n,1).setInt32(uint32(m),data{n,m});
                case{"smallint"}
                    tuple(n,1).setInt16(uint32(m),data{n,m});
                case{"timeuuid","uuid"}
                    tuple(n,1).setUUID(uint32(m),data{n,m});
                case{"tinyint"}
                    tuple(n,1).setInt8(uint32(m),data{n,m});
                case{"varint"}
                    tuple(n,1).setVarint(uint32(m),data{n,m});
                case{"list","set","map"}
                    tuple(n,1).setCollection(uint32(m),data{n,m});
                case{"tuple"}
                    tuple(n,1).setTuple(uint32(m),data{n,m});
                case{"udt"}
                    tuple(n,1).setUserType(uint32(m),data{n,m});
                end
            end
        end
    end
end

function udt=table2udt(data,dataType)

    missingVals=ismissing(data);

    for n=1:width(data)
        subType=dataType.getSubTypeByName(data.Properties.VariableNames{n});
        data.(data.Properties.VariableNames{n})=convertMATLABToCassandraType(data{:,n},subType);
    end

    udt=apachecassandra.internal.UserType.empty();
    for n=1:height(data)
        udt(n,1)=apachecassandra.internal.UserType();
        udt(n,1).initializeUserType(dataType);
        for m=1:width(data)
            varName=data.Properties.VariableNames{m};
            if missingVals(n,m)
                udt(n,1).setNull(varName);
            else
                subType=dataType.getSubTypeByName(varName);
                switch subType.getType()
                case{"ascii","text","varchar"}
                    udt(n,1).setString(varName,data{n,m});
                case{"bigint","time","timestamp"}
                    udt(n,1).setInt64(varName,data{n,m});
                case{"blob"}
                    udt(n,1).setBytes(varName,data{n,m}{1},uint32(length(data{n,m}{1})));
                case{"boolean"}
                    udt(n,1).setBool(varName,data{n,m});
                case{"date"}
                    udt(n,1).setUInt32(varName,data{n,m});
                case{"decimal"}
                    udt(n,1).setDecimal(varName,data{n,m});
                case{"double"}
                    udt(n,1).setDouble(varName,data{n,m});
                case{"float"}
                    udt(n,1).setFloat(varName,data{n,m});
                case{"inet"}
                    udt(n,1).setInet(varName,data{n,m});
                case{"int"}
                    udt(n,1).setInt32(varName,data{n,m});
                case{"smallint"}
                    udt(n,1).setInt16(varName,data{n,m});
                case{"timeuuid","uuid"}
                    udt(n,1).setUUID(varName,data{n,m});
                case{"tinyint"}
                    udt(n,1).setInt8(varName,data{n,m});
                case{"varint"}
                    udt(n,1).setVarint(varName,data{n,m});
                case{"list","set","map"}
                    udt(n,1).setCollection(varName,data{n,m});
                case{"tuple"}
                    udt(n,1).setTuple(varName,data{n,m});
                case{"udt"}
                    udt(n,1).setUserType(varName,data{n,m});
                end
            end
        end
    end
end
