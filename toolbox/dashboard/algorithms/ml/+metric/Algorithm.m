classdef Algorithm<handle









    properties(Dependent,SetAccess=protected)
        AlgorithmID string;
        Version uint32;
    end






    properties(Dependent,SetAccess=private)
        ID string;
        ScopeQuery alm.gdb.QueryConfiguration;
        ArtifactQuery alm.gdb.QueryConfiguration;
        ExecutionContext metric.data.Context;
        ValueDataType metric.data.ValueType;
        SupportedValueDataTypes metric.data.ValueType;
    end


    properties(Dependent,SetAccess=private,Hidden)
        AlgorithmDependencies string;
        MapKey string;
        AnchorID string;
        Licenses string;
        DataServiceDependencies string;
        RequiredLicenses string;
    end

    properties(Access=private,Hidden)
        Model;
        StaticProperties;
        DynamicProperties;
        UserMessages;
    end

    methods
        function obj=Algorithm()
            obj.Model=mf.zero.Model();
            obj.StaticProperties=metric.data.AlgorithmStaticProperties.createEmptyInstance(obj.Model);
            obj.DynamicProperties=metric.data.AlgorithmDynamicProperties.createEmptyInstance(obj.Model);
            obj.UserMessages=struct('Type',{},'Title',{},'Message',{});
        end
    end


    methods
        function value=get.AlgorithmID(obj)
            value=obj.StaticProperties.AlgorithmID;
        end

        function value=get.ExecutionContext(obj)
            value=obj.DynamicProperties.ExecutionContext;
        end

        function value=get.ScopeQuery(obj)
            if~isempty(obj.DynamicProperties.ScopeQuery)
                value.Namespace=obj.DynamicProperties.ScopeQuery.Namespace;
                value.Statement=obj.DynamicProperties.ScopeQuery.Statement;
            else
                value=[];
            end
        end

        function value=get.ArtifactQuery(obj)
            if~isempty(obj.DynamicProperties.ArtifactQuery)
                value.Namespace=obj.DynamicProperties.ArtifactQuery.Namespace;
                value.Statement=obj.DynamicProperties.ArtifactQuery.Statement;
            else
                value=[];
            end
        end

        function value=get.Version(obj)
            value=obj.StaticProperties.Version;
        end

        function value=get.ValueDataType(obj)
            value=obj.DynamicProperties.ValueDataType;
        end

        function value=get.DataServiceDependencies(obj)
            value={};

            objArray=obj.DynamicProperties.DataServiceDependencies.toArray();
            for n=1:numel(objArray)
                value{n}=objArray(n).ID;%#ok<AGROW>
            end
        end

        function val=get.Licenses(obj)
            val=obj.DynamicProperties.Licenses.toArray();

            if isempty(val)

                val={};
            end
        end

        function val=get.RequiredLicenses(obj)
            val=obj.StaticProperties.RequiredLicenses.toArray();

            if isempty(val)

                val={};
            end
        end

        function val=get.SupportedValueDataTypes(obj)
            val=obj.StaticProperties.SupportedValueDataTypes.toArray();
        end


        function value=get.ID(obj)
            value=obj.DynamicProperties.ID;
        end

        function value=get.AlgorithmDependencies(obj)
            value={};

            objArray=obj.DynamicProperties.AlgorithmDependencies.toArray();
            for n=1:numel(objArray)
                value{n}=objArray(n).ID;%#ok<AGROW>
            end
        end

        function value=get.MapKey(obj)
            value=obj.DynamicProperties.MapKey;
        end

        function value=get.AnchorID(obj)
            value=obj.DynamicProperties.AnchorID;
        end
    end


    methods
        function set.AlgorithmID(obj,value)
            obj.StaticProperties.AlgorithmID=value;
        end

        function set.Version(obj,value)
            assert(isa(value,'uint32'),'Expecting uint32 input.');
            obj.StaticProperties.Version=value;
        end
    end

    methods(Access=protected)
        function addSupportedValueDataType(obj,value)
            obj.StaticProperties.SupportedValueDataTypes.add(value);
        end

        function addRequiredLicense(obj,value)
            obj.StaticProperties.RequiredLicenses.add(value);
        end
    end
    methods
        function metaInfo=getMetaInformation(obj,varargin)
            metaInfo=obj.getMetaInfo(obj.DynamicProperties.MetaInformation,varargin{:});
        end
    end



    methods(Hidden)
        function notifyUserError(obj,msg)
            assert(isa(msg,'message'),'Expecting a message as input.');
            obj.UserMessages(end+1).Type=uint8(2);
            obj.UserMessages(end).Title=msg.Identifier;
            obj.UserMessages(end).Message=msg.getString();
        end

        function notifyUserWarning(obj,msg)
            assert(isa(msg,'message'),'Expecting a message as input.');
            obj.UserMessages(end+1).Type=uint8(1);
            obj.UserMessages(end).Title=msg.Identifier;
            obj.UserMessages(end).Message=msg.getString();
        end

        function notifyUser(obj,msg)
            assert(isa(msg,'message'),'Expecting a message as input.');
            obj.UserMessages(end+1).Type=uint8(0);
            obj.UserMessages(end).Title=msg.Identifier;
            obj.UserMessages(end).Message=msg.getString();
        end

        function msgs=getUserMessages(obj)
            msgs=obj.UserMessages;
            obj.UserMessages=struct('Type',{},'Title',{},'Message',{});
        end
    end

    methods(Access=private)
        function metaInfo=getMetaInfo(obj,map,varargin)
            if nargin==2
                locale=obj.getCurrentLocale();

                mi=map.getByKey(locale);
                if isempty(mi)

                    locales=map.keys();

                    if numel(locales)>0
                        locale=locales{1};
                    else
                        locale="_EMPTY_";
                    end
                end
            else
                locale=varargin{1};
            end

            if~strcmp(locale,"_EMPTY_")
                metaInfo=map.getByKey(locale);
            else
                metaInfo=[];
            end
        end

        function locale=getCurrentLocale(~)
            l=feature('locale');
            locale=strtok(l.ctype,'.');
        end
    end

    methods(Hidden)

        function value=get(obj,propName)
            switch propName
            case 'Model'
                value=obj.Model;
            case 'StaticProperties'
                value=obj.StaticProperties;
            case 'DynamicProperties'
                value=obj.DynamicProperties;
            otherwise
                value=[];
            end
        end

        function set(obj,propName,value)
            switch propName
            case 'DynamicProperties'
                obj.DynamicProperties=value.copy(obj.get('Model'));
            end
        end
    end
end
