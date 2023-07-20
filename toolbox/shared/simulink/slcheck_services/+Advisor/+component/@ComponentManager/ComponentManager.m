classdef ComponentManager<handle




    properties

        CloseModels=true;


        CreateSubHierarchy=true;

        AnalyzeLibraries=false;
        ModelReferencesSimulationMode="AllModes";

    end

    properties(Dependent,Access=private)


SingleComponentMode
    end

    properties(SetAccess=private)

        AnalysisRoot='';

        IsInitialized=false;
        IsDirty=false;




        AnalyzeMFiles=false;
    end

    properties(Hidden,SetAccess=private)


        AnalysisRootFile='';



        AnalysisRootComponentID='';
        AnalysisRootType=Advisor.component.Types.empty();




        AbstractRootID='';
        AbstractRootIDType=Advisor.component.Types.empty();


        Templates;
        ComponentGraph;
    end

    properties(Access=private)

        ByTypeCache;




        ExternalProperties;
        ExternalPropertyNames={};
        ExternalPropertiesDefaultValues;
    end


    events
StatusAvailable
    end

    methods










        function this=ComponentManager(varargin)
            this.Templates=containers.Map('KeyType','char','ValueType','any');
            this.ByTypeCache=containers.Map('KeyType','char','ValueType','any');

            this.ComponentGraph=Advisor.component.ComponentGraph();

            if~isempty(varargin)
                p=inputParser();
                p.KeepUnmatched=true;
                p.parse(varargin{:});
                in=p.Unmatched;

                this.ExternalPropertyNames=fieldnames(in);
                this.ExternalPropertiesDefaultValues=in;
                this.ExternalProperties=table();
            end
        end


        function delete(this)

            ks=this.ByTypeCache.keys;
            for n=1:length(ks)
                this.ByTypeCache.remove(ks{n});
            end

        end




        initializeExternally(this,root,abstractRoot,options,createSubHierarchy,...
        graph,templates);


        function val=get.SingleComponentMode(this)
            val=~(this.AnalyzeLibraries||this.AnalyzeMFiles||...
            (this.ModelReferencesSimulationMode~="None"));
        end



        function status=setSingleComponentMode(this,state)
            status=false;

            if~this.IsInitialized
                this.SingleComponentMode=state;
                status=true;
            end
        end


        function status=existComponent(this,instID)
            status=this.ComponentGraph.isValidComponentID(instID);
        end


        function status=existTemplate(this,id)
            status=this.Templates.isKey(id);
        end



        function t=getTemplates(this,varargin)
            if isempty(varargin)
                tcell=this.Templates.values;
                t=[tcell{:}];
            else
                ids=varargin{1};

                if ischar(ids)
                    ids={ids};
                end

                t=Advisor.component.Template.empty(length(ids),0);

                for n=1:length(ids)
                    t(n)=this.Templates(ids{n});
                end
            end
        end






        function instIDs=getRootComponentsWithProperties(this,props,externalProps)
            instIDs=findComponentsWithProps(this,...
            this.AnalysisRootComponentID,props,externalProps,true);
            instIDs=unique(instIDs);
        end

        instIDs=getComponentsWithProperties(this,props,externalProps);


        function props=getProperties(this,instID)
            props=struct();

            if this.existComponent(instID)
                props=table2struct(this.ExternalProperties(instID,:));
            end
        end


        function setProperty(this,instID,propertyName,value)
            if this.existComponent(instID)&&...
                isfield(this.ExternalPropertiesDefaultValues,propertyName)

                this.ExternalProperties{instID,propertyName}=value;

            end
        end




        function setProperties(this,instIDs,propertyName,value)
            if ischar(instIDs)
                instIDs={instIDs};
            end

            if isfield(this.ExternalPropertiesDefaultValues,propertyName)
                numComps=size(this.ExternalProperties(instIDs,propertyName),1);

                if ischar(value)
                    propCell=cellstr(repmat(value,numComps,1));
                    this.ExternalProperties(instIDs,propertyName)=propCell;
                elseif isnumeric(value)||islogical(value)
                    propCell=num2cell(repmat(value,numComps,1));
                    this.ExternalProperties(instIDs,propertyName)=propCell;
                end
            end
        end



        function setDirtyFlag(this)
            this.IsDirty=true;
        end



        function ids=getComponentIDs(this)
            ids=this.ComponentGraph.getComponentIDs();
        end



        function cmp=getComponent(this,ID)
            if this.existComponent(ID)
                cmp=this.ComponentGraph.getComponent(ID);
            else
                cmp=Advisor.component.Component.empty();
            end
        end

        status=isParentOf(this,childID,parentID);
    end

    methods(Access=private)


        instIDs=findComponentsWithProps(this,nodeID,props,externalProps,exit);

        initExternalProperties(this);
        createCaches(this);
    end

    methods(Hidden)

        function c=getChildNodes(this,instID)
            c=this.ComponentGraph.getChildComponents(instID);
        end


        function p=getParentNodes(this,instID)
            p=this.ComponentGraph.getParentComponents(instID);
        end


        function hasPs=hasParentNodes(this,instID)
            ps=this.getParentNodes(instID);
            hasPs=~isempty(ps);
        end



        function cg=getComponentGraph(this)
            cg=this.ComponentGraph;
        end
    end

    methods(Static,Hidden)
        [rootCompID,type,linked,file]=parseAnalysisRoot(root,intype);
    end
end