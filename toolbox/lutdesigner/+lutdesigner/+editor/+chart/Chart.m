classdef Chart<handle

    properties(Constant,Access=private)
        ViewModelCtor=struct(...
        'line',@lutdesigner.editor.chart.Line,...
        'multiline',@lutdesigner.editor.chart.MultiLine,...
        'mesh',@lutdesigner.editor.chart.Mesh,...
        'surface',@lutdesigner.editor.chart.Surface,...
        'contour',@lutdesigner.editor.chart.Contour...
        );
    end

    properties(SetAccess=immutable)
Figure
ChartType
ViewModel
DataModel
    end

    properties(Access=private)
SliceSelection
IVIndices
        RootEventListeners={}
        AxesEventListeners={}
        TableEventListeners={}
CellSelectionCache
    end

    events
Failure
    end

    methods
        function this=Chart(fig,chartType,dataModel,testDepConfig)
            mustBeMember(chartType,{'line','mesh','surface','contour'});
            validateattributes(dataModel,{'LUTWidget.Connector'},{'scalar'});
            if~exist('testDepConfig','var')
                testDepConfig=struct;
            end

            this.Figure=fig;
            this.ChartType=chartType;
            if numel(dataModel.Axes)==1
                assert(strcmp(chartType,'line'),...
                'lutdesigner:internal:improperChartType',...
                '1-d data can only have line chart.');
            else
                if strcmp(chartType,'line')
                    chartType='multiline';
                end
            end
            ax=uiaxes(fig,'Units','normalized','Position',[0.05,0.05,0.9,0.9]);

            if isfield(testDepConfig,'ViewModel')
                this.ViewModel=testDepConfig.ViewModel;
            else
                this.ViewModel=this.ViewModelCtor.(chartType)(ax);
            end

            this.DataModel=dataModel;
        end

        function delete(this)
            this.clearRootEventListeners();
            this.clearAxesEventListeners();
            this.clearTableEventListeners();
        end

        function startup(this)
            this.updateRootEventListeners();
            this.updateAxesEventListeners();
            this.updateTableEventListeners();
            this.Figure.CloseRequestFcn=@(event,handlers)figureCloseRequestFcn(this);
            this.render();
            currentCellSelection=this.DataModel.getCurrentCellSelection();
            this.updateForCellSelection(currentCellSelection.src,currentCellSelection.eventData);
        end

        function render(this)
            try
                this.updateSliceSelection();

                ivData=arrayfun(@(i)this.getIndependentVariableData(i),1:numel(this.IVIndices),'UniformOutput',false);
                dvData=this.getDependentVariableData();
                this.ViewModel.plot(ivData{:},dvData);
                for i=1:numel(this.IVIndices)
                    ividx=this.IVIndices(i);
                    this.ViewModel.updateIndependentVariableLabel(i,...
                    this.DataModel.Axes(ividx).FieldName,this.DataModel.Axes(ividx).Unit);
                end
                this.ViewModel.updateDependentVariableLabel(...
                this.DataModel.Table.FieldName,this.DataModel.Table.Unit);
            catch
                notify(this,'Failure');
            end
        end

        function updateForAction(this,eventData)
            try
                updateMemo=struct('IV',false(size(this.SliceSelection)),'DV',false);
                updateMemo=this.parseActionEventData(updateMemo,eventData);
                for i=1:numel(updateMemo.IV)
                    if updateMemo.IV(i)
                        axisValue=this.getIndependentVariableData(i);
                        axisLength=numel(axisValue);
                        this.ViewModel.updateIndependentVariableData(i,axisValue);
                        if~isempty(this.CellSelectionCache)

                            this.CellSelectionCache(this.CellSelectionCache(:,i)>axisLength,:)=[];
                        end
                    end
                end
                if updateMemo.DV
                    this.ViewModel.updateDependentVariableData(this.getDependentVariableData());
                end
                this.ViewModel.updateSelectionMark(this.CellSelectionCache);
            catch
                notify(this,'Failure');
            end
        end

        function updateForCellSelection(this,src,eventData)
            try
                if isa(src,'LUTWidget.Table')
                    coords=cellfun(@(coord)cell2mat(coord(:,this.IVIndices)),eventData.Indices(:),'UniformOutput',false);
                    this.CellSelectionCache=vertcat(coords{:});
                else
                    this.CellSelectionCache=[];
                end
                this.ViewModel.updateSelectionMark(this.CellSelectionCache);
            catch
                notify(this,'Failure');
            end
        end
    end

    methods(Access=private)
        function figureCloseRequestFcn(this)
            f=this.Figure;
            delete(this);
            delete(f);
        end

        function clearRootEventListeners(this)
            cellfun(@delete,this.RootEventListeners);
            this.RootEventListeners={};
        end

        function updateRootEventListeners(this)
            this.clearRootEventListeners();

            this.RootEventListeners{end+1}=addlistener(this.DataModel,'SliceSelected',@(~,~)this.render());
            this.RootEventListeners{end+1}=addlistener(this.DataModel,'Action',@(~,eventData)this.updateForAction(eventData));

            this.RootEventListeners{end+1}=addlistener(this.DataModel,'AfterSetBaseline',@(~,~)this.updatePropertyEventListeners());
            this.RootEventListeners{end+1}=addlistener(this.DataModel,'Axes','PostSet',@(~,~)this.updateAxesEventListeners());
            this.RootEventListeners{end+1}=addlistener(this.DataModel,'Table','PostSet',@(~,~)this.updateTableEventListeners());
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
            this.AxesEventListeners{end+1}=addlistener(this.DataModel.Axes,'CellSelected',@(src,eventData)this.updateForCellSelection(src,eventData));
        end

        function clearTableEventListeners(this)
            cellfun(@delete,this.TableEventListeners);
            this.TableEventListeners={};
        end

        function updateTableEventListeners(this)
            this.clearTableEventListeners();
            this.TableEventListeners{end+1}=addlistener(this.DataModel.Table,'CellSelected',@(src,eventData)this.updateForCellSelection(src,eventData));
        end

        function updateSliceSelection(this)
            sel=this.DataModel.getCurrentSliceSelection();
            this.SliceSelection=sel.Selection;
            if isfield(sel,'XAxis')
                this.IVIndices=[sel.YAxis,sel.XAxis];
            else
                this.IVIndices=sel.YAxis;
            end
        end

        function ivData=getIndependentVariableData(this,index)
            dimIndex=this.IVIndices(index);
            ivData=this.DataModel.Axes(dimIndex).Value;
            if isa(ivData,'LUTWidget.UnknownDataSource')
                dvData=this.DataModel.Table.Value;
                if isvector(dvData)
                    ivData=1:numel(dvData);
                else
                    ivData=1:size(dvData,dimIndex);
                end
            end
        end

        function dvData=getDependentVariableData(this)
            dvData=squeeze(this.DataModel.Table.Value(this.SliceSelection{:}));
            if numel(this.IVIndices)>1&&this.IVIndices(1)<this.IVIndices(2)
                dvData=dvData.';
            end
        end

        function updateMemo=parseActionEventData(this,updateMemo,actionData)
            switch actionData.ActionType
            case{'CellEdit','ArrayEdit'}
                pathParts=strsplit(actionData.ActionData.Property,'/');
                assert(strcmp(pathParts{end},'Value'));
                if strcmp(pathParts{1},'Table')
                    updateMemo.DV=true;
                else
                    assert(strcmp(pathParts{1},'Axes'));
                    updateMemo.IV(this.IVIndices==str2double(pathParts{2}))=true;
                end
            case{'IncreaseDimensionSize','DecreaseDimensionSize'}
                updateMemo.DV=true;
                updateMemo.IV(this.IVIndices==actionData.ActionData.Dimension)=true;
            otherwise
                assert(ismember(actionData.ActionType,{'Composite','Paste'}));
                for i=1:numel(actionData.ActionData)
                    updateMemo=this.parseActionEventData(updateMemo,actionData.ActionData(i));
                end
            end
        end
    end
end
