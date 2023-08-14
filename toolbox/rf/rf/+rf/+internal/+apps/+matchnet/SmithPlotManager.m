
classdef SmithPlotManager<rf.internal.apps.matchnet.SinglePlotManager



    properties
        gridOverall(1,1)matlab.ui.container.GridLayout
    end

    methods(Access=public)
        function this=SmithPlotManager(parent)
            this@rf.internal.apps.matchnet.SinglePlotManager(parent);
            this.PlotType='Smith';
        end


        function ui=makePlotOptionsUI(this,parent)
            ui=rf.internal.apps.matchnet.SmithSPlotOptions(parent,this.PlotParameterOptions);
            this.Listeners.ParameterUpdateListener=addlistener(ui,'ParameterOptionChanged',@(h,e)(this.updateParameterOptions(e.NewParameters)));
            this.Listeners.FormatUpdateListener=addlistener(ui,'FormatOptionChanged',@(h,e)(this.updateFormatOptions(e.NewFormat)));
        end

        function clearAxes(this)
            this.myPlot=smithplot(this.myPlot.Parent);
        end

        function setDefaultSelections(this)
            this.PlotParameterOptions={'S11'};
        end
    end

    methods(Access=protected)
        function initializePlot(this)

            this.Parent.Figure.AutoResizeChildren='on';
            this.gridOverall=uigridlayout(this.Parent.Figure,...
            'RowHeight',{'1x','fit'},...
            'ColumnWidth',{'1x'},...
            'Visible',matlab.lang.OnOffSwitchState.off);


            p=uipanel(this.gridOverall);
            p.AutoResizeChildren=matlab.lang.OnOffSwitchState('off');
            this.setDefaultSelections();
            this.myPlot=smithplot(p);
            this.myPlot.hAxes.Interactions=dataTipInteraction;
            pan(this.myPlot.hAxes,'off')


            this.myPlotOptionsPanel=uipanel(this.gridOverall,'Title','Plot Options');
            this.myPlotOptionsUI=this.makePlotOptionsUI(this.myPlotOptionsPanel);

            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.on;
        end

        function calculateFormattedPlotData(this)
            this.myPlotFormattedData=cell(length(this.PlotCircuits)*length(this.PlotParameterOptions)*length(this.PlotFormatOptions),4);
            currentLine=1;
            for j=1:length(this.PlotCircuits)
                for k=1:length(this.PlotParameterOptions)
                    for l=1:max(length(this.PlotFormatOptions),1)
                        this.myPlotFormattedData{currentLine,1}=this.PlotCircuits{j};
                        this.myPlotFormattedData{currentLine,2}=this.PlotParameterOptions{k};
                        if(~isempty(this.PlotFormatOptions))
                            this.myPlotFormattedData{currentLine,3}=this.PlotFormatOptions{l};
                        else
                            this.myPlotFormattedData{currentLine,3}='';
                        end

                        this.myPlotFormattedData{currentLine,4}=[];


                        dataidx=find(strcmp(this.PlotCircuits{j},this.myPlotRawData(:,1)));
                        if(length(dataidx)>1)
                            warning('More than one circuit shares the selected circuit''s name');
                            dataidx=dataidx(1);
                        end


                        rawdata=[];
                        switch(this.PlotParameterOptions{k})
                        case 'S11'

                            rawdata=squeeze(this.myPlotRawData{dataidx,2}.Parameters(1,1,:));
                        case 'S22'
                            rawdata=squeeze(this.myPlotRawData{dataidx,2}.Parameters(2,2,:));
                        end

                        this.myPlotFormattedData{currentLine,4}=rawdata;
                        this.myPlotFormattedData{currentLine,5}=this.myPlotRawData{dataidx,2}.Frequencies;
                        currentLine=currentLine+1;
                    end
                end
            end
        end


        function drawPlot(this)
            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.off;
            data=cell2mat(transpose(this.myPlotFormattedData(:,4)));
            if isempty(this.myPlotFormattedData)
                this.myPlot=smithplot(this.myPlot.Parent);
            else
                freq=cell2mat(transpose(this.myPlotFormattedData(:,5)));
                this.myPlot.replace(freq(:,1),data);
                str=replace(this.myPlotFormattedData(:,2),{'1','2'},...
                {internal.polariCommon.getUTFSubscriptNumber(1,'subscript'),...
                internal.polariCommon.getUTFSubscriptNumber(2,'subscript')});
                this.myPlot.LegendLabels=...
                cellfun(@(x,y)strcat(strcat(x,':'),y),...
                this.myPlotFormattedData(:,1),...
                str,'UniformOutput',false);
                [xdata,~,U]=engunits(this.myPlotRawData{1,2}.Frequencies);
                Z0=this.myPlotRawData{1,2}.Impedance;
                linesinfo=cellfun(@(x)this.myPlot.currentlineinfo(...
                'gamma',x,'Freq',xdata,strcat(U,'Hz'),...
                'None','','',Z0,''),this.myPlot.LegendLabels);
                for nlines=1:length(this.myPlot.hDataLine)
                    set(this.myPlot.hDataLine(nlines),...
                    'UserData',linesinfo(nlines));
                end
            end
            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.on;
        end
    end
end
