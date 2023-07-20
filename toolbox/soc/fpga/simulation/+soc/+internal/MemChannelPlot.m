classdef MemChannelPlot<soc.internal.PerfPlot

    properties

blkPath
numBuffers
numLatencies
ddBlkPaths
samplingIntervalRange
autoSamplingInterval

latencyControls
latencyWindow

        pTitle='Buffer Latencies';
        xLabel='Simulation time (s)';
        yLabel='Latencies (s)';
    end

    methods
        function this=MemChannelPlot(figName,blkPath,numBuffers,ddBlkPaths)
            this@soc.internal.PerfPlot(figName);
            this.blkPath=blkPath;
            this.numBuffers=numBuffers;
            this.numLatencies=3;
            this.ddBlkPaths=ddBlkPaths;
            this.samplingIntervalRange=[0,0];


            latP=this.lm.addLatenciesPanel(this.cPanel);
            this.latencyControls=this.lm.addLatencyControls(latP,'Channel');
            this.numLatencies=numel(this.latencyControls);
            for i=1:this.numLatencies
                set(this.latencyControls(i),'Callback',@this.checkboxCb);
            end

            if isempty(this.ddBlkPaths{1})
                set(this.latencyControls(1),'Visible','off');
            end

            if isempty(this.ddBlkPaths{2})
                set(this.latencyControls(2),'Visible','off');
                set(this.latencyControls(3),'Visible','off');
            end


            avgP=this.lm.addAvgWindowPanel(this.cPanel);
            this.latencyWindow=this.lm.addAvgWindowControls(avgP,message('soc:ui:PlotAvgWindowLbl').getString());


            this.plotB=this.lm.addPlotBtn(this.cPanel);
            this.plotB.Interruptible='off';
            this.plotB.BusyAction='cancel';
            set(this.plotB,'Callback',@this.plotCb);

            helpB=this.lm.addHelpBtn(this.iPanel);
            set(helpB,'Callback',@this.memChannelHelpCb);
            this.updateCurrentPlotInfo();
        end


        function plotCb(this,~,~)
            try
                pargs=this.getPlotterArgs();
                pp=soc.internal.PerformancePlotter(pargs{:});

                set(this.plotB,'Enable','off');
                pp.clearPlot();
                pause(0.1);

                plotDesc=cell([3,1]);
                ticDesc=cell([3,3]);
                tocDesc=cell([3,3]);

                plotDesc(1)={'Memory Channel Write Buffer Latency'};
                ticDesc(1,:)={this.ddBlkPaths{1},'<REGION_BUFFER_EVENT>',DDEvent2.BufRequest};
                tocDesc(1,:)={this.ddBlkPaths{1},'<REGION_BUFFER_EVENT>',DDEvent2.BufDone};

                plotDesc(2)={'Memory Channel Read Buffer Latency'};
                ticDesc(2,:)={this.ddBlkPaths{2},'<REGION_BUFFER_EVENT>',DDEvent2.BufExecuting};
                tocDesc(2,:)={this.ddBlkPaths{2},'<REGION_BUFFER_EVENT>',DDEvent2.BufDone};

                plotDesc(3)={'Memory Channel Read Acknowledge Buffer Latency'};
                ticDesc(3,:)={this.ddBlkPaths{2},'<REGION_BUFFER_EVENT>',DDEvent2.BufDone};
                tocDesc(3,:)={this.ddBlkPaths{2},'<REGION_BUFFER_EVENT>',DDEvent2.BufAck};

                pp.plotChannelLatencyStacked(this.numBuffers,plotDesc,ticDesc,tocDesc);



                this.setPlotTitle(this.pTitle);
                this.updateCurrentPlotInfo();
                this.plotB.String='Update';
            catch ME
                errMsg=message('soc:msgs:ProblemPlottingPerformanceData',...
                ME.message(),...
                message('soc:msgs:StepsToGettingDataMemChannel').getString());
                errordlg(errMsg.getString(),'Error trying to plot data.','modal');
            end
            set(this.plotB,'Enable','on');
        end

        function checkboxCb(this,~,~)

            lat=this.getLatencyControls();
            if any(lat)
                set(this.plotB,'Enable','on');
            else
                set(this.plotB,'Enable','off');
            end
        end
    end

    methods(Access=private)
        function updateCurrentPlotInfo(this)
            str=this.getLatenciesString();
            if isempty(str)
                str={
                message('soc:ui:PlotInfo_MemCh_DefTxt').getString(),...
                newline,...
                message('soc:ui:PlotInfo_HelpTxt').getString()
                };
            end
            this.setCurrentPlotInfo(str);
        end
        function memChannelHelpCb(~,~,~)
            soc.internal.helpview('soc_memorychannelperformanceviewer');
        end

        function str=getLatenciesString(this)
            str='';
            lat=this.getLatencyControls();
            if any(lat)
                latStr='';
                for i=1:this.numLatencies
                    if lat(i)==1
                        latStr=strcat(latStr,',',get(this.latencyControls(i),'String'));
                    end
                end
                latStr=regexprep(latStr,'\s\w+,\w+',',');
                latStr(1)=[];

                str={[
                message('soc:ui:PlotLatenciesLbl').getString(),' ',latStr,'.',...
                newline,...
                newline,...
                message('soc:ui:PlotAvgWindowLbl').getString(),' ',this.getLatencyWindow(),'.',...
                newline,...
                newline,...
                message('soc:ui:PlotInfo_UpdateTxt').getString(),...
                ]};
            end
        end
        function lat=getLatencyControls(this)
            lat=false(1,this.numLatencies);
            for i=1:this.numLatencies
                lat(i)=get(this.latencyControls(i),'Value');
            end
        end
        function wind=getLatencyWindow(this)
            wind=this.latencyWindow.String;
            wind=this.addAutoWindow(wind);
        end
        function wind=addAutoWindow(this,wind)
            switch wind
            case 'auto'
                wind=[wind,' (',mat2str(this.autoSamplingInterval),' s)'];
            case 'min'
                wind=[wind,' (',mat2str(this.samplingIntervalRange(1)),' s)'];
            case 'max'
                wind=[wind,' (',mat2str(this.samplingIntervalRange(2)),' s)'];
            otherwise
                wind=[wind,' (s)'];
            end
        end

        function selected=getSelectedControls(this)
            vals=get(this.latencyControls,'Value');
            selected=logical(cell2mat(vals));
        end
        function window=getDataWindow(this)
            windowStr=get(this.latencyWindow,'String');
            switch windowStr
            case 'auto'
                window=this.autoSamplingInterval;
            case 'min'
                window=this.samplingIntervalRange(1);
            case 'max'
                window=this.samplingIntervalRange(2);
            otherwise
                window=evalin('base',windowStr);
            end
        end
        function pargs=getPlotterArgs(this)
            bp=this.blkPath;
            ddbp=this.ddBlkPaths;
            slvar=soc.blkcb.cbutils('GetSignalLoggingVariable',this.blkPath);

            this.setValidSamplingIntervalRange(slvar);

            cm=this.getSelectedControls();
            si=this.getDataWindow();
            ca=this.hAx;
            hta=[];
            pargs={bp,ddbp,slvar,cm,si,ca,hta};

            if si<this.samplingIntervalRange(1)||si>this.samplingIntervalRange(2)
                error(message('soc:msgs:SamplingIntervalNotInRange',mat2str(this.samplingIntervalRange)));
            end

        end
        function setValidSamplingIntervalRange(this,slvar)
            ddLength=numel(this.ddBlkPaths);
            maxCount=0;
            maxTime=0;
            minAvg=1;
            ds=[];dsElem=[];
            try
                for ii=1:ddLength
                    ddBlk=this.ddBlkPaths{ii};
                    if isempty(ddBlk)
                        continue;
                    end
                    ds=slvar.find('BlockPath',ddBlk);
                    elemName='<bufTransfersCompleted>';
                    dsElem=ds.getElement(elemName);
                    [~,lastTime,count,avgTime]=l_avgTransactionInfo(dsElem);
                    if count>maxCount
                        maxCount=count;
                    end
                    if lastTime>maxTime
                        maxTime=lastTime;
                    end
                    if avgTime<minAvg
                        minAvg=avgTime;
                    end
                end
                if maxCount==0||maxTime==0
                    throw(MException);
                end
                numBuckets=this.numBuffers;
                this.samplingIntervalRange=round([minAvg,maxTime],4,'significant');
                this.autoSamplingInterval=round(min(numBuckets*minAvg,maxTime),4,'significant');
            catch ME
                if isempty(ds)||isempty(dsElem)
                    error(message('soc:msgs:CouldNotFindLoggedMemoryPerformanceData',...
                    'memory channel','<bufTransfersCompleted>',ddBlk).getString());
                elseif maxCount==0||maxTime==0
                    error(message('soc:msgs:NoTransactionsInLoggedData','memory channel'));
                else
                    error(message('soc:msgs:ProblemPlottingPerformanceData','memory channel',ME.message()));
                end
            end
        end
    end
end

function[firstTime,lastTime,count,avgTime]=l_avgTransactionInfo(dsElem)
    elemTS=dsElem.Values;
    count=elemTS.Data(end);
    if count>0
        firstIdx=find(elemTS.Data==1,1);
        lastIdx=find(elemTS.Data==count,1);
        firstTime=elemTS.Time(firstIdx);
        lastTime=elemTS.Time(lastIdx);
        avgTime=(lastTime-firstTime)/count;
    else
        firstTime=0;
        lastTime=0;
        count=0;
        avgTime=Inf;
    end
end