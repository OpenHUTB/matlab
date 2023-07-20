

classdef SignalPlotter<handle



    properties(Access=private)
WebscopesStreamingSource
    end

    methods

        function this=SignalPlotter(webscopesStreamingSource)
            this.WebscopesStreamingSource=webscopesStreamingSource;
        end


        function plotSignals(this,signalIDs,signalData,plottingMap,performFitToView)





            if nargin<5
                performFitToView=true;
            end

            if performFitToView
                dataForScale=cell2mat(signalData);
                axesLimits.xMin=0;
                axesLimits.xMax=size(dataForScale,1)-1;
                axesLimits.yMin=min(dataForScale,[],'all');
                axesLimits.yMax=max(dataForScale,[],'all');
                this.WebscopesStreamingSource.setAxesLimits(axesLimits);
            end
            this.WebscopesStreamingSource.write(signalIDs,signalData,plottingMap);
        end
    end
end