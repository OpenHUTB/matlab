classdef connection<handle&matlab.mixin.CustomDisplay

    properties(Access=public)

        Database;
    end

    properties(SetAccess=private)


        UserName string;

        Server string;

        Port double;

        CollectionNames string;

    end

    properties(Hidden=true)
        ConnectionHandle;

    end

    methods
        function obj=connection(varargin)

            if nargin==2
                validateattributes(varargin{1},["string","char"],"scalartext");
                validateattributes(varargin{1},["string","char"],"scalartext");
                url=varargin{1};
                obj.Database=varargin{2};
                try
                    obj.ConnectionHandle=mongoc.internal.MongoConnection;
                    obj.ConnectionHandle.getClient(url);
                    obj.ConnectionHandle.getDatabase(obj.Database);
                    obj.CollectionNames=string(obj.ConnectionHandle.getCollectionNames());
                catch ME
                    throw(ME);
                end
            else
                p=inputParser;
                p.addRequired("server",@(x)validateattributes(x,["string","char"],{}));
                p.addRequired("port",@(x)validateattributes(x,"numeric",["row","nonnegative","positive","nonnan","finite"]));
                p.addRequired("database",@(x)validateattributes(x,["string","char"],"scalartext"));
                p.addParameter("UserName","",@(x)validateattributes(x,["string","char"],"scalartext"));
                p.addParameter("Password","",@(x)validateattributes(x,["string","char"],"scalartext"));

                p.parse(varargin{:});

                server=p.Results.server;
                port=p.Results.port;

                if isempty(server)
                    error(message('database:mongodb:IncorrectDataType','server'));
                end

                switch class(server)

                case{'string','char'}

                    server=cellstr(server);
                    if any(cellfun(@isempty,server)==1)
                        error(message('database:mongodb:IncorrectDataType','server'));
                    end

                case{'cell'}

                    if~all(cellfun(@ischar,server)==1)||any(cellfun(@isempty,server)==1)
                        error(message('database:mongodb:IncorrectDataType','server'));
                    end
                    server=cellstr(p.Results.server);
                end



                if length(port)~=length(server)
                    error(message('database:mongodb:PortServerSizeMismatch'))
                end

                obj.Server=string(p.Results.server);
                obj.Port=p.Results.port;
                obj.UserName=string(p.Results.UserName);
                obj.Database=string(p.Results.database);

                for i=1:length(obj.Server)
                    if i==1
                        serverlist=obj.Server(i)+":"+num2str(obj.Port(i));
                    else
                        serverlist=serverlist+","+obj.Server(i)+":"+num2str(obj.Port(i));
                    end

                end
                try
                    obj.ConnectionHandle=mongoc.internal.MongoConnection;
                    if obj.UserName.strlength==0||string(p.Results.Password).strlength==0
                        obj.ConnectionHandle.getClient("mongodb://"+serverlist+"/"+obj.Database);
                    else
                        obj.ConnectionHandle.getClient("mongodb://"+obj.UserName+":"+p.Results.Password+"@"+serverlist+"/"+obj.Database);
                    end
                    obj.ConnectionHandle.getDatabase(obj.Database);
                    obj.CollectionNames=string(obj.ConnectionHandle.getCollectionNames());
                catch ME
                    throw(ME);
                end
            end

        end

        function collectionnames=get.CollectionNames(obj)

            try
                collectionnames=string(obj.ConnectionHandle.getCollectionNames());
            catch ME
                throw(ME)
            end

        end

    end

    methods(Access=public)
        dropCollection(mongodbconn,collectname);
        createCollection(mongodbconn,collectname,varargin);
        val=isopen(mongodbconn);
        close(mongodbconn);
        val=count(mongodbconn,query,varargin);
        deletecount=remove(mongodbconn,collectname,query);
        data=find(mongodbconn,collectname,varargin);
        updatecount=update(mongodbconn,collectname,findquery,updatequery,varargin);
        insertCount=insert(mongodbconn,collectname,documents,varargin);
    end

    methods(Hidden=true)

        function delete(obj)
            if isvalid(obj)
                close(obj);
            end
        end
    end

end

