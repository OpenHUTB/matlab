classdef PerformancePlotter
    properties
BlockPath
DDBlockPaths
SignalLoggingVar
CheckedMasters
CheckedLatencies
SamplingInterval
CurrentAxes
    end
    methods
        function obj=PerformancePlotter(bp,ddbp,slvar,cm,si,ca,hta)
            obj.BlockPath=bp;
            obj.DDBlockPaths=ddbp;
            obj.SignalLoggingVar=slvar;
            obj.CheckedMasters=cm;
            obj.CheckedLatencies=cm;
            obj.SamplingInterval=si;
            obj.CurrentAxes=ca;
        end

        function plotSampledStatistic(obj,plotTitle,statName,statKind,scalingFactor,ylabelStr)

            plotSampledStatisticData(obj,statName,statKind,scalingFactor,ylabelStr);



        end
        function plotControllerLatencyStacked(obj,selectedMaster,numPipelines,plotDesc,ticDesc,tocDesc)

            latLength=numel(obj.CheckedLatencies);

            allT=cell(1,latLength);
            allD=cell(1,latLength);

            for idx=1:latLength
                ticDesc{idx,1}=obj.DDBlockPaths{selectedMaster};
                tocDesc{idx,1}=obj.DDBlockPaths{selectedMaster};
                [allT{idx},allD{idx}]=obj.getLatencyData(numPipelines,ticDesc(idx,:),tocDesc(idx,:));
            end
            obj.plotLatencyData(plotDesc,allT,allD);



        end
        function plotChannelLatencyStacked(obj,numBuffers,plotDesc,ticDesc,tocDesc)

            latLength=numel(obj.CheckedLatencies);

            allT=cell(1,latLength);
            allD=cell(1,latLength);
            emptyIdx=[];

            for idx=1:latLength
                if isempty(ticDesc{idx,1})||isempty(tocDesc{idx,1})
                    emptyIdx=[emptyIdx,idx];
                    continue;
                end
                [allT{idx},allD{idx}]=obj.getLatencyData(numBuffers,ticDesc(idx,:),tocDesc(idx,:));
            end

            if~isempty(emptyIdx)
                [maxCount,maxIdx]=max(cellfun(@numel,allT));
                for idx=emptyIdx
                    allT{idx}=allT{maxIdx};
                    allD{idx}=zeros(1,maxCount);
                end
            end

            obj.plotLatencyData(plotDesc,allT,allD);



        end
        function clearPlot(obj)
            cla(obj.CurrentAxes,'reset');
        end

        function plotLatency(obj,plotDesc,numPipelines,ticDesc,tocDesc)

            [t{1},d{1}]=obj.getLatencyData(numPipelines,ticDesc,tocDesc);
            obj.plotLatencyData(plotDesc,t,d);



        end
        function plotLatencyMulti(obj,plotDesc,numBuffers,ticDesc,tocDesc)

            ddLength=numel(obj.DDBlockPaths);
            for didx=1:ddLength
                ticDesc{1}=obj.DDBlockPaths{didx};
                tocDesc{1}=obj.DDBlockPaths{didx};
                [allT{didx},allD{didx}]=obj.getLatencyData(numBuffers,ticDesc,tocDesc);
            end
            obj.plotLatencyData(plotDesc,allT,allD);



        end
    end

    methods(Access=private)
        function plotSampledStatisticData(obj,statName,statKind,scalingFactor,ylabelStr)
            hold off;

            validatestring(statKind,{'AverageForInterval','RateForInterval','AbsoluteForInterval'});

            ddBlkPaths=obj.DDBlockPaths;
            ddLength=numel(ddBlkPaths);

            statTS(1:ddLength)=timeseries();
            tbeTS(1:ddLength)=timeseries();

            try
                l=obj.SignalLoggingVar;
                for ii=1:ddLength
                    ddBlkPath=ddBlkPaths{ii};
                    ds=l.find('BlockPath',ddBlkPath);
                    statElem=ds.getElement(statName);
                    statTS(ii)=statElem.Values;
                    bcountElem=ds.getElement('<burstTransfersCompleted>');
                    tbeTS(ii)=bcountElem.Values;
                end
            catch ME
                error(message('soc:msgs:CouldNotFindLoggedMemoryPerformanceData',...
                ylabelStr,statName,ddBlkPath));
            end




            unifiedTime=unique(sort(vertcat(statTS(1:end).Time,tbeTS(1:end).Time)));
            tres=obj.SamplingInterval;
            stimes=obj.getUniformSampleTimes([unifiedTime(1),unifiedTime(end)]);












            statd=zeros(numel(stimes),ddLength);
            tbed=zeros(numel(stimes),ddLength);
            for ii=1:ddLength
                statd(:,ii)=obj.resampleData(statTS(ii).Data,statTS(ii).Time,stimes);
                tbed(:,ii)=obj.resampleData(tbeTS(ii).Data,tbeTS(ii).Time,stimes);
            end

            numPorts=ddLength;
            laststat=zeros([numPorts,1]);
            currstat=zeros([numPorts,1]);
            lastbcount=zeros([numPorts,1]);
            currbcount=zeros([numPorts,1]);

            plotd=zeros([numPorts,numel(stimes)]);
            plott=zeros([numel(stimes),1]);

            for ii=1:numel(stimes)

                switch(statKind)
                case{'AverageForInterval'}
                    currstat(1:numPorts,1)=statd(ii,1:numPorts).*tbed(ii,1:numPorts);
                case{'AbsoluteForInterval','RateForInterval'}
                    currstat(1:numPorts,1)=statd(ii,1:numPorts);
                end
                currbcount(1:numPorts,1)=tbed(ii,1:numPorts);

                plotstat=currstat-laststat;
                plotbcount=currbcount-lastbcount;



                switch statKind
                case 'AverageForInterval'
                    plotd(:,ii)=(plotstat(:,1)./plotbcount(:,1))/scalingFactor;
                case 'RateForInterval'
                    plotd(:,ii)=(plotstat(:,1)./tres)/scalingFactor;
                case 'AbsoluteForInterval'
                    plotd(:,ii)=plotstat(:,1)./scalingFactor;
                end
                plott(ii)=stimes(ii);

                laststat=currstat;
                lastbcount=currbcount;
            end


            c=obj.colorValues(ddLength);
            l=obj.legendStrings(ddLength,'');


            plotd=plotd(obj.CheckedMasters,:);
            c=c(obj.CheckedMasters);
            l=l(obj.CheckedMasters);

            maxval=max(max(plotd));

            if(plott(end,1)==0),plott(end,1)=stimes(end);end

            t={plott(:,1)};
            d=plotd';

            if isempty(find(d~=0,1))
                error(message('soc:msgs:PerformanceMetricsEmpty'));
            end


            vd=arrayfun(@(x)(find(d(:,x)~=0)),(1:length(l)),'UniformOutput',false);
            vd=vd(cellfun(@(x)(~isempty(x)),vd));
            firstD=cellfun(@(x)(x(1)),vd);
            lastD=cellfun(@(x)(x(end)),vd);
            maxD=max(cellfun(@(x)(length(x)),vd));
            if firstD>1,firstD=firstD-1;end
            if lastD<length(t{1}),lastD=lastD+1;end
            firstT=min(firstD);
            lastT=max(lastD);
            t={t{1}(firstT:lastT)};
            d=arrayfun(@(x)(d(firstT:lastT,x)),(1:length(l)),'UniformOutput',false);
            d=[d{:}];

            [t,~,unit]=obj.scaleTimeValues(t);


            obj.clearPlot();









            ah=area(t{1},d);

            ahc=arrayfun(@(x)({x}),ah);
            cellfun(@(a,c)(set(a,'FaceColor',c)),ahc,c);

            xlabel(['Simulation time (',unit,')']);
            ylabel(ylabelStr);

            legend(l,'location','southoutside','orientation','horizontal','NumColumns',4);

        end
        function plotLatencyData(obj,plotDesc,t,d)

            if any(cellfun(@(x)(isempty(x)),d))
                error(message('soc:msgs:SomeLatencyMetricsEmpty'));
            end

            numLats=length(d);


            [tinst,dinst]=obj.getOverallInstantaneousLatency(t,d);



            dmm=cellfun(@(tx,dx)(movmean(dx,[obj.SamplingInterval,0],'SamplePoints',tx)),t,d,'UniformOutput',false);







            mint=t{end}(1);
            maxt=t{end}(end);
            [t,dmm]=cellfun(@(tx,dx)(obj.makeUniformXaxis(tx,dx,[mint,maxt])),t,dmm);
            [t,dmm,trimLen]=obj.trimDataToMinLength(t,dmm);




            c=obj.colorValues(numLats);
            numShownLats=length(find(obj.CheckedLatencies));
            t=t(obj.CheckedLatencies);
            dmm=dmm(obj.CheckedLatencies);
            c=c(obj.CheckedLatencies);
            l=plotDesc(obj.CheckedLatencies);





            [dsc,~,du]=obj.scaleTimeValues([dmm,{dinst}]);
            [tsc,~,tu]=obj.scaleTimeValues([t,{tinst}]);


            obj.clearPlot();

            hold on;

            ah=area(tsc{1},reshape(cell2mat(dsc(1:numShownLats)),[trimLen,numShownLats]));
            ahc=arrayfun(@(x)({x}),ah);
            cellfun(@(a,c)(set(a,'FaceColor',c)),ahc,c);


            instColor=[1,0,0];
            instLineColor=[0.6627,0.6627,0.6627,0.050];
            instDotSize=15;
            l(end+1)={'Instantaneous Total Latency'};
            line(tsc{numShownLats+1},dsc{numShownLats+1},'Color',instLineColor);
            sc=scatter(tsc{numShownLats+1},dsc{numShownLats+1},instDotSize,instColor,'filled');




            xlabel(['Simulation Time (',tu,')']);
            ylabel(['Latency (',du,')']);
            legend([ah,sc],l,'location','southoutside','orientation','horizontal','NumColumns',2);
            hold off;
        end
        function[tinst,dinst]=getOverallInstantaneousLatency(obj,t,d)
            numLats=length(d);


            [t,d,numTrans]=obj.trimDataToMinLength(t,d);
            if numTrans>=1
                tinst=t{numLats};
                da=reshape(cell2mat(d),[numTrans,numLats])';
                dinst=arrayfun(@(x)(sum(da(:,x))),(1:numTrans));
            else


                tinst=[];
                dinst=[];
            end
        end
        function[t,d,trimLen]=trimDataToMinLength(obj,t,d)
            dlenAll=cellfun(@(dx)(length(dx)),d,'UniformOutput',false);
            trimLen=min([dlenAll{:}]);
            d=cellfun(@(dx)(dx(1:trimLen)),d,'UniformOutput',false);
            t=cellfun(@(tx)(tx(1:trimLen)),t,'UniformOutput',false);
        end

        function str=legendStrings(obj,numMasters,kind)
            str=arrayfun(@(x)(sprintf('Master %d %s',x,kind)),(1:numMasters),'UniformOutput',false);
        end
        function c=colorValues(~,numPlots)




            c=winter(numPlots);
            c=num2cell(c,2)';

...
...
...
...
...
...
...
...
...
...
...
        end







        function[t,d]=getLatencyData(obj,numPipelines,ticDesc,tocDesc)
            TICIDX=1;
            TOCIDX=2;
            statDesc=[ticDesc;tocDesc];

            statTS(TICIDX:TOCIDX)=timeseries();
            try
                l=obj.SignalLoggingVar;
                for ii=TICIDX:TOCIDX
                    desc=statDesc(ii,:);
                    ds=l.find('BlockPath',desc{1});
                    statElem=ds.getElement(desc{2});
                    statTS(ii)=statElem.Values;
                end
            catch ME
                error(message('soc:msgs:CouldNotFindLoggedMemoryPerformanceData',...
                'latency',desc{2},desc{1}));
            end
            statd=[statTS.Data];
            statt=statTS.Time;

            [plott,plotd,lidx]=extractLatencyData(statt,statd,numPipelines,ticDesc{3},tocDesc{3});

            t=plott(1:lidx);
            d=plotd(1:lidx);

        end


        function[stattU,statdU]=makeUniformXaxis(obj,statt,statd,trange)

            utimes=obj.getUniformSampleTimes([trange(1),trange(end)]);

            nidx=1;
            uidx=1;
            laststat=0;
            currstat=0;
            statdU=zeros([1,length(utimes)]);
            stattU=zeros([1,length(utimes)]);

            for t=utimes
                if nidx>length(statt)
                    currstat=laststat;
                else
                    if(statt(nidx)<=t)

                        while(statt(nidx)<=t)
                            currstat=statd(nidx);
                            nidx=nidx+1;
                            if nidx>length(statt)
                                break;
                            end
                        end
                    else
                        currstat=laststat;
                    end
                end

                statdU(uidx)=currstat;
                stattU(uidx)=t;
                uidx=uidx+1;

                laststat=currstat;




            end
            statdU={statdU};
            stattU={stattU};
        end
        function utimes=getUniformSampleTimes(obj,trange)
            tres=obj.SamplingInterval;
            utimes=(trange(1):tres:(trange(2)+tres));
            if(length(utimes)<2)
                marg0=sprintf('%g',tres);
                marg1=mat2str(trange);
                error(message('soc:msgs:BadPlotTimeResolution',marg0,marg1));
            end
        end

        function[d,expScale,expUnit]=scaleTimeValues(obj,d)
            dmin=min([d{:}]);
            dmax=max([d{:}]);
            drange=dmax-dmin;

            dexp=floor(log10([dmin,dmax]));
            dexp=dexp(~isinf(dexp));
            if isempty(dexp)
                expScale=-12;
            elseif(min(dexp)<-12)

                expScale=-12;
            else
                expScale=min(dexp);
            end


            if expScale<=-10
                expScale=-12;expUnit='ps';
            elseif expScale>=0
                expScale=0;expUnit='s';
            else
                switch expScale
                case num2cell(-9:-7),expScale=-9;expUnit='ns';
                case num2cell(-6:-4),expScale=-6;expUnit='us';
                case num2cell(-3:-1),expScale=-3;expUnit='ms';
                otherwise
                    error('(internal socb) bad scaling exponent for plot data');
                end
            end
            d=cellfun(@(x)(x/10^expScale),d,'UniformOutput',false);
        end

        function rDataVec=resampleData(obj,dataVec,timeVec,rTimeVec)
            rDataVec=zeros(numel(rTimeVec),1);
            didx=1;
            for idx=1:numel(rTimeVec)
                if(didx<=numel(timeVec))&&(timeVec(didx)<=rTimeVec(idx))

                    while(didx<=numel(timeVec))&&(timeVec(didx)<=rTimeVec(idx))
                        rDataVec(idx)=dataVec(didx);
                        didx=didx+1;
                    end
                else
                    if idx>1
                        rDataVec(idx)=rDataVec(idx-1);
                    end
                end
            end
        end

    end
end


