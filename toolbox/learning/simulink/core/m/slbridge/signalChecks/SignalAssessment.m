
classdef SignalAssessment<handle




















    methods(Static)

        function[max_boundary,min_boundary,boolval]=maskInitFcn(block)

            max_boundary=struct;
            max_boundary.time=SignalCheckUtils.getMaskWSVariable(block,'t_ans');

            min_boundary=struct;
            min_boundary.time=SignalCheckUtils.getMaskWSVariable(block,'t_ans');






            signalType=eval(get_param(block,'signal_type'));
            if isempty(signalType)
                return
            end

            isBooleanSignal=strcmp(get_param(block,'range'),'true');

            if isequal(signalType,'bound')
                max_boundary.signals.values=SignalCheckUtils.getMaskWSVariable(block,'y_ans_upper');
                min_boundary.signals.values=SignalCheckUtils.getMaskWSVariable(block,'y_ans_lower');
                boolval=false;
            elseif isBooleanSignal
                y_nominal=logical(SignalCheckUtils.getMaskWSVariable(block,'y_ans_upper'));

                max_boundary.signals.values=y_nominal;
                min_boundary.signals.values=y_nominal;

                set_param(bdroot(block),'OutputOption','SpecifiedOutputTimes');
                set_param(bdroot(block),'OutputTimes','t_ans');
                boolval=true;
            else
                delta=SignalCheckUtils.getMaskWSVariable(block,'range');
                y_nominal=SignalCheckUtils.getMaskWSVariable(block,'y_ans_upper');
                y_max=y_nominal+delta;
                y_min=y_nominal-delta;
                max_boundary.signals.values=y_max;
                min_boundary.signals.values=y_min;
                boolval=false;
            end

            task=get_param(block,'task');
            log_file_location=fullfile(tempdir,'signalCheck',['task',task,'.mat']);

            set_param([block,'/To File'],'Filename',log_file_location);
            if~exist(fileparts(log_file_location),'dir')
                mkdir(fileparts(log_file_location));
            end

        end

        function openFcn()


        end

        function writeCurrentPlot(block)
            SignalAssessment.updateFigure(block);
        end

        function stopFcn(block)
            SignalAssessment.updateFigure(block);
        end

        function updatePassStatus(block)
            connected=get_param(block,'PortConnectivity');
            if connected.SrcBlock==-1
                set_param(block,'pass','0');
                return
            end

            [input_sig,max_sig,min_sig]=SignalAssessment.getSimulationSignals(block);

            if input_sig.Length~=max_sig.Length




                if input_sig.Length<max_sig.Length
                    interpData=interp1(input_sig.Time,input_sig.Data,max_sig.Time);
                    input_sig=timeseries(interpData,max_sig.Time,'Name','signal');
                end
            end
            badIdx=(input_sig.Data>max_sig.Data)|(input_sig.Data<min_sig.Data);
            badTime=input_sig.Time(badIdx);

            if isempty(badTime)&&~SignalAssessment.isInputShort(block,max_sig)
                set_param(block,'pass','1');
            else
                set_param(block,'pass','0');
            end
        end

        function openSignalInPlotWindow(block)
            SignalAssessment.updateFigure(block,1);
        end

    end

    methods(Static,Access=private)

        function updateFigure(block,varargin)
            isDiscrete=logical(str2double(get_param(block,'rate_type')));

            [fh,ah]=SignalCheckUtils.getFigureHandle(block,varargin{:});
            hold on

            max_boundary=SignalCheckUtils.getMaskWSVariable(block,'max_boundary');
            min_boundary=SignalCheckUtils.getMaskWSVariable(block,'min_boundary');

            [fill_time,fill_signal]=SignalAssessment.boundariesToFill(min_boundary,...
            max_boundary,isDiscrete);

            rangeHandle=plot(ah,fill_time.top,fill_signal.top,'Color',[0.8235,0.4706,0.0353],...
            'LineWidth',1);
            plot(ah,fill_time.bottom,fill_signal.bottom,'Color',[0.8235,0.4706,0.0353],...
            'LineWidth',1);
            fill(ah,[fill_time.top,fill_time.bottom],[fill_signal.top,fill_signal.bottom],...
            [1,1,.88],'LineStyle','none');

            requirementStr=message('learning:simulink:resources:SignalFigureLegendRange').getString();
            signalStr=message('learning:simulink:resources:SignalFigureLegendSignal').getString();
            incorrectStr=message('learning:simulink:resources:SignalFigureLegendIncorrect').getString();

            connected=get_param(block,'PortConnectivity');

            if exist(SignalCheckUtils.getLogFileName(block),'file')&&connected.SrcBlock~=-1
                [input_sig,max_sig,min_sig]=SignalAssessment.getSimulationSignals(block);
                if input_sig.Length>0
                    sampleTimes=get_param(block,'CompiledSampleTime');

                    if iscell(sampleTimes)
                        sampleTimes=[sampleTimes{:}];
                    end
                    if all(sampleTimes==0|sampleTimes==-1)
                        userData=plot(input_sig.Time,input_sig.Data);
                    else
                        userData=stairs(input_sig.Time,input_sig.Data);
                    end
                    hold on

                    if input_sig.Length==max_sig.Length
                        badIdx=(input_sig.Data>max_sig.Data)|(input_sig.Data<min_sig.Data);
                        outOfRange=plot(input_sig.Time(badIdx),input_sig.Data(badIdx),'r.','MarkerSize',10);
                    else
                        badIdx=[];
                    end

                    if sum(badIdx)>0
                        lh=legend([rangeHandle,userData,outOfRange],requirementStr,signalStr,incorrectStr,...
                        'Location','southoutside','Orientation','horizontal');
                    else
                        lh=legend([rangeHandle,userData],requirementStr,signalStr,'Location','southoutside',...
                        'Orientation','horizontal');
                    end

                    userData.Color=[0,0.4431,0.7373];
                    userData.LineWidth=1;
                end
            else
                lh=legend(requirementStr,'Location','southoutside','Orientation','horizontal');
            end

            lh.Box='off';
            lh.Position=[0,0,1,.1];
            lh.ItemTokenSize=[15,18];
            ah.ClippingStyle='rectangle';
            ah.Box='on';
            ah.OuterPosition=[0,.11,1,.89];



            if isequal(eval(get_param(block,'signal_type')),'signal')

                ah.YLim=SignalCheckUtils.calculateYLims(ah);
            end

            xlabel(message('learning:simulink:resources:SignalFigureXAxis').getString());
            ylabel(message('learning:simulink:resources:SignalFigureYAxis').getString());


            if isempty(varargin)
                lh.FontSize=6;
                ah.FontSize=7;

                scopeNumber=str2double(get_param(block,'task'));
                fig_save_location=fullfile(tempdir,'signalCheck',['scope',num2str(scopeNumber),'.png']);
                saveas(fh,fig_save_location);
                close(fh)
            end
        end

        function[input_sig,max_sig,min_sig]=getSimulationSignals(block)
            data=load(SignalCheckUtils.getLogFileName(block));
            data=data.ans;
            input_sig=data.signal;
            max_sig=data.max;
            min_sig=data.min;


            input_sig.Data=reshape(input_sig.Data,[],1);









            isDiscrete=logical(str2double(get_param(block,'rate_type')));
            if~isDiscrete
                if input_sig.Length~=max_sig.Length
                    interpData=interp1(max_sig.Time,max_sig.Data,input_sig.Time);
                    max_sig=timeseries(interpData,input_sig.Time,'Name','max');
                end
                if input_sig.Length~=min_sig.Length
                    interpData=interp1(min_sig.Time,min_sig.Data,input_sig.Time);
                    min_sig=timeseries(interpData,input_sig.Time,'Name','min');
                end
            end
        end

        function[fill_time,fill_signal]=boundariesToFill(min_boundary,max_boundary,rate)


            if rate
                trep_min=[min_boundary.time(2:end-1)';min_boundary.time(2:end-1)'];
                trep_max=[max_boundary.time(2:end-1)';max_boundary.time(2:end-1)'];
                tstair_min=[min_boundary.time(1),trep_min(1:end),min_boundary.time(end)];
                tstair_max=[max_boundary.time(1),trep_max(1:end),max_boundary.time(end)];

                yrep_min=[min_boundary.signals.values(1:end-1)';...
                min_boundary.signals.values(1:end-1)'];
                yrep_max=[max_boundary.signals.values(1:end-1)';...
                max_boundary.signals.values(1:end-1)'];
                ystair_min=yrep_min(1:end);
                ystair_max=yrep_max(1:end);

                fill_time.top=tstair_max;
                fill_time.bottom=fliplr(tstair_min);

                fill_signal.top=ystair_max;
                fill_signal.bottom=fliplr(ystair_min);
            else

                assert(iscolumn(max_boundary.time),'max_boundary.time is not a column');
                assert(iscolumn(min_boundary.time),'min_boundary.time is not a column');
                assert(iscolumn(max_boundary.signals.values),'max_boundary.signals.values is not a column');
                assert(iscolumn(min_boundary.signals.values),'min_boundary.signals.values is not a column');

                fill_time.top=max_boundary.time';
                fill_time.bottom=flipud(min_boundary.time)';
                fill_signal.top=max_boundary.signals.values';
                fill_signal.bottom=flipud(min_boundary.signals.values)';
            end

        end

        function isInputShort=isInputShort(block,AssessmentBlkMaxSig)


            maxSig=SignalCheckUtils.getMaskWSVariable(block,'max_boundary');
            isInputShort=~isequal(maxSig.signals.values(end),AssessmentBlkMaxSig.Data(end));
        end
    end
end
