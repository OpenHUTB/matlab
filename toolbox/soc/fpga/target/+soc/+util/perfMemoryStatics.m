classdef perfMemoryStatics<soc.internal.PerfPlot

    properties
cTabGp
cTabs

usedMasters
timeRelative
CheckBoxNames
profileDiag
numMasters
numLatencies

latencyControls
bandwidthControls
burstControls

bandwidthWindow
burstWindow
latencyWindow
latencyMaster
        OverflowStr='';

        pTitle='Controller Bandwidth';
        xLabel='Time (Sec)';
        yLabel='Bandwidth(MB/s)';

        dataOverflow=false;
    end

    properties(Constant)
        minMasters=1;
        maxMasters=12;
    end

    methods
        function this=perfMemoryStatics(figName,usedMasters,profileDiag,timeRelative)
            this@soc.internal.PerfPlot(figName);
            this.timeRelative=timeRelative;
            this.usedMasters=usedMasters;
            this.profileDiag=profileDiag;
            this.CheckBoxNames=insertBefore(usedMasters,'Read',' ');
            this.CheckBoxNames=insertBefore(this.CheckBoxNames,'Write',' ');
            this.numMasters=numel(usedMasters);
            this.numLatencies=3;



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
            set(helpB,'Callback',@this.performanceViewerHelpCb);
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
            this.dataOverflow=false;
            switch this.getSelectedTab
            case 'tab1'
                this.nonLatencyPlot();
            case 'tab2'
                this.nonLatencyPlot();
            case 'tab3'
                this.LatencyPlot();
            end
            this.setPlotTitle(this.cTabGp.SelectedTab.Title);
            this.updateCurrentPlotInfo();
            this.plotB.String='Update';
            this.hAx.Toolbar.Visible='on';
        end
        function nonLatencyPlot(this)
            c=winter(this.numMasters);
            c=num2cell(c,2)';
            switch this.getSelectedTab
            case 'tab1'
                dataIndex=1;
                OverflowIndex=6;
                yleb='Bandwidth (MB/s)';
                typeCtrlName='bandwidthControls';
            otherwise
                dataIndex=2;
                OverflowIndex=7;
                yleb='Bursts Executed';
                typeCtrlName='burstControls';
            end
            plotData=[];
            OverflowFlags=[];
            label={};
            faceCol={};
            timeRel=[];
            this.OverflowStr='';
            for ii=1:this.numMasters
                if(this.(typeCtrlName)(ii).Value)
                    plotData=[plotData,this.bandwidthControls(ii).UserData(:,dataIndex)];
                    OverflowFlags=[OverflowFlags,this.bandwidthControls(ii).UserData(:,OverflowIndex)];
                    label=[label,this.bandwidthControls(ii).String];
                    faceCol=[faceCol,c{ii}];
                    timeRel=[timeRel,this.timeRelative];
                    if~isempty(find(this.bandwidthControls(ii).UserData(:,OverflowIndex)~=0,1))
                        this.OverflowStr=strcat(this.OverflowStr,'''',this.(typeCtrlName)(ii).String,''',',' ');
                    end
                end
            end
            sizeOverflow=size(OverflowFlags);
            if(~isempty(plotData))
                h=area(timeRel,plotData);
                xlim([0,this.timeRelative(end)]);

                arh=arrayfun(@(x)({x}),h);
                cellfun(@(a,faceCol)(set(a,'FaceColor',faceCol)),arh,faceCol);
                hold on;
                x1=[];
                y1=[];
                for ii=1:sizeOverflow(2)
                    idx=find(OverflowFlags(:,ii)==1);
                    x1=this.timeRelative(idx);
                    y1=sum(plotData(idx,1:ii),2);
                    if~isempty(x1)
                        plot(x1,y1,'*','color','m');
                        this.dataOverflow=true;
                    end
                end
                if(this.dataOverflow)
                    label=[label,'Data Overflow'];
                end
                hold off
                legend(label,'location','southoutside','orientation','horizontal','NumColumns',4);
            end
            ylabel(yleb);
            xlabel('Time (sec)');
        end
        function LatencyPlot(this)
            c=winter(3);
            c=num2cell(c,2)';
            selMaster=this.getSelectedMaster();
            selLatencies=this.getSelectedControls();
            plotData=[];
            faceCol={};
            label={};
            OverflowFlags=[];
            relativeTime=[];
            totalLatency=[];
            latencyLegends={'Burst Request to First Transfer Latency',...
            'Burst Execution Latency',...
            'Burst Last Transfer to Burst Complete Latency'};
            this.OverflowStr='';
            TotalData=zeros(numel(this.timeRelative),1);
            for i=1:length(selLatencies)
                totalLatency=[totalLatency,double(this.latencyControls(i).UserData(:,(2*selMaster-1))*10^6)];
                if selLatencies(i)
                    plotData=[plotData,double(this.latencyControls(i).UserData(:,(2*selMaster-1))*10^6)];
                    OverflowFlags=[OverflowFlags,this.latencyControls(i).UserData(:,(2*selMaster))];
                    faceCol=[faceCol,c{i}];
                    label=[label,latencyLegends{i}];
                    if~isempty(find(this.latencyControls(i).UserData(:,(2*selMaster))~=0,1))
                        this.OverflowStr=strcat(this.OverflowStr,'''',this.latencyControls(i).String,''',',' ');
                    end
                end
            end
            totalLatency=sum(totalLatency,2);
            label=[label,'Instantaneous Total Latency'];
            relativeTime=[relativeTime,this.timeRelative];
            sizeOverflow=size(OverflowFlags);
            if(~isempty(plotData))
                h=area(relativeTime,plotData);


                arh=arrayfun(@(x)({x}),h);
                cellfun(@(a,faceCol)(set(a,'FaceColor',faceCol)),arh,faceCol);
                xlim([0,this.timeRelative(end)]);
                hold on
                plot(relativeTime,totalLatency','. r','MarkerSize',10);
                x1=[];
                y1=[];
                for ii=1:sizeOverflow(2)
                    idx=find(OverflowFlags(:,ii)==1);
                    x1=this.timeRelative(idx,1);
                    y1=sum(plotData(idx,1:ii),2);
                    if~isempty(x1)
                        plot(x1,y1,'*','color','m');
                        this.dataOverflow=true;
                    end
                end
                if(this.dataOverflow)
                    label=[label,'Data Overflow'];
                end
                hold off;
                legend(label,'location','southoutside','orientation','horizontal','NumColumns',2);
            end
            ylabel('Latency (\mus)');
            xlabel('Time (sec)');
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
                message('soc:ui:PlotInfo_HelpTxt').getString(),...
                newline};
            end
            if(this.dataOverflow)
                this.OverflowStr(end)='';
                str=[str,...
                message('soc:ui:ProfileDataOverflowLb1',this.OverflowStr).getString(),...
                newline];
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
                message('soc:ui:PlotInfo_UpdateTxt').getString(),...
                newline]};
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
                        latStr=strcat(latStr,',','''',get(this.latencyControls(i),'String'),' ','''');
                    end
                end
                latStr(1)=[];

                str={[
                message('soc:ui:PlotMastersToPlotLbl','').getString(),' ',this.getLatencyMaster(),'.',...
                newline,...
                newline,...
                message('soc:ui:PlotLatenciesLbl').getString(),' ',latStr,'.',...
                newline,...
                message('soc:ui:PlotInfo_UpdateTxt').getString(),...
                newline]};
            end
        end

        function setupBandwidthTab(this,parentTab)

            mastP=this.lm.addMastersPanel(parentTab,'long');
            this.bandwidthControls=this.lm.addMastersControls(mastP,this.numMasters,'checkboxlist');
            for i=1:numel(this.bandwidthControls)

                this.bandwidthControls(i).UserData=[this.profileDiag.(this.usedMasters{i}).Data,this.profileDiag.(this.usedMasters{i}).Overflow];
                set(this.bandwidthControls(i),'Callback',@this.checkboxCb);
            end


            this.plotB=this.lm.addPlotBtn(this.cPanel);
            set(this.plotB,'Callback',@this.plotCb);
        end

        function setupBurstsTab(this,parentTab)

            mastP=this.lm.addMastersPanel(parentTab,'long');
            this.burstControls=this.lm.addMastersControls(mastP,this.numMasters,'checkboxlist');
            for i=1:numel(this.burstControls)

                this.burstControls(i).UserData=[this.profileDiag.(this.usedMasters{i}).Data,this.profileDiag.(this.usedMasters{i}).Overflow];
                set(this.burstControls(i),'Callback',@this.checkboxCb);
            end


            this.plotB=this.lm.addPlotBtn(this.cPanel);
            set(this.plotB,'Callback',@this.plotCb);
        end

        function setupLatenciesTab(this,parentTab)

            mastP=this.lm.addMastersPanel(parentTab,'short');
            this.latencyMaster=this.lm.addMastersControls(mastP,this.numMasters,'dropdownlist');


            latP=this.lm.addLatenciesPanel(parentTab);
            this.latencyControls=this.lm.addLatencyControls(latP,'Controller');




            FtrLtData=[];
            for j=1:1:numel(this.burstControls)
                FtrLtData=[FtrLtData,this.profileDiag.(this.usedMasters{j}).Data(:,3),this.profileDiag.(this.usedMasters{j}).Overflow(:,3)];
            end


            ExeLtData=[];
            for j=1:1:numel(this.burstControls)
                ExeLtData=[ExeLtData,this.profileDiag.(this.usedMasters{j}).Data(:,4),this.profileDiag.(this.usedMasters{j}).Overflow(:,4)];
            end


            CmpLtData=[];
            for j=1:1:numel(this.burstControls)
                CmpLtData=[CmpLtData,this.profileDiag.(this.usedMasters{j}).Data(:,5),this.profileDiag.(this.usedMasters{j}).Overflow(:,5)];
            end

            for i=1:numel(this.latencyControls)
                set(this.latencyControls(i),'Callback',@this.checkboxCb);
            end
            avgLtData=FtrLtData+ExeLtData+CmpLtData;
            this.latencyControls(1).UserData=FtrLtData;
            this.latencyControls(2).UserData=ExeLtData;
            this.latencyControls(3).UserData=CmpLtData;


            this.plotB=this.lm.addPlotBtn(this.cPanel);
            set(this.plotB,'Callback',@this.plotCb);

        end

        function performanceViewerHelpCb(~,~,~)
            soc.internal.helpview('soc_deviceperformanceviewer');
        end

        function tab=getSelectedTab(this)
            tab=this.cTabGp.SelectedTab.Tag;
        end

        function master=getSelectedMaster(this)

            master=get(findobj(this.cTabs{3},'Tag','masterDropdown'),'Value');
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

        function mast=getLatencyMaster(this)
            mast=char(this.latencyMaster.String(this.latencyMaster.Value));
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
    end
end


