classdef CartesianPlotManager<rf.internal.apps.matchnet.SinglePlotManager




    properties(Access=protected)

        YLim_dB=[-20,0]
        YLim_abs=[0,1]
    end

    properties
        gridOverall(1,1)matlab.ui.container.GridLayout
    end

    methods(Access=public)
        function this=CartesianPlotManager(parent)
            this@rf.internal.apps.matchnet.SinglePlotManager(parent);
            this.PlotType='Cartesian';
        end


        function ui=makePlotOptionsUI(this,parent)
            ui=rf.internal.apps.matchnet.SParameterPlotOptions_2(parent,this.PlotParameterOptions,this.PlotFormatOptions);
            this.Listeners.ParameterUpdateListener=addlistener(ui,'ParameterOptionChanged',@(h,e)(this.updateParameterOptions(e.NewParameters)));
            this.Listeners.FormatUpdateListener=addlistener(ui,'FormatOptionChanged',@(h,e)(this.updateFormatOptions(e.NewFormat)));
        end

        function clearAxes(this)
            cla(this.myPlot)
        end

        function setDefaultSelections(this)
            this.PlotParameterOptions={'S11','S21'};
            this.PlotFormatOptions={'magdB'};
        end
    end

    methods(Access=protected)
        function initializePlot(this)

            this.Parent.Figure.AutoResizeChildren='on';
            this.gridOverall=uigridlayout(this.Parent.Figure,...
            'RowHeight',{'1x'},'ColumnWidth',{'1x','fit'},...
            'Visible',matlab.lang.OnOffSwitchState.off);


            this.myPlot=uiaxes(this.gridOverall);
            this.myPlot.Layout.Column=1;
            grid(this.myPlot,'on')
            this.setDefaultSelections();


            this.myPlotOptionsPanel=uipanel(this.gridOverall,'Title',...
            'Plot Options');
            this.myPlotOptionsPanel.Layout.Column=2;
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
                        case 'S21'
                            rawdata=squeeze(this.myPlotRawData{dataidx,2}.Parameters(2,1,:));
                        case 'S12'
                            rawdata=squeeze(this.myPlotRawData{dataidx,2}.Parameters(1,2,:));
                        case 'S22'
                            rawdata=squeeze(this.myPlotRawData{dataidx,2}.Parameters(2,2,:));
                        end

                        if(isempty(this.PlotFormatOptions))
                            formattedData=rawdata;
                            formattedYLabel='rawdata';
                        else
                            switch(this.PlotFormatOptions{l})
                            case 'magdB'
                                formattedData=20*log10(abs(rawdata));
                                formattedYLabel='Magnitude (dB)';
                            case 'magabs'
                                formattedData=abs(rawdata);
                                formattedYLabel='Magnitude';
                            case 'phase'
                                formattedData=rad2deg(angle(rawdata));
                                formattedYLabel='Angle (degrees)';
                            case 'real'
                                formattedData=real(rawdata);
                                formattedYLabel='Re(S-parameters)';
                            case 'imaginary'
                                formattedData=imag(rawdata);
                                formattedYLabel='Im(S-parameters)';
                            end
                        end

                        this.myPlotFormattedData{currentLine,4}=formattedData;
                        this.myPlotFormattedData{currentLine,5}=formattedYLabel;
                        this.myPlotFormattedData{currentLine,6}=this.myPlotRawData{dataidx,2}.Frequencies;
                        currentLine=currentLine+1;
                    end
                end
            end
        end

        function drawPlot(this)
            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.off;
            hold(this.myPlot,'on');




            s=settings;
            if isprop(s,'rf')
                axisHasBeenSpecified=s.rf.PlotAxis.UseEngUnits.ActiveValue;
            else
                axisHasBeenSpecified=true;
            end
            formatData=this.myPlotFormattedData;
            axisType=0;
            if~all(cellfun(@(x)isempty(x),formatData(:,3)))
                freq=cell2mat(transpose(formatData(:,6)));
                if axisHasBeenSpecified
                    [freq,E,freqUnit]=engunits(freq);
                end
                axisType=all(strcmp(formatData(:,3),'magabs'))||...
                all(strcmpi(formatData(:,3),'magdb'))||...
                all(strcmp(formatData(:,3),'phase'))||...
                all(strcmp(formatData(:,3),'real'))||...
                all(strcmp(formatData(:,3),'imaginary'));
                if axisType

                    if length(this.myPlot.YAxis)==2
                        cla(this.myPlot,'reset')
                    end
                    data=cell2mat(transpose(formatData(:,4)));
                    plot(this.myPlot,freq,data)
                    ylabel(this.myPlot,formatData{1,5})
                    this.myPlot.UserData=formatData{1,3};
                    legend(this.myPlot,strrep(formatData(:,1),'_',' ')+":"+...
                    strrep(formatData(:,2),'S','S_{')+"}")
                else

                    if~isempty(this.myPlot.UserData)&&...
                        strcmp(this.myPlot.UserData,formatData{2,3})
                        order=["right","left"];
                    else
                        order=["left","right"];
                    end
                    cla(this.myPlot,'reset')
                    data=cell2mat(transpose(formatData(1:2:end,4)));
                    freq=cell2mat(transpose(formatData(1:2:end,6)));
                    if axisHasBeenSpecified
                        [freq,E,freqUnit]=engunits(freq);
                    end
                    yyaxis(this.myPlot,order(1))
                    plot(this.myPlot,freq,data)
                    ylabel(this.myPlot,formatData{1,5})

                    data=cell2mat(transpose(formatData(2:2:end,4)));
                    freq=cell2mat(transpose(formatData(2:2:end,6)));
                    if axisHasBeenSpecified
                        [freq,E,freqUnit]=engunits(freq);
                    end
                    yyaxis(this.myPlot,order(2))
                    plot(this.myPlot,freq,data)
                    ylabel(this.myPlot,formatData{2,5})
                    legend(this.myPlot,...
                    strrep([formatData(1:2:end,1);formatData(2:2:end,1)],'_',' ')+":"+...
                    strrep([formatData(1:2:end,2);formatData(2:2:end,2)],'S','S_{')+"}")
                end
                if axisHasBeenSpecified
                    xlabel(this.myPlot,sprintf('Frequency (%sHz)',freqUnit))
                else
                    xlabel(this.myPlot,horzcat('Frequency (Hz)'))
                end
            else
                cla(this.myPlot,'reset');
            end
            grid(this.myPlot,'on')



            dataidx=arrayfun(@(j)find(strcmp(this.PlotCircuits{j},this.myPlotRawData(:,1))),1:length(this.PlotCircuits));


            if~isempty(this.ActiveEvalparams)&&~isempty(dataidx)&&axisType
                for m=1:length(this.ActiveEvalparams.Parameter)
                    x=this.ActiveEvalparams.Band{m}(1);
                    w=this.ActiveEvalparams.Band{m}(2)-this.ActiveEvalparams.Band{m}(1);
                    if axisHasBeenSpecified
                        x=this.ActiveEvalparams.Band{m}*E;
                        w=x(2)-x(1);
                        x=x(1);
                    end

                    if(any(strcmp(this.PlotFormatOptions,'magabs')))
                        curGoal=10^(this.ActiveEvalparams.Goal{m}/20);
                        h=curGoal;
                    end

                    if(any(strcmp(this.PlotFormatOptions,'magdB')))
                        curGoal=this.ActiveEvalparams.Goal{m};
                        h=max(abs(min(data,[],'all')),100);
                    end


                    if(~exist('curGoal','var'))
                        continue
                    end

                    if isinf(h)
                        h=100;
                    end

                    if(strcmp(this.ActiveEvalparams.Comparison{m},'>'))
                        y=curGoal-h;
                    else
                        y=curGoal;
                    end
                    performanceTestsFailed=this.myPlotRawData(dataidx,3);
                    if(strcmp(this.ActiveEvalparams.Parameter{m},'gammain'))

                        if(any(cellfun(@(x)any(x==m),performanceTestsFailed)))
                            color=[1,0,0,0.5];
                        else
                            color=[0,1,1,0.5];
                        end
                    else
                        if(any(cellfun(@(x)any(x==m),performanceTestsFailed)))
                            color=[1,0.65,0,0.5];
                        else
                            color=[0,1,0,0.5];
                        end
                    end

                    rectangle(this.myPlot,'Position',[x,y,w,h],...
                    'FaceColor',color);
                end
                this.YLim_dB(1)=min(min(cell2mat(this.ActiveEvalparams.Goal))-10,...
                this.YLim_dB(1));
            end




            if length(this.myPlot.YAxis)==2
                for k=[1,2]
                    if strcmp(this.myPlot.YAxis(k).Label,'magdB')
                        this.myPlot.YAxis(k).Limits=this.YLim_dB;
                    elseif strcmp(this.myPlot.YAxis(k).Label,'magabs')
                        this.myPlot.YAxis(k).Limits=this.YLim_abs;
                    else
                        this.myPlot.YAxis(k).Limits=[-inf,inf];
                    end
                end
            else
                if(any(strcmp(this.PlotFormatOptions,'magdB')))
                    this.myPlot.YLim=this.YLim_dB;
                elseif(any(strcmp(this.PlotFormatOptions,'magabs')))
                    this.myPlot.YLim=this.YLim_abs;
                else
                    this.myPlot.YLim=[-inf,inf];
                end
            end
            hold(this.myPlot,'off');
            this.gridOverall.Visible=matlab.lang.OnOffSwitchState.on;
        end
    end
end
