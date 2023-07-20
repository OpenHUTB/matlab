classdef BaseSet<handle




    properties(Transient=true,Access={?slreq.ReqSet,?slreq.LinkSet,?slreq.report.Report})
        dataObject;
    end

    methods(Static)
        function obj=loadobj(s)
            obj=s;
            rmiut.warnNoBacktrace('Slvnv:slreq:illegalDataForMATFile',class(obj));
        end
    end
    methods
        function sobj=saveobj(obj)
            rmiut.warnNoBacktrace('Slvnv:slreq:illegalDataForMATFile',class(obj));
            sobj=obj;
        end
    end


    methods(Access=public)
        function addAttribute(this,name,type,varargin)
            parser=inputParser();
            parser.addRequired('Name',@checkAttributeName);
            parser.addRequired('Type',@checkAttributeType);
            parser.addParameter('Description','',@(x)ischar(x)||(isscalar(x)&&isstring(x)));
            parser.addParameter('DefaultValue','');
            parser.addParameter('List',{},@validatekList);
            parser.parse(name,type,varargin{:});

            typeEnum=slreq.custom.AttributeType.nameToEnum(type);

            hasDefaultValue=~isempty(parser.Results.DefaultValue);
            hasList=~isempty(parser.Results.List);
            defaultValOrEnumList='';
            switch typeEnum
            case slreq.custom.AttributeType.Combobox
                if~hasList
                    error(message('Slvnv:slreq:AttrRegistryListMustDefine',type));
                elseif hasDefaultValue
                    error(message('Slvnv:slreq:AttrRegistryDefaultUnsupported',type));
                end
                defaultValOrEnumList=parser.Results.List;
                if~any(strcmp(defaultValOrEnumList,'Unset'))


                    defaultValOrEnumList=[{'Unset'},defaultValOrEnumList];
                end
            case slreq.custom.AttributeType.Checkbox
                if hasList
                    error(message('Slvnv:slreq:AttrRegistryListUnsupported',type));
                end
                if~hasDefaultValue

                    defaultValOrEnumList=false;
                else
                    defaultValOrEnumList=parser.Results.DefaultValue;
                end
            case{slreq.custom.AttributeType.Edit,slreq.custom.AttributeType.DateTime}
                if hasDefaultValue
                    error(message('Slvnv:slreq:AttrRegistryDefaultUnsupported',type));
                end
                if hasList
                    error(message('Slvnv:slreq:AttrRegistryListUnsupported',type));
                end
            otherwise


            end

            this.dataObject.addCustomAttribute(name,typeEnum,parser.Results.Description,defaultValOrEnumList)

            function tf=checkAttributeName(name)
                tf=~slreq.custom.AttributeHandler.isReservedName(name);
                if~tf
                    error(message('Slvnv:slreq_import:ReservedNameCannotBeUsed',name));
                end
            end

            function tf=checkAttributeType(type)
                slreq.custom.AttributeType.nameToEnum(type);
                tf=true;
            end

        end

        function deleteAttribute(this,Name,varargin)
            parser=inputParser();
            parser.addRequired('Name',@(x)ischar(x)||(isscalar(x)&&isstring(x)));
            parser.addParameter('Force',false,@validateLogical);

            parser.parse(Name,varargin{:});

            this.dataObject.deleteCustomAttribute(Name,parser.Results.Force);
        end

        function updateAttribute(this,Name,varargin)
            parser=inputParser();
            parser.addRequired('Name',@(x)ischar(x)||(isscalar(x)&&isstring(x)));
            parser.addParameter('Description',NaN,@(x)ischar(x)||(isscalar(x)&&isstring(x)));
            parser.addParameter('DefaultValue',NaN,@validateLogical);
            parser.addParameter('List',NaN,@validatekList);

            parser.parse(Name,varargin{:});

            this.dataObject.udpateCustomAttribute(Name,parser.Results,parser.UsingDefaults);
        end

        function out=inspectAttribute(this,Name)
            out=this.dataObject.getCustomAttribute(Name);
        end
    end

    methods(Access=protected)
        function errorIfVectorOperation(this)
            if numel(this)>1
                error(message('Slvnv:slreq:MethodOnlyForScalar'));
            end
        end
    end

    methods(Hidden)
        function generateTraceDiagram(this)
            this.errorIfVectorOperation();
            slreq.internal.tracediagram.utils.generateTraceDiagram(this.dataObject);
        end
    end

end

function tf=validatekList(list)
    tf=true;
    validateattributes(list,{'string','cell'},{'vector'});
end

function tf=validateLogical(in)

    tf=islogical(logical(in))&&isscalar(in);
end