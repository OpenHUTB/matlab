classdef LookupTableModel<LUTWidget.Connector


    properties(Constant)
        FieldNames={
'Value'
'Min'
'Max'
'Unit'
'FieldName'
'Description'
        };
    end

    properties(SetObservable,SetAccess=private)
        IsDirty=false
    end

    properties(Access=private)

        RootEventListeners={}
        AxesEventListeners={}
        TableEventListeners={}
        CellSelection=struct('src',[],'eventData',[])
    end

    events
AfterSetBaseline
    end

    methods
        function this=LookupTableModel()


            for i=1:numel(this.Axes)
                this.Axes(i).FieldName=regexprep(this.Axes(i).FieldName,'\s','');
            end
            this.Table.FieldName=regexprep(this.Table.FieldName,'\s','');

            this.updateRootEventListeners();
            this.updateAxesEventListeners();
            this.updateTableEventListeners();
        end

        function delete(this)
            this.clearRootEventListeners();
            this.clearAxesEventListeners();
            this.clearTableEventListeners();
        end


        function result=compareBaselineData(this,that)
            bdThis=this.getBaselineData();
            bdThat=that.getBaselineData();
            hasNumDimsDifference=numel(bdThis.Axes)~=numel(bdThat.Axes);
            hasContentDifference=hasNumDimsDifference||~(...
            isPropertyBaselineDataSame(bdThis.Table,bdThat.Table)&&...
            all(arrayfun(@(i)isPropertyBaselineDataSame(bdThis.Axes(i),bdThat.Axes(i)),1:numel(bdThis.Axes)))...
            );

            result=struct(...
            'HasContentDifference',hasContentDifference,...
            'HasNumDimsDifference',hasNumDimsDifference);
        end

        function setBaselineData(this,table,axes)
            setBaselineData@LUTWidget.Connector(this,table,axes);
            this.updateDirtyFlag();
            this.notify('AfterSetBaseline');
        end

        function clearHistory(this)
            clearHistory@LUTWidget.Connector(this);
            this.updateDirtyFlag();
        end


        function bd=getBaselineData(this)
            bd=struct;
            for i=1:numel(this.Axes)
                bd.Axes(i)=getBaselineDataForProperty(this.Axes(i));
            end
            bd.Table=getBaselineDataForProperty(this.Table);
        end


        function cellSelection=getCurrentCellSelection(this)
            cellSelection=this.CellSelection;
        end


        function featureClassIDs=getSortedFeatureIDs(this)
            features=this.getFeatures();

            featureClassIDs=unique(cellfun(@(f)class(f),features,'UniformOutput',false));
        end

        function addFeatureIfNotYet(this,feature)
            existingFeatures=this.getFeatures();
            if~any(cellfun(@(f)isa(f,class(feature)),existingFeatures))
                this.addFeature(feature);
            end
        end

        function removeFeatureByType(this,featureType)
            existingFeatures=this.getFeatures();
            fidx=find(cellfun(@(f)isa(f,featureType),existingFeatures));
            if~isempty(fidx)
                assert(isscalar(fidx));
                this.removeFeature(existingFeatures{fidx});
            end
        end

        function updateDisablePropertyEditFeatures(this,features)
            disablePropertyEditfeatureIDs={'LUTWidget.DisableAxesEdit','LUTWidget.DisableTableEdit'};
            newFeatureIDs=cellfun(@(f)class(f),features,'UniformOutput',false);
            mustBeMember(newFeatureIDs,disablePropertyEditfeatureIDs);

            cellfun(@(f)this.addFeatureIfNotYet(f),features);
            featureIDsToRemove=setdiff(disablePropertyEditfeatureIDs,newFeatureIDs);
            cellfun(@(fid)this.removeFeatureByType(fid),featureIDsToRemove);
        end
    end

    methods(Access=private)
        function clearRootEventListeners(this)
            cellfun(@delete,this.RootEventListeners);
            this.RootEventListeners={};
        end

        function updateRootEventListeners(this)
            this.clearRootEventListeners();


            this.RootEventListeners{end+1}=addlistener(this,'SliceSelected',@(~,~)this.cacheCellSelection([],[]));
            this.RootEventListeners{end+1}=addlistener(this,'Action',@(src,eventData)this.updateDirtyFlag());

            this.RootEventListeners{end+1}=addlistener(this,'AfterSetBaseline',@(~,~)this.updatePropertyEventListeners());
            this.RootEventListeners{end+1}=addlistener(this,'Axes','PostSet',@(~,~)this.updateAxesEventListeners());
            this.RootEventListeners{end+1}=addlistener(this,'Table','PostSet',@(~,~)this.updateTableEventListeners());
        end

        function updatePropertyEventListeners(this)
            this.updateAxesEventListeners();
            this.updateTableEventListeners();
        end

        function clearAxesEventListeners(this)
            cellfun(@delete,this.AxesEventListeners);
            this.AxesEventListeners={};
        end

        function updateAxesEventListeners(this)
            this.clearAxesEventListeners();
            this.RootEventListeners{end+1}=addlistener(this.Axes,'CellSelected',@(src,eventData)this.cacheCellSelection(src,eventData));
        end

        function clearTableEventListeners(this)
            cellfun(@delete,this.TableEventListeners);
            this.TableEventListeners={};
        end

        function updateTableEventListeners(this)
            this.clearTableEventListeners();
            this.RootEventListeners{end+1}=addlistener(this.Table,'CellSelected',@(src,eventData)this.cacheCellSelection(src,eventData));
        end


        function cacheCellSelection(this,src,eventData)
            this.CellSelection.src=src;
            this.CellSelection.eventData=eventData;
        end


        function updateDirtyFlag(this)
            if this.IsDirty~=this.isUndoActionAvailable()
                this.IsDirty=this.isUndoActionAvailable();
            end
        end
    end
end

function propbd=getBaselineDataForProperty(property)
    propbd=struct(...
    'Value',property.getBaseline(),...
    'Min',property.Min,...
    'Max',property.Max,...
    'Unit',property.Unit,...
    'FieldName',property.FieldName,...
    'Description',property.Description...
    );
end

function tf=isPropertyBaselineDataSame(propbd1,propbd2)
    tf=isequal(propbd1,propbd2)&&...
    strcmp(class(propbd1.Value),class(propbd2.Value))&&...
    strcmp(class(propbd1.Min),class(propbd2.Min))&&...
    strcmp(class(propbd1.Max),class(propbd2.Max));
end
