classdef Simulator<handle&matlab.mixin.Heterogeneous

    properties(SetAccess=protected)
        Designer
        Tag
    end

    properties(Access=protected)
        TabCache;
    end


    methods
        function this=Simulator(designer)
            this.Designer=designer;
        end

        function clearCaches(~)

        end

        function updateScenario(~,~)

        end

        function tab=getDynamicTabs(this)
            tab=this.TabCache;
            if isempty(tab)&&~isempty(this.Designer.Toolstrip)
                tab=matlab.ui.internal.toolstrip.Tab(getString(message('driving:scenarioApp:SimulationTabName')));
                tab.Tag='simulation';

                tab.add(createSimulationManagerSection(this.Designer.Toolstrip));
                sections=getSections(this);
                for indx=1:numel(sections)
                    tab.add(sections(indx));
                end
            end
        end

        function updateToolstrip(this)
            updateRun(this.Designer.Toolstrip);
        end

        function str=getAgentModelString(this,actorId)
            str='';
        end

        function attach(~)

        end

        function detach(~)

        end

        function s=serialize(~)
            s=[];
        end

        function deserialize(~,~)

        end
    end

    methods(Access=protected)
        function s=getSections(~)
            s=[];
        end
    end

    methods(Sealed)
        function out=findobj(varargin)
            out=findobj@handle(varargin{:});
        end
    end

    
    methods(Abstract)
        run(this)  % 相当于点击图形界面的"运行"
        stop(this)
        pause(this)
        b=isRunning(this)
        b=isStopped(this)
        b=isPaused(this)
        b=canRun(this)
        t=getCurrentTime(this)
        s=getCurrentSample(this)
        t=getStopTime(this)
        l=addStateChangedListener(this,cb)
        l=addSampleChangedListener(this,cb)
        i=getIcon(this)
    end
end


