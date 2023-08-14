classdef Analyzer<matlabshared.application.Application&...
    matlabshared.application.ToolGroupFileSystem




    properties(SetAccess=protected)
        DataModel;
Uplink
Downlink
Results
UplinkFSPLVisual
UplinkFoMVisual
DownlinkFSPLVisual
DownlinkFoMVisual
    end

    properties(Access=protected)
SpecificationChangedListener
ResultsComputedListener
    end

    methods

        function this=Analyzer

            this.DataModel=comm.internal.linkBudgetApp.DataModel;
        end

        function set.DataModel(this,model)
            this.DataModel=model;
            this.SpecificationChangedListener=event.listener(model,'SpecificationChanged',@this.onSpecificationChanged);%#ok<*MCSUP>
            this.ResultsComputedListener=event.listener(model,'ResultsComputed',@this.onResultsComputed);%#ok<*MCSUP>


            onSpecificationChanged(this);
        end

        function b=useAppContainer(~)
            b=true;
        end
    end

    methods(Hidden)

        function onSpecificationChanged(this,~,~)
            if isempty(this.Uplink)
                return;
            end
            update(this.Uplink);
            update(this.Downlink);
        end

        function onResultsComputed(this,~,~)
            if isempty(this.Results)
                return;
            end
            update(this.Results);
            update(this.UplinkFSPLVisual);
            update(this.UplinkFoMVisual);
            update(this.DownlinkFSPLVisual);
            update(this.DownlinkFoMVisual);
        end

        function name=getName(~)
            name=getString(message('comm_demos:LinkBudgetApp:LinkBudgetAnalyzer'));
        end

        function tag=getTag(~)
            tag='linkBudgetApp';
        end

        function title=getTitle(this)
            title=getTitle@matlabshared.application.ToolGroupFileSystem(this);
        end

        function b=showRecentFiles(~)
            b=true;
        end

        function new(this,~)
            if allowNew(this)
                new@matlabshared.application.ToolGroupFileSystem(this);
                new(this.DataModel);
            end
        end

        function success=openFile(this,varargin)
            success=openFile@matlabshared.application.ToolGroupFileSystem(this,varargin{:});
            if success
                openFile@matlabshared.application.undoredo.ToolGroupUndoRedo(this);
            end
        end

        function p=getPathToIcons(~)
            p=fullfile(matlabroot,'toolbox','comm','commdemos','+comm','+internal','+linkBudgetApp');
        end

        function helpCallback(~,~,~)

            helpview(fullfile(docroot,'comm','comm.map'),'LinkBudgetAnalysisExample');
        end

    end

    methods(Access=protected)
        function c=createDefaultComponents(this)
            this.Uplink=comm.internal.linkBudgetApp.Uplink(this);
            this.Downlink=comm.internal.linkBudgetApp.Downlink(this);
            this.Results=comm.internal.linkBudgetApp.Results(this);
            this.UplinkFSPLVisual=comm.internal.linkBudgetApp.UplinkFSPLVisual(this);
            this.UplinkFoMVisual=comm.internal.linkBudgetApp.UplinkFoMVisual(this);
            this.DownlinkFSPLVisual=comm.internal.linkBudgetApp.DownlinkFSPLVisual(this);
            this.DownlinkFoMVisual=comm.internal.linkBudgetApp.DownlinkFoMVisual(this);
            c=[this.Uplink,this.Downlink,this.Results...
            ,this.UplinkFSPLVisual,this.UplinkFoMVisual...
            ,this.DownlinkFSPLVisual,this.DownlinkFoMVisual];
        end

        function h=createToolstrip(this)
            h=comm.internal.linkBudgetApp.Toolstrip(this);
        end

        function s=getSaveData(this)
            s.DataModel=this.DataModel;
        end

        function processOpenData(this,s)
            this.DataModel=s.DataModel;
        end

        function updateComponents(this,~)




            uplink=this.Uplink;
            downlink=this.Downlink;
            results=this.Results;
            upFSPLVis=this.UplinkFSPLVisual;
            upFoMVis=this.UplinkFoMVisual;
            downFSPLVis=this.DownlinkFSPLVisual;
            downFoMVis=this.DownlinkFoMVisual;

            allComps=[uplink,downlink,results,upFSPLVis,upFoMVis...
            ,downFSPLVis,downFoMVis];


            set([allComps.Figure],'Visible','on');
            columnWeights=[0.3,0.3,0.4];
            if useAppContainer(this)
                appContainer=this.Window.AppContainer;
                leftComps=[uplink,downlink];
                centerComps=results;
                rightComps=[upFSPLVis,upFoMVis,downFSPLVis,downFoMVis];

                appContainer.DocumentLayout=struct(...
                'gridDimensions',struct('w',3,'h',1),...
                'columnWeights',columnWeights,...
                'rowWeights',1,...
                'tileCount',3,...
                'tileCoverage',[1,2,3],...
                'tileOccupancy',{getTileOccupancy(this.Window,leftComps,centerComps,rightComps)});
            end
        end
    end
end


