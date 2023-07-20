classdef VSWRPlotManager<rf.internal.apps.matchnet.SinglePlotManager




    properties(Access=protected,Constant)

        YLim_abs=[1,10]
    end

    properties
        gridOverall(1,1)matlab.ui.container.GridLayout
    end

    methods(Access=public)
        function this=VSWRPlotManager(parent)
            this@rf.internal.apps.matchnet.SinglePlotManager(parent);
            this.PlotType='VSWR';
        end

        function clearAxes(this)
            cla(this.myPlot)
        end

        function makePlotOptionsUI(~,~)
        end

        function setDefaultSelections(~)
        end
    end

    methods(Access=protected)
        function initializePlot(this)
            this.Parent.Figure.AutoResizeChildren='on';
            this.gridOverall=uigridlayout(this.Parent.Figure,[1,1],...
            'Visible',matlab.lang.OnOffSwitchState.off);
            this.myPlot=uiaxes(this.gridOverall);
            grid(this.myPlot,'on')
            ylabel(this.myPlot,'VSWR_{in}')
            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.on;
        end

        function calculateFormattedPlotData(this)
            this.myPlotFormattedData=cell(length(this.PlotCircuits),2);
            currentLine=1;
            for j=1:length(this.PlotCircuits)
                this.myPlotFormattedData{currentLine,1}=this.PlotCircuits{j};


                dataidx=find(strcmp(this.PlotCircuits{j},this.myPlotRawData(:,1)));
                if(length(dataidx)>1)
                    warning('More than one circuit shares the selected circuit''s name');
                    dataidx=dataidx(1);
                end


                rawdata=vswr(squeeze(this.myPlotRawData{dataidx,2}.Parameters(1,1,:)));

                this.myPlotFormattedData{currentLine,2}=rawdata;
                this.myPlotFormattedData{currentLine,3}=this.myPlotRawData{dataidx,2}.Frequencies;
                currentLine=currentLine+1;
            end
        end

        function drawPlot(this)
            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.off;
            s=settings;
            if isprop(s,'rf')
                axisHasBeenSpecified=s.rf.PlotAxis.UseEngUnits.ActiveValue;
            else
                axisHasBeenSpecified=true;
            end
            formatData=this.myPlotFormattedData;
            if~all(cellfun(@(x)isempty(x),formatData(:,1)))
                freq=cell2mat(transpose(formatData(:,3)));
                if axisHasBeenSpecified
                    [freq,~,freqUnit]=engunits(freq);
                    xlabel(this.myPlot,sprintf('Frequency (%sHz)',freqUnit))
                else
                    xlabel(this.myPlot,horzcat('Frequency (Hz)'))
                end


                data=cell2mat(transpose(formatData(:,2)));
                plot(this.myPlot,freq,data)
                legend(this.myPlot,strrep(formatData(:,1),'_',' '))
            else
                cla(this.myPlot,'reset');
            end

            this.myPlot.YLim=this.YLim_abs;
            hold(this.myPlot,'off');
            grid(this.myPlot,'on')
            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.on;
        end
    end
end
