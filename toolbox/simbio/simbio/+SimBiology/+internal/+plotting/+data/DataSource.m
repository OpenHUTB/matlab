classdef DataSource<matlab.mixin.SetGet
    properties(Access=public)
        programName='';
        dataName='';
        variableName='';
        type='';
        associatedDataSources=[];
    end

    properties(SetAccess=protected,GetAccess=public)
        key;
    end

    methods(Access=public)
        function obj=DataSource(input)
            if nargin>0
                if isempty(input)
                    obj=SimBiology.internal.plotting.data.DataSource.empty;
                elseif ischar(input)

                    obj.dataName=input;
                else

                    obj(numel(input),1)=SimBiology.internal.plotting.data.DataSource;
                    arrayfun(@setDataSourceFieldsForSingleObject,obj,input);
                end
            end
        end
    end

    methods(Access=private)
        function obj=setDataSourceFieldsForSingleObject(obj,input)
            set(obj,'programName',input.programName,'dataName',input.dataName,'variableName',input.variableName);
            if isfield(input,'type')
                obj.type=input.type;
            else
                obj.type='';
            end
            if isfield(input,'associatedDataSources')
                obj.associatedDataSources=SimBiology.internal.plotting.data.DataSource(input.associatedDataSources);
            end

            obj.updateKey;
        end

        function updateKey(obj)

            obj.key=obj.getName();
        end
    end

    methods(Access=public)
        function name=getName(obj)
            if isempty(obj.programName)
                name=obj.dataName;
            else
                name=[obj.programName,':',obj.dataName,':',obj.variableName];
            end
        end

        function name=getShortName(obj)
            if isempty(obj.programName)
                name=obj.dataName;
            else
                name=obj.programName;
                if~strcmp(obj.dataName,'LastRun')
                    name=[name,':',obj.dataName];
                end
                if~strcmp(obj.variableName,'results')
                    name=[name,':',obj.variableName];
                end
            end
        end

        function flag=isEqualByKey(obj,dataSource)

            flag=obj.isEqualToKey(dataSource.key);
        end

        function flag=isEqualToKey(obj,dataSourceKey)

            flag=strcmp({obj.key},dataSourceKey);
        end

        function flag=isEqual(obj,dataSource)
            if isempty(obj)
                flag=isempty(dataSource);
            else
                flag=arrayfun(@(ds)isEqualFcn(ds,dataSource),obj);
            end

            function flag=isEqualFcn(ds1,ds2)
                if~isempty(dataSource)
                    flag=strcmp(ds1.programName,ds2.programName)&&...
                    strcmp(ds1.dataName,ds2.dataName)&&...
                    strcmp(ds1.variableName,ds2.variableName);
                else
                    flag=false;
                end
            end
        end

        function flag=hasAssociatedDataSource(obj,dataSource)

            flag=any(arrayfun(@(ads)ads.isEqual(dataSource),obj.associatedDataSources));
        end

        function dataSource=getStruct(obj)
            if isempty(obj)
                dataSource=[];
            else
                dataSource=struct;
                dataSource.programName=obj.programName;
                dataSource.dataName=obj.dataName;
                dataSource.variableName=obj.variableName;
                dataSource.type=obj.type;
                if isempty(obj.associatedDataSources)
                    dataSource.associatedDataSources=[];
                else
                    dataSource.associatedDataSources=obj.associatedDataSources.getStruct();
                end
            end
        end
    end

    methods
        function set.programName(obj,value)
            obj.programName=value;
            obj.updateKey;
        end

        function set.dataName(obj,value)
            obj.dataName=value;
            obj.updateKey;
        end

        function set.variableName(obj,value)
            obj.variableName=value;
            obj.updateKey;
        end
    end
end