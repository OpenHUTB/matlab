classdef MemControllerPlot<soc.internal.PerfPlot

    properties
cTabGp
cTabs

blkPath
numMasters
numLatencies
ddBlkPaths
samplingIntervalRange
autoSamplingInterval

latencyControls
bandwidthControls
burstControls

bandwidthWindow
burstWindow
latencyWindow
latencyMaster

samplingInt
avgW

        pTitle='Controller Bandwidth';
        xLabel='Simulation time (s)';
        yLabel='Bandwidth(MB/s)';
    end

    properties(Constant)
        minMasters=1;
        maxMasters=12;
    end

    methods
        function this=MemControllerPlot(figName,blkPath,numMasters,ddBlkPaths)
            this@soc.internal.PerfPlot(figName);
            this.blkPath=blkPath;
            this.numMasters=numMasters;
            this.numLatencies=3;
            this.ddBlkPaths=ddBlkPaths;
            this.samplingIntervalRange=[0,0];


            this.cTabGp=uitabgroup(this.cPanel);
            set(this.cTabGp,'SelectionChangedFcn',@this.tabChangedCb);
            this.cTabs{1}=uitab(this.cTabGp,'Title',message('soc:ui:PlotTab1Title').getString(),'Tag','tab1');
            this.cTabs{2}=uitab(this.cTabGp,'Title',message('soc:ui:PlotTab2Title').getString(),'Tag','tab2');
            this.cTabs{3}=uitab(this.cTabGp,'Title',message('soc:ui:PlotTab3Title').getString(),'Tag','tab3');
            this.cTabGp.TabLocation='top';
            this.tabChangedCb(this.cTabGp);

            this.setupBandwidthTab(this.cTabs{1});
            this.setupBurstsTab(this.cTabs{2});
            this.setupLatenciesTab(this.cTabs{3});


            helpB=this.lm.addHelpBtn(this.iPanel);
            set(helpB,'Callback',@this.memControllerHelpCb);
            this.updateCurrentPlotInfo();

        end

        function set.numMasters(this,val)
            validateattributes(val,{'numeric'},{'>=',this.minMasters,'<=',this.maxMasters});
            this.numMasters=val;
        end


        function checkboxCb(this,~,~)
            selectedControls=this.getSelectedControls();
            if any(selectedControls)
                set(this.plotB,'Enable','on');
            else
                set(this.plotB,'Enable','off');
            end
        end

        function plotCb(this,~,~)
            try
                pargs=this.getPlotterArgs();
                pp=soc.internal.PerformancePlotter(pargs{:});

                set(this.plotB,'Enable','off');
                pp.clearPlot();
                pause(0.1);

                switch this.getSelectedTab
                case 'tab1'
                    pp.plotSampledStatistic('Memory Bandwidth Usage','<bytesTransferred>','RateForInterval',1000*1000,'MB/s');
                case 'tab2'
                    pp.plotSampledStatistic('Bursts Executed','<burstTransfersCompleted>','AbsoluteForInterval',1,'Bursts Executed');
                case 'tab3'
                    numPipelines=2;
                    selMaster=this.getSelectedMaster();
                    plotDesc=cell([3,1]);
                    ticDesc=cell([3,3]);
                    tocDesc=cell([3,3]);

                    plotDesc(1)={'Burst Request to First Transfer Latency'};
                    ticDesc(1,:)={'%DDBLOCK%','<BURST_EXECUTION_EVENT>',DDEvent2.BurstRequest};
                    tocDesc(1,:)={'%DDBLOCK%','<BURST_EXECUTION_EVENT>',DDEvent2.BurstExecuting};

                    plotDesc(2)={'Burst Execution Latency'};
                    ticDesc(2,:)={'%DDBLOCK%','<BURST_EXECUTION_EVENT>',DDEvent2.BurstExecuting};
                    tocDesc(2,:)={'%DDBLOCK%','<BURST_EXECUTION_EVENT>',DDEvent2.BurstDone};

                    plotDesc(3)={'Burst Last Transfer to Burst Complete Latency'};
                    ticDesc(3,:)={'%DDBLOCK%','<BURST_EXECUTION_EVENT>',DDEvent2.BurstDone};
                    tocDesc(3,:)={'%DDBLOCK%','<BURST_EXECUTION_EVENT>',DDEvent2.BurstComplete};

                    pp.plotControllerLatencyStacked(selMaster,numPipelines,plotDesc,ticDesc,tocDesc);
                end



                this.setPlotTitle(this.cTabGp.SelectedTab.Title);
                this.updateCurrentPlotInfo();
                this.plotB.String='Update';
                this.hAx.Toolbar.Visible='on';
            catch ME
                errMsg=message('soc:msgs:ProblemPlottingPerformanceData',...
                ME.message(),...
                message('soc:msgs:StepsToGettingDataMemController').getString());
                errordlg(errMsg.getString(),'Error trying to plot data.','modal');
            end
            set(this.plotB,'Enable','on');
        end

        function tabChangedCb(this,tabGp,~)
            this.cPanel.Title=[tabGp.SelectedTab.Title,' ',message('soc:ui:PlotControlsPanelLbl').getString()];
            if~isempty(this.bandwidthControls)&&~isempty(this.burstControls)&&~isempty(this.latencyControls)
                this.checkboxCb();
            end
        end
    end


    methods(Access=private)
        function updateCurrentPlotInfo(this)
            switch(this.getSelectedTab())
            case 'tab1'
                str=this.getBandwidthString();
            case 'tab2'
                str=this.getBurstString();
            case 'tab3'
                str=this.getLatenciesString();
            end
            if isempty(str)
                str={
                message('soc:ui:PlotInfo_MemCont_DefTxt').getString(),...
                newline,...
                message('soc:ui:PlotInfo_HelpTxt').getString()
                };
            end
            this.setCurrentPlotInfo(str);
        end

        function str=getBandwidthString(this)
            str='';
            mast=this.getBandwidthControls();
            if any(mast)
                mastStr='';
                for i=1:this.numMasters
                    if mast(i)==1
                        mastStr=strcat(mastStr,',',num2str(i));
                    end
                end
                mastStr(1)=[];

                str={[
                message('soc:ui:PlotMastersToPlotLbl','s').getString(),' ',mastStr,'.',...
                newline,...
                newline,...
                message('soc:ui:PlotSamplingIntLbl').getString(),' ',this.getBandwidthWindow(),'.',...
                newline,...
                newline,...
                message('soc:ui:PlotInfo_UpdateTxt').getString(),...
                ]};
            end
        end

        function str=getBurstString(this)
            str='';
            mast=this.getBurstControls();
            if any(mast)
                mastStr='';
                for i=1:this.numMasters
                    if mast(i)==1
                        mastStr=strcat(mastStr,',',num2str(i));
                    end
                end
                mastStr(1)=[];
                str={[
                message('soc:ui:PlotMastersToPlotLbl','s').getString(),' ',mastStr,'.',...
                newline,...
                newline,...
                message('soc:ui:PlotSamplingIntLbl').getString(),' ',this.getBurstWindow(),'.',...
                newline,...
                newline,...
                message('soc:ui:PlotInfo_UpdateTxt').getString(),...
                ]};
            end
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
                latStr(1)=[];
                strc=strsplit(latStr,' ');
                latStr=strcat(strc{1},strrep(latStr,strc{1},''));

                str={[
                message('soc:ui:PlotMastersToPlotLbl','').getString(),' ',this.getLatencyMaster(),'.',...
                newline,...
                newline,...
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

        function setupBandwidthTab(this,parentTab)

            mastP=this.lm.addMastersPanel(parentTab,'long');
            this.bandwidthControls=this.lm.addMastersControls(mastP,this.numMasters,'checkboxlist');
            for i=1:numel(this.bandwidthControls)
                set(this.bandwidthControls(i),'Callback',@this.checkboxCb);
            end


            avgP=this.lm.addSamplingIntPanel(parentTab);
            this.bandwidthWindow=this.lm.addAvgWindowControls(avgP,message('soc:ui:PlotSamplingIntLbl').getString(),'auto');


            this.plotB=this.lm.addPlotBtn(this.cPanel);
            this.plotB.Interruptible='off';
            this.plotB.BusyAction='cancel';
            set(this.plotB,'Callback',@this.plotCb);
        end

        function setupBurstsTab(this,parentTab)

            mastP=this.lm.addMastersPanel(parentTab,'long');
            this.burstControls=this.lm.addMastersControls(mastP,this.numMasters,'checkboxlist');
            for i=1:numel(this.burstControls)
                set(this.burstControls(i),'Callback',@this.checkboxCb);
            end


            avgP=this.lm.addSamplingIntPanel(parentTab);
            this.burstWindow=this.lm.addAvgWindowControls(avgP,message('soc:ui:PlotSamplingIntLbl').getString(),'auto');


            this.plotB=this.lm.addPlotBtn(this.cPanel);
            this.plotB.Interruptible='off';
            this.plotB.BusyAction='cancel';
            set(this.plotB,'Callback',@this.plotCb);
        end

        function setupLatenciesTab(this,parentTab)

            mastP=this.lm.addMastersPanel(parentTab,'short');
            this.latencyMaster=this.lm.addMastersControls(mastP,this.numMasters,'dropdownlist');


            latP=this.lm.addLatenciesPanel(parentTab);
            this.latencyControls=this.lm.addLatencyControls(latP,'Controller');
            for i=1:numel(this.latencyControls)
                set(this.latencyControls(i),'Callback',@this.checkboxCb);
            end


            avgP=this.lm.addAvgWindowPanel(parentTab);
            this.latencyWindow=this.lm.addAvgWindowControls(avgP,message('soc:ui:PlotAvgWindowLbl').getString(),'auto');


            this.plotB=this.lm.addPlotBtn(this.cPanel);
            this.plotB.Interruptible='off';
            this.plotB.BusyAction='cancel';
            set(this.plotB,'Callback',@this.plotCb);
        end

        function memControllerHelpCb(~,~,~)
            soc.internal.helpview('soc_memorycontrollerperformanceviewer');
        end

        function tab=getSelectedTab(this)
            tab=this.cTabGp.SelectedTab.Tag;
        end

        function mast=getBandwidthControls(this)
            mast=false(1,this.numMasters);
            for i=1:this.numMasters
                mast(i)=get(this.bandwidthControls(i),'Value');
            end
        end

        function mast=getBurstControls(this)
            mast=false(1,this.numMasters);
            for i=1:this.numMasters
                mast(i)=get(this.burstControls(i),'Value');
            end
        end

        function lat=getLatencyControls(this)
            lat=false(1,this.numLatencies);
            for i=1:this.numLatencies
                lat(i)=get(this.latencyControls(i),'Value');
            end
        end

        function wind=getBandwidthWindow(this)
            wind=this.bandwidthWindow.String;
            wind=this.addAutoWindow(wind);
        end
        function wind=getBurstWindow(this)
            wind=this.burstWindow.String;
            wind=this.addAutoWindow(wind);
        end

        function mast=getLatencyMaster(this)
            mast=char(this.latencyMaster.String(this.latencyMaster.Value));
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
            switch(this.getSelectedTab())
            case 'tab1'
                vals=get(this.bandwidthControls,'Value');
            case 'tab2'
                vals=get(this.burstControls,'Value');
            case 'tab3'
                vals=get(this.latencyControls,'Value');
            end
            if iscell(vals)
                selected=logical(cell2mat(vals));
            else
                selected=logical(vals);
            end
        end
        function window=getDataWindow(this)
            switch(this.getSelectedTab())
            case 'tab1'
                windowStr=get(this.bandwidthWindow,'String');
            case 'tab2'
                windowStr=get(this.burstWindow,'String');
            case 'tab3'
                windowStr=get(this.latencyWindow,'String');
            end
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
        function master=getSelectedMaster(this)

            master=get(findobj(this.cTabs{3},'Tag','masterDropdown'),'Value');
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
            ddLength=length(this.ddBlkPaths);
            maxCount=0;
            maxTime=0;
            minAvg=1;
            ds=[];dsElem=[];
            try
                for ii=1:ddLength
                    ddBlk=this.ddBlkPaths{ii};
                    ds=slvar.find('BlockPath',ddBlk);
                    elemName='<burstTransfersCompleted>';
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
                numBuckets=ceil(maxCount/100);
                this.samplingIntervalRange=round([minAvg,maxTime],4,'significant');
                this.autoSamplingInterval=round(min(numBuckets*minAvg,maxTime),4,'significant');
            catch ME
                if isempty(ds)||isempty(dsElem)
                    error(message('soc:msgs:CouldNotFindLoggedMemoryPerformanceData',...
                    'memory controller','<burstTransfersCompleted>',ddBlk).getString());
                elseif maxCount==0||maxTime==0
                    error(message('soc:msgs:NoTransactionsInLoggedData','memory controller'));
                else
                    error(message('soc:msgs:ProblemPlottingPerformanceData','memory controller',ME.message()));
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
