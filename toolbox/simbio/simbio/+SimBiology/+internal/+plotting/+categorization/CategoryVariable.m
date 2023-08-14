classdef CategoryVariable<matlab.mixin.SetGet


    methods(Static)

        function const=RESPONSE
            const='<RESPONSE>';
        end
        function const=RESPONSE_SET
            const='<RESPONSE_SET>';
        end
        function const=GROUP
            const='<GROUP>';
        end
        function const=PARAM
            const='<PARAM>';
        end
        function const=COVARIATE
            const='<COVARIATE>';
        end
        function const=ASSOCIATED_GROUP
            const='<ASSOCIATED_GROUP>';
        end
        function const=BIN_SET
            const='<BIN_SET>';
        end

        function const=QUANTITY
            const='<QUANTITY>';
        end
        function const=DOSE
            const='<DOSE>';
        end
        function const=VARIANT
            const='<VARIANT>';
        end
        function const=CONTINUOUS
            const='<CONTINUOUS>';
        end
        function const=CATEGORICAL
            const='<CATEGORICAL>';
        end
    end

    properties(Access=public)

        type=[];

        subtype=[];

        name='';




        dataSource=SimBiology.internal.plotting.data.DataSource.empty;



        associatedDataSource=SimBiology.internal.plotting.data.DataSource.empty;
    end

    properties(SetAccess=protected,GetAccess=public)
        key;
    end

    methods(Access=public)
        function obj=CategoryVariable(input)
            if nargin>0
                if ischar(input)
                    obj.type=input;
                    obj.name=input;
                else
                    obj.name=input.name;
                    obj.type=input.type;
                    obj.subtype=input.subtype;

                    if~isempty(input.associatedDataSource)
                        obj.associatedDataSource=SimBiology.internal.plotting.data.DataSource(input.associatedDataSource);
                    else
                        obj.associatedDataSource=SimBiology.internal.plotting.data.DataSource.empty;
                    end
                    if(isa(input,'SimBiology.internal.plotting.categorization.CategoryVariable')||isstruct(input)&&isfield(input,'dataSource'))&&~isempty(input.dataSource)
                        obj.dataSource=SimBiology.internal.plotting.data.DataSource(input.dataSource);
                    else
                        obj.dataSource=[];
                    end
                end

                obj.updateKey;
            end
        end

        function categoryVariable=getStruct(obj,excludeDataSource)
            if nargin==1
                excludeDataSource=false;
            end
            categoryVariable=struct('name',obj.name,...
            'type',obj.type,...
            'subtype',obj.subtype);

            if~isempty(obj.associatedDataSource)
                categoryVariable.associatedDataSource=obj.associatedDataSource.getStruct();
            else
                categoryVariable.associatedDataSource=[];
            end

            if~excludeDataSource
                if~isempty(obj.dataSource)
                    categoryVariable.dataSource=obj.dataSource.getStruct();
                else
                    categoryVariable.dataSource=[];
                end
            end
        end

        function updateKey(obj)

            if obj.isVariable
                obj.key=obj.getDisplayName(true);
            else
                obj.key=obj.type;
            end
        end

        function displayName=getDisplayName(obj,plotDefinitionOrFlag)
            if strcmp(obj.name,obj.RESPONSE)
                displayName='Response';
            elseif strcmp(obj.name,obj.RESPONSE_SET)
                displayName='Response Set';
            elseif strcmp(obj.name,obj.GROUP)
                displayName='Scenario';
            else
                prefix='';
                if islogical(plotDefinitionOrFlag)
                    showDataSource=plotDefinitionOrFlag;
                else
                    showDataSource=plotDefinitionOrFlag.qualifyCategoryByDataSource(obj);
                end
                if showDataSource&&~isempty(obj.dataSource)
                    prefix=[obj.dataSource.getShortName(),'.'];
                end
                displayName=[prefix,obj.name];
            end
        end

        function flag=isEqual(obj,comparisonObj)

            if ischar(comparisonObj)
                comparisonKey=comparisonObj;
            else
                comparisonKey=comparisonObj.key;
            end

            flag=arrayfun(@(c)strcmp(c.key,comparisonKey),obj);













        end

        function flag=isOfType(obj,type)
            flag=strcmp({obj.type},type);
        end

        function flag=isOfSubtype(obj,type)
            flag=strcmp({obj.subtype},type);
        end

        function flag=isResponse(obj)
            flag=isOfType(obj,obj.RESPONSE);
        end

        function flag=isResponseSet(obj)
            flag=isOfType(obj,obj.RESPONSE_SET);
        end

        function flag=isGroup(obj)
            flag=isOfType(obj,obj.GROUP);
        end

        function flag=isParam(obj)
            flag=isOfType(obj,obj.PARAM);
        end

        function flag=isCovariate(obj)
            flag=isOfType(obj,obj.COVARIATE);
        end

        function flag=isAssociatedGroup(obj)
            flag=isOfType(obj,obj.ASSOCIATED_GROUP);
        end

        function flag=isBinSet(obj)
            flag=isOfType(obj,obj.BIN_SET);
        end

        function flag=isVariable(obj)
            flag=obj.isParam|obj.isCovariate|obj.isAssociatedGroup;
        end

        function flag=isContinuousCovariate(obj)
            flag=obj.isCovariate&&isOfSubtype(obj,obj.CONTINUOUS);
        end
    end

    methods
        function set.dataSource(obj,value)
            obj.dataSource=value;
            obj.updateKey;
        end

        function set.name(obj,value)
            obj.name=value;
            obj.updateKey;
        end
    end
end