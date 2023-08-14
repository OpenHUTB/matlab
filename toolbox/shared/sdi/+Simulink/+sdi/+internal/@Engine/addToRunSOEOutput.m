function signalIDs=addToRunSOEOutput(this,runID,soeOutput,sdi2featVal,varargin)




    signalIDs=[];
    parentID=[];


    if~isempty(soeOutput.SLDVData)
        interface=Simulink.sdi.internal.Framework.getFramework();
        interface.addSLDVRuns(soeOutput.SLDVData);
        return;
    end


    count=1;
    overwrittenRunID=0;
    signalList=[];
    if~isempty(varargin)&&isnumeric(varargin{1})
        overwrittenRunID=varargin{1};
        signalList=varargin{2};
    end


    loweredOutput=Simulink.sdi.internal.SimOutputLower.lower(soeOutput,sdi2featVal);
    if isempty(loweredOutput)
        return;
    end

    if sdi2featVal>1
        loweredOutput=reshape(loweredOutput,numel(loweredOutput),1);








        isComplex=...
        arrayfun(@(x)~isreal(x.DataValues.Data),loweredOutput);
        firstComplexID=find(isComplex,1,'first');
        if isempty(firstComplexID)

            firstComplexID=1;
        end
        ithOutForHier=loweredOutput(firstComplexID);

        expr='\(:,(\w*)\)';
        sigRootSource=regexprep(ithOutForHier.RootSource,expr,'');
        sigRootDataSrc=regexprep(ithOutForHier.rootDataSrc,expr,'');
        sigBlockSource=strrep(ithOutForHier.BlockSource,sprintf('\n'),' ');
        sigBlockSource=strrep(sigBlockSource,sprintf('\r'),' ');
        isSingleOutputSim=~isempty(strfind(sigRootSource,'.find('));
        sigRootSource=helperRegexp(sigRootSource);
        sigRootDataSrc=helperRegexp(sigRootDataSrc);

        rootDataSrcForSignalLabelParsing=sigRootDataSrc;
        signalLabel=ithOutForHier.SignalLabel;
        sigLabelHasDots=~isempty(strfind(signalLabel,'.'));
        if sigLabelHasDots
            signalLabelWithUnderscore=strrep(signalLabel,'.','_');
            rootDataSrcForSignalLabelParsing=strrep(...
            rootDataSrcForSignalLabelParsing,...
            signalLabel,...
            signalLabelWithUnderscore);
            sigRootDataSrc=strrep(sigRootDataSrc,signalLabel,signalLabelWithUnderscore);
        end



        dotsInDataSource=strfind(rootDataSrcForSignalLabelParsing,'.');
        if isSingleOutputSim
            dotsInDataSource(1)=[];
        end
        if~isempty(dotsInDataSource)&&dotsInDataSource(end)==length(rootDataSrcForSignalLabelParsing)
            dotsInDataSource(end)=[];
        end
        if~ithOutForHier.AlwaysUseSignalLabel&&~isempty(dotsInDataSource)&&~sigLabelHasDots
            signalLabel=rootDataSrcForSignalLabelParsing(dotsInDataSource(end)+1:end);
        else
            signalLabel=strtrim(signalLabel);
        end


        if~isempty(ithOutForHier.busesPrefixForLabel)
            signalLabel=ithOutForHier.busesPrefixForLabel;
        end

        newSigID=this.sigRepository.add(...
        this,...
        runID,...
        sigRootSource,...
        ithOutForHier.TimeSource,...
        ithOutForHier.DataSource,...
        ithOutForHier.DataValues,...
        sigBlockSource,...
        ithOutForHier.ModelSource,...
        signalLabel,...
        int32(ithOutForHier.TimeDim),...
        int32(ithOutForHier.SampleDims),...
        int32(ithOutForHier.PortIndex),...
        int32(1),...
        ithOutForHier.SID,...
        ithOutForHier.metaData,...
        [],...
        sigRootDataSrc,...
        ithOutForHier.interpolation,...
        ithOutForHier.Unit);


        if~isempty(ithOutForHier.HierarchyReference)
            this.setSignalHierarchyReference(newSigID,ithOutForHier.HierarchyReference);
        end


        this.setSignalSampleTimeLabel(newSigID,ithOutForHier.SampleTimeString);

        import Simulink.sdi.internal.Util;
        leafSigIDs=int32(Simulink.HMI.findAllLeafSigIDsForThisRoot(this.sigRepository,newSigID));


        for leafIdx=1:length(leafSigIDs)
            leafSigID=leafSigIDs(leafIdx);
            this.sigRepository.addSignal(runID,leafSigID);
        end


        expandedDataValues={};
        isComplex=any(isComplex);
        numChannels=length(loweredOutput);
        for dataIdx=1:numChannels
            dataCol=loweredOutput(dataIdx).DataValues;
            cls=class(dataCol.Data);
            expandedDataValues{end+1}=...
            eval(sprintf('%s(real(dataCol.Data))',cls));%#ok<AGROW>

            if isComplex
                expandedDataValues{end+1}=...
                eval(sprintf('%s(imag(dataCol.Data))',cls));%#ok<AGROW>
            end

            if numChannels>1||isComplex
                dataSrc=loweredOutput(dataIdx).DataSource;
                if isComplex
                    this.sigRepository.setSignalDataSource(leafSigIDs(2*dataIdx-1),sprintf('real(%s)',dataSrc));
                    this.sigRepository.setSignalDataSource(leafSigIDs(2*dataIdx),sprintf('imag(%s)',dataSrc));
                else
                    this.sigRepository.setSignalDataSource(leafSigIDs(dataIdx),dataSrc);
                end
            end
        end

        assert(size(expandedDataValues,2)==length(leafSigIDs));


        for leafIdx=1:length(leafSigIDs)
            leafSigID=leafSigIDs(leafIdx);
            dataValues.Data=expandedDataValues{leafIdx};
            dataValues.Time=ithOutForHier(1).TimeValues;
            this.sigRepository.setSignalDataValues(leafSigID,dataValues);
            if~isempty(ithOutForHier(1).Unit)
                this.sigRepository.setUnit(leafSigID,ithOutForHier(1).Unit);
            end

            if~isempty(ithOutForHier.busesPrefixForLabel)
                this.sigRepository.setLeafBusSignal(leafSigID,ithOutForHier.busesPrefixForLabel);
            end


            if overwrittenRunID&&~isempty(signalList)
                oldSigID=this.sigRepository.findAlignedSignalFromRun(leafSigID,overwrittenRunID);
                if oldSigID
                    clr=this.getSignalLineColor(oldSigID);
                    lineStyle=this.getSignalLineDashed(oldSigID);
                    plts=this.getSignalCheckedPlots(oldSigID);

                    this.setSignalLineColor(leafSigID,clr);
                    this.setSignalLineDashed(leafSigID,lineStyle);

                    if~isempty(plts)
                        this.sigRepository.setSignalChecked(leafSigID,plts);
                        notify(this,'treeSignalPropertyEvent',...
                        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',...
                        leafSigID,true,'checked'));
                    end
                end
            end
        end

        signalIDs=newSigID;
        this.dirty=true;
        return;
    end

    if max(size(loweredOutput))>1
        loweredOutput=reshape(loweredOutput,numel(loweredOutput),1);
        ithOut=loweredOutput(1);
        if isempty(signalList)||count>length(signalList)
            if isempty(ithOut.SignalLabel)
                ithOut.SignalLabel=' ';
            end

            expr='\(:,(\w*)\)';
            ithOut.RootSource=regexprep(ithOut.RootSource,expr,'');
            ithOut.rootDataSrc=regexprep(ithOut.rootDataSrc,expr,'');
            ithOut.BlockSource=strrep(ithOut.BlockSource,sprintf('\n'),' ');
            ithOut.BlockSource=strrep(ithOut.BlockSource,sprintf('\r'),' ');
            ithOut.RootSource=helperRegexp(ithOut.RootSource);
            ithOut.rootDataSrc=helperRegexp(ithOut.rootDataSrc);
            parentID=this.sigRepository.add(this,runID,...
            ithOut.RootSource,...
            ithOut.TimeSource,...
            ithOut.DataSource,...
            ithOut.DataValues,...
            ithOut.BlockSource,...
            ithOut.ModelSource,...
            ithOut.SignalLabel,...
            int32(ithOut.TimeDim),...
            int32(ithOut.SampleDims),...
            int32(ithOut.PortIndex),...
            int32(ithOut.Channel),...
            ithOut.SID,...
            ithOut.metaData,...
            [],...
            ithOut.rootDataSrc,...
            ithOut.interpolation,...
            ithOut.Unit);
            signalIDs=[signalIDs,parentID];
        else
            parentID=signalList(count);
            signalIDs=[signalIDs,parentID];
            count=count+1;
            this.sigRepository.setSignalDataValues(parentID,ithOut.DataValues);
        end
        this.dirty=true;
    end

    for i=1:length(loweredOutput)
        if(max(size(loweredOutput))>1&&i==1)
            continue;
        end


        ithOut=loweredOutput(i);

        if isempty(signalList)||count>length(signalList)
            if isempty(ithOut.SignalLabel)
                ithOut.SignalLabel=' ';
            end

            expr='\(:,(\w*)\)';
            ithOut.RootSource=regexprep(ithOut.RootSource,expr,'');
            ithOut.rootDataSrc=regexprep(ithOut.rootDataSrc,expr,'');
            ithOut.BlockSource=strrep(ithOut.BlockSource,sprintf('\n'),' ');
            ithOut.BlockSource=strrep(ithOut.BlockSource,sprintf('\r'),' ');
            ithOut.RootSource=helperRegexp(ithOut.RootSource);
            ithOut.rootDataSrc=helperRegexp(ithOut.rootDataSrc);

            newSignalID=this.sigRepository.add(this,runID,...
            ithOut.RootSource,...
            ithOut.TimeSource,...
            ithOut.DataSource,...
            ithOut.DataValues,...
            ithOut.BlockSource,...
            ithOut.ModelSource,...
            ithOut.SignalLabel,...
            int32(ithOut.TimeDim),...
            int32(ithOut.SampleDims),...
            int32(ithOut.PortIndex),...
            int32(ithOut.Channel),...
            ithOut.SID,...
            ithOut.metaData,...
            parentID,...
            ithOut.rootDataSrc,...
            ithOut.interpolation,...
            ithOut.Unit);
        else
            newSignalID=signalList(count);
            this.sigRepository.setSignalDataValues(newSignalID,ithOut.DataValues);
            count=count+1;
        end


        signalIDs=[signalIDs,newSignalID];%#ok
    end
    if~isempty(signalIDs)
        this.dirty=true;
    end
end


function rootSrc=helperRegexp(rootSrc)
    [substr,sind,eind]=regexp(rootSrc,'find\(''[^)]*\'')',...
    'match','start','end');%#ok
    toRemoveInds=zeros(length(sind)*8,1);
    for j=1:length(sind)
        startInd=sind(j);
        endInd=eind(j);
        toRemoveInds(8*j-7:8*j)=[startInd:startInd+5,endInd-1:endInd];
    end
    rootSrc(toRemoveInds)='';
end


