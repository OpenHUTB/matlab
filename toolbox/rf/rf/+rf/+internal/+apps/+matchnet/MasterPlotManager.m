



classdef MasterPlotManager<handle



    properties(Access=public)
        myPlotManagers rf.internal.apps.matchnet.SinglePlotManager
        CurrentCircuitNames cell
    end

    properties(Access=protected)



        HighestCount(1,1)double{mustBeNonnegative}=0
    end

    events
CircuitDataRequested
    end

    methods(Access=public)
        function add(this,newManager)

            if(isempty(this.myPlotManagers))
                this.myPlotManagers=newManager;
            elseif(isempty(this.getPlotManagerByTag(newManager.PlotID)))
                this.myPlotManagers(end+1)=newManager;
            else
                error('Cannot add new plot with same tag as previously-added plot');
            end

            this.HighestCount=this.HighestCount+1;


            if(~isempty(this.CurrentCircuitNames))
                data.RequestedCircuits=this.CurrentCircuitNames;
                this.notify('CircuitDataRequested',rf.internal.apps.matchnet.ArbitraryEventData(data));
                this.myPlotManagers(end).updateDisplayedCircuits(this.CurrentCircuitNames);
            end
        end

        function m=getPlotManagerByTag(this,tag)
            for j=1:length(this.myPlotManagers)
                if(strcmp(this.myPlotManagers(j).PlotID,tag))
                    m=this.myPlotManagers(j);return;
                end
            end
            m=[];
        end

        function cnt=highestCount(this)
            cnt=this.HighestCount;
        end
    end


    methods(Access=public)


        function newCircuitsSelected(this,evtdata)

            newCircuits=evtdata.data.CircuitNames;
            this.CurrentCircuitNames=newCircuits;
            for j=1:length(this.myPlotManagers)


                if(~this.myPlotManagers(j).haveCircuits(newCircuits))

                    data.RequestedCircuits=newCircuits;
                    this.notify('CircuitDataRequested',rf.internal.apps.matchnet.ArbitraryEventData(data));
                end


                this.myPlotManagers(j).updateDisplayedCircuits(newCircuits);
            end
        end


        function addCircuitData(this,evtdata)

            cktnames=evtdata.data.CircuitNames;
            sparams=evtdata.data.CircuitSParams;
            perftests=evtdata.data.CircuitFailedPerformanceTests;
            if isfield(evtdata.data,'CircuitNets')
                nets=evtdata.data.CircuitNets;
                compvalues=evtdata.data.CircuitValues;
                centerfreq=evtdata.data.CircuitCenterFreq;
                loadedq=evtdata.data.CircuitLoadedQ;
                sourceZ=evtdata.data.CircuitSrcZ;
                loadZ=evtdata.data.CircuitLoadZ;
                for j=1:length(this.myPlotManagers)
                    this.myPlotManagers(j).addCircuits(cktnames,sparams,...
                    perftests,nets,compvalues,centerfreq,loadedq,sourceZ,loadZ);
                end
            else
                for j=1:length(this.myPlotManagers)
                    this.myPlotManagers(j).addCircuits(cktnames,sparams,...
                    perftests);
                end
            end
        end

        function evalparamsUpdated(this,evtdata)

            for j=1:length(this.myPlotManagers)
                this.myPlotManagers(j).updateActiveEvalparams(evtdata.data);
            end
        end


        function plotClosedCBK(this,e)
            invalidIndices=strcmp(arrayfun(@(x)x.PlotID,this.myPlotManagers),e.Source.UserData);
            delete(this.myPlotManagers(invalidIndices));
            this.myPlotManagers(invalidIndices)=[];
        end
    end
end
