

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
                message.axesLimits.xMin=0;
                message.axesLimits.xMax=size(dataForScale,1)-1;
                message.signalIDs=signalIDs;
                this.WebscopesStreamingSource.setAxesLimits(message);
            end

            this.WebscopesStreamingSource.write(signalIDs,signalData,plottingMap);
        end
    end
end