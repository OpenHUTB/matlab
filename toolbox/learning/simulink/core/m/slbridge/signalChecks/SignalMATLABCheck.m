classdef SignalMATLABCheck<handle


    methods(Static)

        function maskInitFcn(block)

            task=get_param(block,'task');
            log_file_location=fullfile(tempdir,'signalCheck',['task',task,'.mat']);

            set_param([block,'/To File'],'Filename',log_file_location);
            if~exist(fileparts(log_file_location),'dir')
                mkdir(fileparts(log_file_location));
            end

        end

        function openFcn()


        end

        function stopFcn(block)
            SignalMATLABCheck.updateFigure(block);
        end

        function updatePassStatus(block)
            status=SignalMATLABCheck.assessSignal(block);

            if all(status==1)
                set_param(block,'pass','1');
            else
                set_param(block,'pass','0');
            end
        end

        function userSignal=getUserSignal(block)
            if exist(SignalCheckUtils.getLogFileName(block),'file')
                userSignal=SignalMATLABCheck.getSimulationSignals(block);
            else
                userSignal.Time=[0,0];
                userSignal.Data=[NaN,NaN];
            end
        end

        function writeCurrentPlot(block)
            SignalMATLABCheck.updateFigure(block);
        end



        function openSignalInPlotWindow(block)
            SignalMATLABCheck.updateFigure(block,1);
        end

        function[status,requirements]=getRequirements(block)
            evalFunc=get_param(block,'mlfunc');
            evalFunc=evalFunc(2:end-1);

            [status,requirements]=feval(evalFunc,block);

            userData=str2double(get_param(block,'pass'));
            if userData==-1
                status=double(status);
                status(:)=-1;
            end
        end
    end

    methods(Static,Access=private)

        function updateFigure(block,varargin)
            [fh,ah]=SignalCheckUtils.getFigureHandle(block,varargin{:});
            hold on

            customSignalRequirements=SignalMATLABCheck.getSignalRequirements(block);
            sampleTimes=get_param(block,'CompiledSampleTime');

            if iscell(sampleTimes)
                sampleTimes=[sampleTimes{:}];
            end






            noDiscreteRequirements=~any(contains(fields(customSignalRequirements),'Discrete'));

            if all(sampleTimes==0|sampleTimes==-1)||(noDiscreteRequirements)
                reqsHandles=plot(ah,customSignalRequirements(1).Time,customSignalRequirements(1).Signal,...
                'Color',[0.8235,0.4706,0.0353],'LineWidth',1);
                plot(ah,customSignalRequirements(2).Time,customSignalRequirements(2).Signal,...
                'Color',[0.8235,0.4706,0.0353],'LineWidth',1);
            else
                reqsHandles=stairs(ah,customSignalRequirements(1).Time,customSignalRequirements(1).Signal,...
                'Color',[0.8235,0.4706,0.0353],'LineWidth',1);
                stairs(ah,customSignalRequirements(2).Time,customSignalRequirements(2).Signal,...
                'Color',[0.8235,0.4706,0.0353],'LineWidth',1);
            end

            if iscolumn(customSignalRequirements(1).Time)
                fill(ah,[customSignalRequirements(1).Time;flipud(customSignalRequirements(2).Time)],...
                [customSignalRequirements(1).Signal;flipud(customSignalRequirements(2).Signal)],...
                [1,1,.88],'LineStyle','none');
            else
                fill(ah,[customSignalRequirements(1).Time,fliplr(customSignalRequirements(2).Time)],...
                [customSignalRequirements(1).Signal,fliplr(customSignalRequirements(2).Signal)],...
                [1,1,.88],'LineStyle','none');
            end

            requirementStr=message('learning:simulink:resources:SignalFigureLegendRange').getString();
            signalStr=message('learning:simulink:resources:SignalFigureLegendSignal').getString();
            incorrectStr=message('learning:simulink:resources:SignalFigureLegendIncorrect').getString();


            if exist(SignalCheckUtils.getLogFileName(block),'file')
                hold on;

                input_sig=SignalMATLABCheck.getSimulationSignals(block);
                if all(sampleTimes==0|sampleTimes==-1)
                    userSignal=plot(input_sig.Time,input_sig.Data,...
                    'Color',[0,0.4431,0.7373]);
                else
                    userSignal=stairs(input_sig.Time,input_sig.Data,...
                    'Color',[0,0.4431,0.7373]);
                end

                [~,~,badIdx]=SignalMATLABCheck.assessSignal(block);
                if sum(badIdx)>0
                    outOfRangeData=plot(input_sig.Time(badIdx),input_sig.Data(badIdx),'r.','MarkerSize',15);
                    lh=legend([reqsHandles,userSignal,outOfRangeData],requirementStr,signalStr,incorrectStr,...
                    'Orientation','horizontal');
                else
                    lh=legend([reqsHandles,userSignal],requirementStr,signalStr,...
                    'Orientation','horizontal');
                end
            else
                lh=legend(requirementStr);
            end

            lh.Box='off';
            lh.Position=[0,0,1,.1];
            lh.ItemTokenSize=[15,18];
            ah.Box='on';
            scopeNumber=str2double(get_param(block,'task'));

            xlabel(message('learning:simulink:resources:SignalFigureXAxis').getString());
            ylabel(message('learning:simulink:resources:SignalFigureYAxis').getString());

            ah.OuterPosition=[0,.11,1,.89];
            ah.YLim=SignalCheckUtils.calculateYLims(ah);


            if isempty(varargin)
                lh.FontSize=6;
                ah.FontSize=7;
                fig_save_location=fullfile(tempdir,'signalCheck',['scope',num2str(scopeNumber),'.png']);
                saveas(fh,fig_save_location);
                close(fh)
            end
        end
        function customSignalRequirements=getSignalRequirements(block)
            [~,~,~,customSignalRequirements]=SignalMATLABCheck.assessSignal(block);
        end

        function[input_sig]=getSimulationSignals(block)
            data=load(SignalCheckUtils.getLogFileName(block));
            input_sig=data.ans;
        end

        function[status,requirements,badIdx,plotCommands]=assessSignal(block)
            evalFunc=get_param(block,'mlfunc');
            evalFunc=evalFunc(2:end-1);

            try
                [status,requirements,badIdx,plotCommands]=feval(evalFunc,block);
            catch
                status=0;
                requirements={message('learning:simulink:resources:SignalFigureCustomFail').getString()};
            end
        end

    end

end
