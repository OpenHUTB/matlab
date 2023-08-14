function SpectrumAnalyzerBlock(obj)





    if isR2018bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AveragingMethod:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ForgettingFactor:remove>>');
    end


    if isR2018aOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SpectrogramChannel:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><MeasurementChannel:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><PeakFinder:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><CursorMeasurements:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ChannelMeasurements:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><DistortionMeasurements:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><CCDFMeasurements:remove>>');
    end

    if isR2017bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><InputDomain:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FrequencyVector:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FrequencyVectorSource:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><InputUnits:remove>>');

        saBlks=find_scopes(obj);
        for jndx=1:numel(saBlks)


            changeBlockToEmptySubsystemIfFrequencyDomain(obj,saBlks{jndx},obj.modelName);
        end

    end

    if isR2017aOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AxesScaling:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AxesScalingNumUpdates:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><CustomWindow:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FullScaleSource:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><FullScale:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><Method:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><NumTapsPerBand:remove>>');

        saBlks=find_scopes(obj);
        for jndx=1:numel(saBlks)

            changeCustomWindow(saBlks{jndx},obj.origModelName);

            changedBFSTodBm(saBlks{jndx},obj.origModelName);


            changeBlockToEmptySubsystemIfFilterBank(obj,saBlks{jndx},obj.modelName);
        end
    end

    if isR2016bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ViewType:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><AxesLayout:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SpectrumUnits:remove>>');

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><RMSUnits:remove>>');


        saBlks=find_scopes(obj);
        for jndx=1:numel(saBlks)
            changeSpectrumTypeAndAxesProps(saBlks{jndx},obj.origModelName);
        end
    end

    if isR2016aOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><SpectralMaskProperties:remove>>');
    end

    if isR2015bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><NumInputPorts:remove>>');



        saBlks=find_scopes(obj);
        for jndx=1:numel(saBlks)
            [~,origBlock]=strtok(saBlks{jndx},'/');
            parentSys=get_param(saBlks{jndx},'Parent');
            numInputPorts=get_param([obj.origModelName,origBlock],'NumInputPorts');
            if str2double(numInputPorts)>1
                currBlk=saBlks{jndx};


                saPorts=get_param(currBlk,'PortHandles');
                hLines=-ones(length(saPorts.Inport),1);
                hLineSrcPort=-ones(length(saPorts.Inport),1);
                for indx=1:length(saPorts.Inport)
                    hLines(indx)=get_param(saPorts.Inport(indx),'Line');
                    if hLines(indx)~=-1
                        hLineSrcPort(indx)=get_param(hLines(indx),'SrcPortHandle');
                    end
                end


                set_param(currBlk,'NumInputPorts','1');


                pos=get_param(currBlk,'Position');
                concatPos=pos;
                saPos=pos;
                switch get_param(currBlk,'Orientation')
                case 'up'
                    saPos=pos-[0,30,0,30];
                    concatPos(2)=concatPos(4)-10;
                case 'down'
                    saPos=pos+[0,30,0,30];
                    concatPos(4)=concatPos(2)+10;
                case 'left'
                    saPos=pos-[30,0,30,0];
                    concatPos(1)=concatPos(3)-10;
                case 'right'
                    saPos=pos+[30,0,30,0];
                    concatPos(3)=concatPos(1)+10;
                end
                set_param(currBlk,'Position',saPos);





                load_system('dspmtrx3');
                concatBlk=add_block('dspmtrx3/Matrix Concatenate',...
                [currBlk,'_MatrixConcatenator'],...
                'MakeNameUnique','on',...
                'ShowName','off',...
                'NumInputs',numInputPorts,...
                'Mode','Multidimensional array',...
                'ConcatenateDimension','2',...
                'Orientation',get_param(currBlk,'Orientation'),...
                'Position',concatPos);





                concatPorts=get_param(concatBlk,'PortHandles');
                for indx=1:length(concatPorts.Inport)
                    if hLines(indx)~=-1
                        hLine_Concat=get_param(concatPorts.Inport(indx),'Line');
                        if hLineSrcPort(indx)~=-1




                            if hLine_Concat==-1||...
                                ~isequal(get_param(hLine_Concat,'SrcPortHandle'),hLineSrcPort(indx))
                                lineName=get_param(hLines(indx),'Name');
                                delete_line(hLines(indx));
                                newLine=add_line(parentSys,hLineSrcPort(indx),...
                                concatPorts.Inport(indx),'autorouting','on');
                                set_param(newLine,'Name',lineName);
                            end
                        else


                            delete_line(hLines(indx));
                        end
                    end
                end


                saPorts=get_param(currBlk,'PortHandles');
                add_line(parentSys,concatPorts.Outport(1),saPorts.Inport(1),...
                'autorouting','on');
            end
        end
    end

    if isR2014aOrEarlier(obj.ver)
        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ScopeSpecificationString:remove>>');

        saBlks=find_scopes(obj);
        for jndx=1:numel(saBlks)
            scopeSpec=get_param(saBlks{jndx},'ScopeSpecificationObject');
            if~isempty(scopeSpec)

                scopeSpec=copy(scopeSpec);

                set_param(saBlks{jndx},...
                'ScopeSpecification',scopeSpec,...
                'ScopeSpecificationObject',scopeSpec);
                scopeSpec.SaveAsString=false;
                if isempty(scopeSpec.ScopeCLI)
                    scopeSpec.ScopeCLI=uiscopes.ScopeCLI;
                end
                if~isempty(scopeSpec.CurrentConfiguration)
                    cc=scopeSpec.CurrentConfiguration.Children;
                    for indx=1:numel(cc)
                        if isempty(cc(indx).PropertySet)
                            cc(indx).PropertySet=extmgr.PropertySet;
                        end
                    end
                end
            end
        end
    end

    if isR2013aOrEarlier(obj.ver)


        origsaBlks_core=find_system(obj.origModelName,...
        'LookUnderMasks','on',...
        'IncludeCommented','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType','SpectrumAnalyzer');
        origsaBlks_viewers=find_system(obj.origModelName,...
        'IncludeCommented','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'AllBlocks','on','IOType','viewer',...
        'BlockType','SpectrumAnalyzer');
        origsaBlks={origsaBlks_core{:},origsaBlks_viewers{:}};%#ok<CCAT>
        saBlks_core=find_system(obj.modelName,...
        'LookUnderMasks','on',...
        'IncludeCommented','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType','SpectrumAnalyzer');
        saBlks_viewers=find_system(obj.modelName,...
        'IncludeCommented','on',...
        'AllBlocks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'IOType','viewer',...
        'BlockType','SpectrumAnalyzer');
        allCDBlks={saBlks_core{:},saBlks_viewers{:}};%#ok<CCAT>
        for jndx=1:length(allCDBlks)
            scope=scopeextensions.ScopeBlock.getInstanceForCoreBlock(allCDBlks{jndx});

            ud=get_param(allCDBlks{jndx},'UserData');


            try
                if isempty(ud)
                    ud=struct;
                end
                if~isempty(scope)
                    ud.Scope=scope;
                    scopeCfg=get_param(origsaBlks{jndx},'ScopeSpecification');
                    if~isempty(scopeCfg)
                        scope.pScopeCfg=copy(scopeCfg);
                    end
                    if~isempty(scope.ScopeCfg)
                        scope.ScopeCfg.SaveAsString=false;
                    end
                    set_param(allCDBlks{jndx},'UserData',ud,'UserDataPersistent','on');
                end
            catch

            end


            set_param(allCDBlks{jndx},'DestroyFcn','');
            scope=scopeextensions.ScopeBlock.getInstance(allCDBlks{jndx});
            oldConfig=scope.ScopeCfg.CurrentConfiguration;
            if~isempty(oldConfig)
                for indx=1:numel(oldConfig.Children)
                    convertPropertySetToOldFormat(oldConfig.Children(indx));
                end
            end
        end


        obj.appendRule('<Block<BlockType|SpectrumAnalyzer><ScopeSpecification:remove>>');

    end

    if isR2012bOrEarlier(obj.ver)


        if~isempty(allCDBlks)

            allCDBlks=cell(2,1);
            allCDBlks{1}=saBlks_core;
            allCDBlks{2}=saBlks_viewers;
            viewer=2;

            if isR2006bOrEarlier(obj.ver)

                MaskVariables='YUnits=@1;numAvg=@2;wintypeSpecScope=@3;RsSpecScope=@4;betaSpecScope=@5;XRange=@6;AxisGrid=@7;AxisLegend=@8;Memory=@9;inpFftLenInherit=@10;FFTlength=@11;YLabel=&12;YMin=@13;YMax=@14;UseBuffer=@15;BufferSize=@16;Overlap=@17;FigPos=@18;winsampSpecScope=@19;';
            elseif isR2007bOrEarlier(obj.ver)

                MaskVariables='YUnits=@1;numAvg=@2;wintypeSpecScope=@3;RsSpecScope=@4;betaSpecScope=@5;XRange=@6;AxisGrid=@7;AxisLegend=@8;Memory=@9;inpFftLenInherit=@10;FFTlength=@11;YLabel=&12;YMin=@13;YMax=@14;XLimit=@15;XMin=@16;XMax=@17;UseBuffer=@18;BufferSize=@19;Overlap=@20;FigPos=@21;winsampSpecScope=@22;';
            elseif isR2010bOrEarlier(obj.ver)
                MaskVariables='YUnits=@1;numAvg=@2;wintypeSpecScope=@3;RsSpecScope=@4;betaSpecScope=@5;XRange=@6;AxisGrid=@7;AxisLegend=@8;Memory=@9;inpFftLenInherit=@10;FFTlength=@11;YLabel=&12;YMin=@13;YMax=@14;XLimit=@15;XMin=@16;XMax=@17;UseBuffer=@18;BufferSize=@19;Overlap=@20;FigPos=@21;winsampSpecScope=@22;XDisplay=@23;';
            else
                MaskVariables='YUnits=@1;numAvg=@2;wintypeSpecScope=@3;RsSpecScope=@4;betaSpecScope=@5;XRange=@6;AxisGrid=@7;AxisLegend=@8;Memory=@9;inpFftLenInherit=@10;FFTlength=@11;YLabel=&12;YMin=@13;YMax=@14;XLimit=@15;XMin=@16;XMax=@17;UseBuffer=@18;BufferSize=@19;Overlap=@20;FigPos=@21;winsampSpecScope=@22;XDisplay=@23;TreatMby1Signals=@24;isFrameUpgraded=@25';
            end


            for cdIdx=1:2

                if~isempty(allCDBlks{cdIdx})
                    saBlks=allCDBlks{cdIdx};
                else
                    continue;
                end



                if cdIdx==viewer


                    lib_mdl=obj.getTempViewerLib;
                else
                    lib_mdl=getTempLib(obj);
                end

                libBlock=[lib_mdl,'/',obj.generateTempName];




                set_param(lib_mdl,'LibraryType','BlockLibrary');
                add_block('built-in/S-Function',libBlock);

                if cdIdx==viewer
                    set_param(lib_mdl,'LibraryType','ssMgrViewerLibrary');
                    set_param(libBlock,'IOType','viewer');
                end


                set_param(libBlock,...
                'Mask','on',...
                'MaskVariables',MaskVariables,...
                'MaskType','Spectrum Scope');


                pmask=Simulink.Mask.get(libBlock);
                y=pmask.getParameter('XRange');
                y.Evaluate='off';
                if~isR2010bOrEarlier(obj.ver)
                    y=pmask.getParameter('TreatMby1Signals');
                    y.Evaluate='off';
                end


                save_system(lib_mdl);



                sfuncBlock=libBlock;
                for i=1:length(saBlks)
                    blk=saBlks{i};


                    params={'Orientation','Position','FigPos'};
                    paramValues=cell(size(params));
                    paramValues{1}=get_param(blk,params{1});
                    paramValues{2}=get_param(blk,params{2});
                    s=get_param(blk,'ScopeConfiguration');
                    paramValues{3}=sprintf('[%s]',num2str(s.Position));


                    if~isR2012aOrEarlier(obj.ver)
                        commented=get_param(blk,'Commented');
                    end




                    ud=get_param(blk,'UserData');


                    [newParamsNames,newParamsValues]=convertParameters(obj,blk,ud);

                    ud.Scope=[];
                    set_param(blk,'UserData',ud);

                    if cdIdx==viewer
                        IOSignals=get_param(blk,'IOSignals');
                    end


                    delete_block(blk);


                    add_block(sfuncBlock,blk);


                    for j=1:length(params)
                        set_param(blk,params{j},paramValues{j});
                    end
                    for j=1:length(newParamsNames)
                        set_param(blk,newParamsNames{j},newParamsValues{j});
                    end


                    if~isR2012aOrEarlier(obj.ver)
                        set_param(blk,'Commented',commented);
                    end

                    if cdIdx==viewer
                        set_param(blk,'IOSignals',IOSignals);
                    end

                end


                newRef=sfuncBlock;

                if cdIdx==viewer
                    oldRef='dspviewers/Spectrum\nScope';
                else
                    oldRef='dspsnks4/Spectrum\nScope';
                end

                obj.appendRule(['<Block<SourceBlock|"',newRef,'":repval "',oldRef,'">>']);

            end
        end

    end
end

function[newParamsNames,newParamsValues]=convertParameters(obj,blk,ud)

    index=1;


    newParamsNames{index}='numAvg';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Spectrum','SpectralAverages');

    index=index+1;


    newParamsNames{index}='wintypeSpecScope';
    winType=ud.Scope.getScopeParam('Visuals','Spectrum','Window');
    switch winType
    case{'Rectangular'}
        newParamsValues{index}='Boxcar';
    case{'Chebyshev','Hann','Hamming','Kaiser'}
        newParamsValues{index}=winType;
    otherwise
        newParamsValues{index}='Hann';
    end


    if strcmp(winType,'Chebyshev')
        index=index+1;
        newParamsNames{index}='RsSpecScope';
        sidelobeAttn=ud.Scope.getScopeParam('Visuals','Spectrum','SidelobeAttenuation');
        newParamsValues{index}=sidelobeAttn;
        index=index+1;
        newParamsNames{index}='betaSpecScope';
        newParamsValues{index}='5';
    elseif strcmp(winType,'Kaiser')
        index=index+1;
        newParamsNames{index}='betaSpecScope';
        sidelobeAttn=ud.Scope.getScopeParam('Visuals','Spectrum','SidelobeAttenuation');
        newParamsValues{index}=sidelobeAttn;
        index=index+1;
        newParamsNames{index}='RsSpecScope';
        newParamsValues{index}='50';
    else
        index=index+1;
        newParamsNames{index}='betaSpecScope';
        newParamsValues{index}='5';
        index=index+1;
        newParamsNames{index}='RsSpecScope';
        newParamsValues{index}='50';
        sidelobeAttn='0';
    end

    index=index+1;


    newParamsNames{index}='XRange';
    twoSided=ud.Scope.getScopeParam('Visuals','Spectrum','TwoSidedSpectrum');
    if twoSided
        if isR2009aOrEarlier(obj.ver)
            newParamsValues{index}='[-Fs/2...Fs/2]';
        else
            newParamsValues{index}='Two-sided';
        end
    else
        if isR2009aOrEarlier(obj.ver)
            newParamsValues{index}='[0...Fs/2]';
        else
            newParamsValues{index}='One-sided';
        end
    end

    index=index+1;


    newParamsNames{index}='AxisGrid';
    gridFlag=ud.Scope.getScopeParam('Visuals','Spectrum','Grid');
    if gridFlag
        newParamsValues{index}='on';
    else
        newParamsValues{index}='off';
    end

    index=index+1;


    newParamsNames{index}='AxisLegend';
    legendFlag=ud.Scope.getScopeParam('Visuals','Spectrum','Legend');
    if legendFlag
        newParamsValues{index}='on';
    else
        newParamsValues{index}='off';
    end

    index=index+1;


    newParamsNames{index}='Memory';
    maxHoldFlag=ud.Scope.getScopeParam('Visuals','Spectrum','MaxHoldTrace');
    if maxHoldFlag
        newParamsValues{index}='on';
    else
        newParamsValues{index}='off';
    end

    index=index+1;

    newParamsNames{index}='inpFftLenInherit';


    newParamsValues{index}='on';
    index=index+1;

    newParamsNames{index}='FFTlength';
    newParamsValues{index}='1024';

    index=index+1;
    ylabel=ud.Scope.getScopeParam('Visuals','Spectrum','YLabel');

    newParamsNames{index}='YLabel';
    newParamsValues{index}=ylabel;

    index=index+1;

    newParamsNames{index}='YMin';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Spectrum','MinYLim');

    index=index+1;

    newParamsNames{index}='YMax';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Spectrum','MaxYLim');


    if~isR2006bOrEarlier(obj.ver)
        index=index+1;

        newParamsNames{index}='XLimit';
        freqSpan=ud.Scope.getScopeParam('Visuals','Spectrum','FrequencySpan');
        if strcmp(freqSpan,'Full')
            newParamsValues{index}='Auto';
        else
            newParamsValues{index}='User-defined';
        end

        index=index+1;
        newParamsNames{index}='XMin';
        newParamsNames{index+1}='XMax';

        if~strcmp(freqSpan,'Full')
            if strcmp(freqSpan,'Start and stop frequencies')
                newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Spectrum','StartFrequency');
                newParamsValues{index+1}=ud.Scope.getScopeParam('Visuals','Spectrum','StopFrequency');
            else
                startFreq=sprintf('%s - %s/2',ud.Scope.getScopeParam('Visuals','Spectrum','CenterFrequency'),...
                ud.Scope.getScopeParam('Visuals','Spectrum','Span'));
                startFreq=simplifyString(blk,startFreq);
                newParamsValues{index}=startFreq;

                stopFreq=sprintf('%s + %s/2',ud.Scope.getScopeParam('Visuals','Spectrum','CenterFrequency'),...
                ud.Scope.getScopeParam('Visuals','Spectrum','Span'));
                stopFreq=simplifyString(blk,stopFreq);
                newParamsValues{index+1}=stopFreq;
            end
        else
            newParamsValues{index}='0';
            newParamsValues{index+1}='1';
        end
        index=index+1;
    end

    index=index+1;

    newParamsNames{index}='UseBuffer';
    newParamsValues{index}='on';

    index=index+1;




    newParamsNames{index}='BufferSize';

    freqResMode=ud.Scope.getScopeParam('Visuals','Spectrum','FrequencyResolutionMethod');

    if strcmp(freqResMode,'RBW')
        [val,~,errStr]=evaluateVariable(blk,sidelobeAttn);
        if~isempty(errStr)

            if strcmp(winType,'Chebyshev')
                val=50;
            else
                val=5;
            end
        end
        ENBW=getENBW(winType,val);



        segLen=round(ENBW*1024*(1+twoSided));
    else
        segLen=ud.Scope.getScopeParam('Visuals','Spectrum','WindowLength');
    end

    newParamsValues{index}=num2str(segLen);

    index=index+1;

    newParamsNames{index}='Overlap';
    overlapPercent=ud.Scope.getScopeParam('Visuals','Spectrum','OverlapPercent');
    overlap=sprintf('round(%s * %s / 100)',overlapPercent,num2str(segLen));
    overlap=simplifyString(blk,overlap);
    newParamsValues{index}=overlap;

    index=index+1;


    newParamsNames{index}='YUnits';
    powerval=ud.Scope.getScopeParam('Visuals','Spectrum','PowerUnits');
    SpectrumType=ud.Scope.getScopeParam('Visuals','Spectrum','SpectrumType');
    [val,~,errStr]=evaluateVariable(blk,overlap);
    if~isempty(errStr)

        val=0;
    end
    if strcmp(SpectrumType,'Power density')&&val==0


        powerval=sprintf('%s/Hertz',powerval);
    end
    newParamsValues{index}=powerval;

    index=index+1;

    newParamsNames{index}='winsampSpecScope';
    newParamsValues{index}='Symmetric';


    if~isR2007bOrEarlier(obj.ver)
        index=index+1;

        newParamsNames{index}='XDisplay';
        newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Spectrum','FrequencyOffset');
    end

    if~isR2010bOrEarlier(obj.ver)
        index=index+1;
        newParamsNames{index}='TreatMby1Signals';
        treatMby1=ud.Scope.getScopeParam('Visuals','Spectrum','TreatMby1SignalsAsOneChannel');
        if treatMby1
            newParamsValues{index}='One channel';
        else
            newParamsValues{index}='M channels';
        end
        index=index+1;
        newParamsNames{index}='isFrameUpgraded';
        newParamsValues{index}='on';

    end
end


function ENBW=getENBW(Window,SidelobeAttenuation)

    switch Window
    case 'Rectangular'
        ENBW=1;
    case 'Hann'
        ENBW=enbw(hann(1000));
    case 'Hamming'
        ENBW=enbw(hamming(1000));
    case 'Flat Top'
        ENBW=enbw(flattopwin(1000));
    case 'Chebyshev'
        w=chebwin(1000,SidelobeAttenuation);
        ENBW=(sum(w.^2)/sum(w)^2)*1000;
    case 'Kaiser'
        if SidelobeAttenuation>50
            winParam=0.1102*(SidelobeAttenuation-8.7);
        elseif SidelobeAttenuation<21
            winParam=0;
        else
            winParam=(0.5842*(SidelobeAttenuation-21)^0.4)+...
            0.07886*(SidelobeAttenuation-21);
        end
        w=kaiser(1000,winParam);
        ENBW=(sum(w.^2)/sum(w)^2)*1000;
    end
end



function[value,errID,errMsg]=evaluateVariable(blk,variableName)


    try
        value=slResolve(variableName,blk);
        errID='';
        errMsg='';
    catch ME %#ok<NASGU>
        [value,errID,errMsg]=uiservices.evaluate(variableName);
    end
end



function newStrVal=simplifyString(blk,strVal)

    strVal2=strrep(strVal,'round(','');
    if~isempty(regexp(strVal2,'[a-zA-Z]','once'))
        newStrVal=strVal;
        return;
    end
    [val,errStr]=evaluateVariable(blk,strVal);
    if isempty(errStr)
        newStrVal=num2str(val);
    else
        newStrVal=strVal;
    end
end



function saBlks=find_scopes(obj)

    saBlks=obj.findBlocksOfType('SpectrumAnalyzer');
    saBlks_viewers=obj.findBlocksOfType('SpectrumAnalyzer','IOType','viewer');
    saBlks=[saBlks;saBlks_viewers];
end


function changeSpectrumTypeAndAxesProps(saBlks,modelName)

    [~,origBlock]=strtok(saBlks,'/');
    origScfg=get_param([modelName,origBlock],'ScopeConfiguration');




    viewType=origScfg.ViewType;
    spectrumType=origScfg.SpectrumType;
    axesProps=getParameter(origScfg,'AxesProperties');

    currBlk=saBlks;
    currScfg=get_param(currBlk,'ScopeConfiguration');
    switch spectrumType

    case{'Power','RMS'}
        switch viewType
        case 'Spectrum'
            currScfg.SpectrumType='Power';
            setScopeParameter(currScfg,'AxesProperties',axesProps(1));
        case 'Spectrogram'
            currScfg.SpectrumType='Spectrogram';
            setScopeParameter(currScfg,'AxesProperties',axesProps(2));
        case 'Spectrum and spectrogram'
            currScfg.SpectrumType='Power';
            setScopeParameter(currScfg,'AxesProperties',axesProps(1));
        end

    case 'Power density'
        switch viewType
        case 'Spectrum'
            currScfg.SpectrumType='Power density';
            setScopeParameter(currScfg,'AxesProperties',axesProps(1));
        case 'Spectrogram'
            currScfg.SpectrumType='Spectrogram';
            setScopeParameter(currScfg,'AxesProperties',axesProps(2));
        case 'Spectrum and spectrogram'
            currScfg.SpectrumType='Power density';
            setScopeParameter(currScfg,'AxesProperties',axesProps(1));
        end
    end
end

function changeCustomWindow(saBlk,modelName)
    [~,origBlk]=strtok(saBlk,'/');
    origScfg=get_param([modelName,origBlk],'ScopeConfiguration');




    windowOption=origScfg.Window;
    currBlk=saBlk;
    currScfg=get_param(currBlk,'ScopeConfiguration');


    if strcmp(windowOption,'Custom')
        currScfg.Window='Hann';
    end
end

function changedBFSTodBm(saBlk,modelName)
    [~,origBlk]=strtok(saBlk,'/');
    origScfg=get_param([modelName,origBlk],'ScopeConfiguration');

    spectrumUnits=origScfg.SpectrumUnits;
    currBlk=saBlk;
    currScfg=get_param(currBlk,'ScopeConfiguration');

    if strcmp(spectrumUnits,'dBFS')
        currScfg.SpectrumUnits='dBm';
    end
end

function changeBlockToEmptySubsystemIfFilterBank(obj,saBlk,modelName)
    [~,origBlk]=strtok(saBlk,'/');
    origScfg=get_param([modelName,origBlk],'ScopeConfiguration');
    method=origScfg.Method;
    if strcmp(method,'Filter bank')


        obj.replaceWithEmptySubsystem(saBlk);
    end
end

function changeBlockToEmptySubsystemIfFrequencyDomain(obj,saBlk,modelName)
    [~,origBlk]=strtok(saBlk,'/');
    origScfg=get_param([modelName,origBlk],'ScopeConfiguration');
    domain=origScfg.InputDomain;
    if strcmp(domain,'Frequency')


        obj.replaceWithEmptySubsystem(saBlk);
    end
end
