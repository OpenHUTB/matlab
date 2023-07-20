function TimeScopeBlock(obj)























    i_addStaticRules(obj);

    isExportingWebTimeScope=Simulink.scopes.Util.isSLWebTimeScope&&isR2022aOrEarlier(obj.ver);
    if isExportingWebTimeScope

        i_addStaticRulesWebScopes(obj);
    else

        if isR2020aOrEarlier(obj.ver)
            obj.removeBlocksOfType('WebTimeScopeBlock');
        end
    end













    tsBlks=find_scopes(obj.modelName);
    for jndx=1:length(tsBlks)
        [~,origBlock]=strtok(tsBlks{jndx},'/');

        if isExportingWebTimeScope
            scopeSpec=getScopeSpecForWebScope(obj,origBlock);
            if~isempty(scopeSpec)
                set_param(tsBlks{jndx},'ScopeSpecificationString',scopeSpec.toString());
            end
        else

            scopeSpec=get_param([obj.origModelName,origBlock],'ScopeSpecificationObject');
        end
        if~isempty(scopeSpec)

            scopeSpec=copy(scopeSpec);


            set_param(tsBlks{jndx},...
            'ScopeSpecificationObject',scopeSpec);
        end
    end

    if isR2019bOrEarlier(obj.ver)
        for jndx=1:length(tsBlks)
            scopeSpec=get_param(tsBlks{jndx},'ScopeSpecificationObject');
            if ischar(scopeSpec.VisibleAtModelOpen)
                convertedValue=char(scopeSpec.VisibleAtModelOpen);
            elseif islogical(scopeSpec.VisibleAtModelOpen)
                if scopeSpec.VisibleAtModelOpen
                    convertedValue='on';
                else
                    convertedValue='off';
                end
            end
            scopeSpec.VisibleAtModelOpen=convertedValue;
        end
    end

    if isR2016bOrEarlier(obj.ver)

        tsBlks=find_scopes(obj.modelName);
        for jndx=1:length(tsBlks)
            scopeSpec=get_param(tsBlks{jndx},'ScopeSpecificationObject');
            changeStemToStairs(scopeSpec);
        end
    end

    if isR2015aOrEarlier(obj.ver)

        tsBlks=find_scopes(obj.modelName);
        for jndx=1:length(tsBlks)
            scopeSpec=get_param(tsBlks{jndx},'ScopeSpecificationObject');


            removeSignalUnitsIdentifier(scopeSpec);


            [~,origBlock]=strtok(tsBlks{jndx},'/');
            isSimulinkTimeScope=strcmpi(get_param(tsBlks{jndx},'DefaultConfigurationName'),...
            'Simulink.scopes.TimeScopeBlockCfg');
            if isSimulinkTimeScope
                i_exportAsBuiltInSimulinkScope(tsBlks{jndx},obj,origBlock);
            end
        end












        tsBlks=getDSTTimeScopes(obj.modelName);
        for jndx=1:length(tsBlks)
            sid=slexportprevious.utils.escapeSIDFormat(get_param(tsBlks{jndx},'SID'));
            obj.appendRule(getRuleChangeBlockType(sid,'Scope','TimeScope'));
            scopeSpec=get_param(tsBlks{jndx},'ScopeSpecification');
            if~isempty(scopeSpec)&&isempty(scopeSpec.ScopeCLI)
                scopeSpec.ScopeCLI=uiscopes.ScopeCLI;
            end
        end








        obj.appendRule('<BlockParameterDefaults<Block<BlockType|Scope><DefaultConfigurationName:remove>>>');
        obj.appendRule('<BlockParameterDefaults<Block<BlockType|Scope><NumInputPorts:remove>>>');



        if isR2011aOrEarlier(obj.ver)
            obj.appendRule('<BlockParameterDefaults<Block<BlockType|TimeScope>:remove>>');
        end



        obj.appendRule('<Block<BlockType|Scope><ScopeSpecificationString:remove>>');
        obj.appendRule('<Block<BlockType|SignalViewerScope><ScopeSpecificationString:remove>>');
    end

    if isR2014aOrEarlier(obj.ver)

        tsBlks=getDSTTimeScopes(obj.modelName);


        obj.appendRule('<Block<BlockType|TimeScope><ScopeSpecificationString:remove>>');
        obj.appendRule('<Block<BlockType|TimeScope><Floating:remove>>');

        for jndx=1:length(tsBlks)

            scopeSpec=get_param(tsBlks{jndx},'ScopeSpecificationObject');
            if~isempty(scopeSpec)


                scopeSpec=copy(scopeSpec);




                removeSignalUnitsIdentifier(scopeSpec);


                set_param(tsBlks{jndx},...
                'ScopeSpecification',scopeSpec,...
                'ScopeSpecificationObject',scopeSpec);
                scopeSpec.SaveAsString=false;
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

        for jndx=1:length(tsBlks)
            scopeSpec=get_param(tsBlks{jndx},'ScopeSpecification');
            if~isempty(scopeSpec)&&isempty(scopeSpec.ScopeCLI)
                scopeSpec.ScopeCLI=uiscopes.ScopeCLI;
            end
        end
    end

    if isR2013aOrEarlier(obj.ver)

        origTsBlks=getDSTTimeScopes(obj.origModelName);
        tsBlks=getDSTTimeScopes(obj.modelName);

        for jndx=1:length(tsBlks)
            scope=scopeextensions.ScopeBlock.getInstanceForCoreBlock(tsBlks{jndx});

            ud=get_param(tsBlks{jndx},'UserData');


            try
                if isempty(ud)
                    ud=struct;
                end
                if~isempty(scope)
                    ud.Scope=scope;
                    scopeCfg=get_param(origTsBlks{jndx},'ScopeSpecification');
                    if~isempty(scopeCfg)
                        scope.pScopeCfg=copy(scopeCfg);
                    end
                    if~isempty(scope.ScopeCfg)
                        scope.ScopeCfg.SaveAsString=false;
                    end
                    set_param(tsBlks{jndx},'UserData',ud,'UserDataPersistent','on');
                end
            catch

            end
            set_param(tsBlks{jndx},'CopyFcn',...
            'scopeextensions.ScopeBlock.callback(gcbh, ''onBlockCopy'', gcbh);');


            oldConfig=scope.ScopeCfg.CurrentConfiguration;
            if~isempty(oldConfig)
                timeDomainCfg=oldConfig.findConfiguration('Visuals','Time Domain');
                if~isempty(timeDomainCfg.PropertySet)
                    sd=timeDomainCfg.PropertySet.findProp('SerializedDisplays');
                    if~isempty(sd)
                        for kndx=1:numel(sd.Value)
                            sd.Value{kndx}.Title=strrep(sd.Value{kndx}.Title,'%<SignalLabel>','');
                        end
                    end
                    for kndx=1:numel(oldConfig.Children)
                        convertPropertySetToOldFormat(oldConfig.Children(kndx));
                    end
                end
            end

            set_param(tsBlks{jndx},'DestroyFcn','');
        end

        mdlObj=get_param(obj.modelName,'Object');
        callbackID=matlab.lang.makeValidName(['ScopeCleanUp',obj.modelName]);
        if~mdlObj.hasCallback('PreDestroy',callbackID)
            mdlObj.addCallback('PreDestroy',callbackID,...
            uiservices.makeCallback(@cleanUpCallback,obj.modelName));
        end


        obj.appendRule('<Block<BlockType|TimeScope><ScopeSpecification:remove>>');
    end

    if isR2012bOrEarlier(obj.ver)

        tsBlks=getDSTTimeScopes(obj.modelName);

        for jndx=1:length(tsBlks)
            tsblock=get_param(tsBlks{jndx},'Object');
            scope=scopeextensions.ScopeBlock.getInstanceFromUserData(tsblock);

            oldConfig=scope.ScopeCfg.CurrentConfiguration;


            if~isempty(oldConfig)
                plotNav=oldConfig.findConfig('Tools','Plot Navigation');
                if~isempty(plotNav)&&~isempty(plotNav.PropertySet)
                    modeProp=plotNav.PropertySet.findProp('AutoscaleMode');
                    onceAtStop=plotNav.PropertySet.findProp('OnceAtStop');

                    if~isempty(modeProp)
                        if strcmp(modeProp.Value,'Updates')
                            modeProp.Value='Manual';
                        elseif~isempty(onceAtStop)&&...
                            onceAtStop.Value&&...
                            ~strcmp(modeProp.Value,'Auto')




                            modeProp.Value='Once at stop';
                        end
                    end
                end
            end



            if isa(oldConfig,'extmgr.ConfigurationSet')
                scope.ScopeCfg.CurrentConfiguration=convertToOldFormat(oldConfig);
            end
        end
    end

    if isR2012aOrEarlier(obj.ver)

        tsBlks=getDSTTimeScopes(obj.modelName);
        for jndx=1:length(tsBlks)
            tsBlock=tsBlks{jndx};
            ud=get_param(tsBlock,'UserData');
            if isempty(ud)||~isfield(ud,'ScopeCfgName')
                ud.ScopeCfgName=get_param(tsBlock,'DefaultConfigurationName');
                set_param(tsBlock,'UserData',ud);
            end
            if isfield(ud,'Scope')&&~isempty(ud.Scope)
                cfg=ud.Scope.ScopeCfg.CurrentConfiguration;
                if~isempty(cfg)
                    tdcfg=cfg.findConfig('Visuals','Time Domain');
                    if~isempty(tdcfg)&&~isempty(tdcfg.PropertyDb)
                        autoTag='Spcuilib:scopes:TimeSpanAuto';
                        timeSpan=tdcfg.PropertyDb.findProp('TimeRangeSamples');
                        if~isempty(timeSpan)&&strcmp(timeSpan.Value,autoTag)


                            timeSpan.Value='10';
                        end
                        timeSpan=tdcfg.PropertyDb.findProp('TimeRangeFrames');
                        if~isempty(timeSpan)&&strcmp(timeSpan.Value,autoTag)
                            timeSpan.Value='10';
                        end
                    end
                end
            end
        end

        obj.appendRule('<Block<BlockType|TimeScope><DefaultConfigurationName:remove>>');



        obj.appendRule('<Block<BlockType|Scope><DefaultConfigurationName:remove>>');

    end

    if isR2011bOrEarlier(obj.ver)

        tsBlks=getDSTTimeScopes(obj.modelName);
        for i=1:length(tsBlks)
            tsBlock=tsBlks{i};




            scope=scopeextensions.ScopeBlock.getInstanceFromUserData(get_param(tsBlock,'Object'));


            set_param(tsBlock,'OpenFcn','');
            set_param(tsBlock,'PreDeleteFcn','');


            scopeCurrentCfg=scope.ScopeCfg.CurrentConfiguration;
            if~isempty(scopeCurrentCfg)
                hPropDb=scopeCurrentCfg.findConfig('Visuals','Time Domain').PropertyDb;



                if~isempty(hPropDb)&&isValidProperty(hPropDb,'SerializedDisplays')

                    serializedDisplays=getValue(hPropDb,'SerializedDisplays');
                    if~isempty(serializedDisplays)
                        firstDisplay=serializedDisplays{1};


                        hPropDb.add('MinYLim','string',firstDisplay.MinYLimReal);
                        hPropDb.add('MaxYLim','string',firstDisplay.MaxYLimReal);
                        hPropDb.add('YLabel','string',firstDisplay.YLabelReal);
                        hPropDb.add('Grid','bool',firstDisplay.XGrid);
                        hPropDb.add('Legend','bool',strcmpi(firstDisplay.LegendVisibility,'on'));


                        propNamesFor11b={'DisplayName','Color','LineStyle','LineWidth',...
                        'Marker','MarkerSize','MarkerEdgeColor','MarkerFaceColor','Visible'};
                        newLineProperties=struct(...
                        'DisplayName',{},...
                        'Color',{},...
                        'LineStyle',{},...
                        'LineWidth',{},...
                        'Marker',{},...
                        'MarkerSize',{},...
                        'MarkerEdgeColor',{},...
                        'MarkerFaceColor',{},...
                        'Visible',{});
                        lineNumberForColor=0;
                        defaultColorOrder=get(0,'DefaultAxesColorOrder');
                        for displayInd=1:length(serializedDisplays)


                            serializedDisplay=serializedDisplays{displayInd};
                            channelNames=serializedDisplay.LineNames;
                            linePropsCache=serializedDisplay.LinePropertiesCache;


                            for lineInd=1:serializedDisplay.NumLines


                                linePropDefaults=uiscopes.getDefaultLineProperties();
                                linePropDefaults.DisplayName=channelNames{lineInd};


                                if length(linePropsCache)>=lineInd
                                    lineProps=linePropsCache{lineInd};
                                    lineProps=matlabshared.scopes.visual.TimeDomainPlotter.mergeStructs(linePropDefaults,lineProps);
                                else
                                    lineProps=linePropDefaults;
                                end


                                if~isfield(lineProps,'Color')||isempty(lineProps.Color)
                                    lineNumberForColor=lineNumberForColor+1;
                                    lineProps.Color=defaultColorOrder(rem(lineNumberForColor-1,size(defaultColorOrder,1))+1,:);
                                end


                                for propInd=1:length(propNamesFor11b)
                                    thisPropName=propNamesFor11b{propInd};
                                    newLineProps.(thisPropName)=lineProps.(thisPropName);
                                end


                                newLineProperties(end+1)=newLineProps;
                            end
                        end
                        hPropDb.add('LineProperties','mxArray',newLineProperties);
                    end
                end
            end
        end
    end

    if isR2011aOrEarlier(obj.ver)

        tsBlks=getDSTTimeScopes(obj.modelName);

        if~isempty(tsBlks)


            lib_mdl=getTempLib(obj);
            libBlock=[lib_mdl,'/',obj.generateTempName];




            add_block('built-in/S-Function',libBlock);


            set_param(libBlock,...
            'Mask','on',...
            'Parameters','NumInputPorts',...
            'MaskVariables','NumInputPorts=@1',...
            'MaskType','Time Scope');


            save_system(lib_mdl);



            sfuncBlock=libBlock;
            for i=1:length(tsBlks)
                blk=tsBlks{i};




                params={'NumInputPorts','UserDataPersistent','Orientation','Position'};
                paramValues=cell(size(params));
                for j=1:length(params)
                    paramValues{j}=get_param(blk,params{j});
                end




                ud=get_param(blk,'UserData');
                sfuncUd=struct;
                sfuncUd.ScopeCfgName=ud.ScopeCfgName;
                sfuncUd.Scope=ud.Scope;

                sfuncUd.Scope.pScopeCfg=copy(ud.Scope.ScopeCfg);
                ud.Scope=[];
                set_param(blk,'UserData',ud);



                ports=get_param(blk,'Ports');
                numInputPorts=num2str(ports(1));
                numOutputPorts=num2str(ports(2));



                set_param(blk,'ScopeSpecificationObject','');
                delete_block(blk);



                add_block(sfuncBlock,blk,...
                'GraphicalNumInputPorts',numInputPorts,...
                'GraphicalNumOutputPorts',numOutputPorts);


                for j=1:length(params)
                    set_param(blk,params{j},paramValues{j});
                end




                set_param(blk,'LinkStatus','Inactive');
                sfuncUd.Scope.Block=get_param(blk,'Object');

                sfuncUd.Scope.AbortDelete=true;
                set_param(blk,'LinkStatus','Restore');
                sfuncUd.Scope.AbortDelete=false;


                set_param(blk,'UserData',sfuncUd);

            end



            newRef=sfuncBlock;

            oldRef='"dspsnks4/Time\nScope"';

            obj.appendRule(['<Block<SourceBlock|"',newRef,'":repval ',oldRef,'>>']);

        end

    end

    if isR2009bOrEarlier(obj.ver)



        timeScopeBlks=find_system(obj.modelName,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'MaskType','Time Scope');

        numTimeScopeBlks=length(timeScopeBlks);
        if numTimeScopeBlks>0




            vecScopeBlk='dspobslib/Frame Input Vector Scope';
            offOn={'off','on'};

            for idx=1:numTimeScopeBlks

                blk=timeScopeBlks{idx};

                ud=get_param(blk,'UserData');
                scopeCurrentCfg=ud.Scope.ScopeCfg.CurrentConfiguration;
                if~isempty(scopeCurrentCfg)

                    ud=get_param(blk,'userdata');
                    numInPortsStr=get_param(blk,'NumInputPorts');
                    numInPorts=str2double(numInPortsStr);
                    blkName=get_param(blk,'Name');
                    orient=get_param(blk,'Orientation');
                    pos=get_param(blk,'Position');

                    frameNess=getScopeParamValue(ud.Scope.ScopeCfg,'Visuals','Time Domain','InputProcessing');
                    visCfg=scopeCurrentCfg.findConfig('Visuals','Time Domain');
                    yMinProp=visCfg.PropertyDb.findProp('MinYLim');
                    yMaxProp=visCfg.PropertyDb.findProp('MaxYLim');
                    if isempty(yMinProp)
                        yMin='-10';
                    else
                        yMin=yMinProp.Value;
                    end
                    if isempty(yMaxProp)
                        yMax='10';
                    else
                        yMax=yMaxProp.Value;
                    end

                    if strncmpi(frameNess,'SampleProcessing',16)||~(exist('dspmisc','file'))

                        timeRange=getScopeParamValue(ud.Scope.ScopeCfg,'Visuals','Time Domain','TimeRangeFrames');

                        if strcmp(timeRange,'Spcuilib:scopes:TimeSpanAuto')
                            timeRange='10';
                        end

                        slScpYMin=yMin;
                        slScpYMax=yMax;

                        for ipIdx=2:numInPorts
                            slScpYMin=[slScpYMin,'~',yMin];
                            slScpYMax=[slScpYMax,'~',yMax];
                        end




                        set_param(blk,'UserDataPersistent','off');
                        set_param(blk,'UserData',[]);



                        sid=slexportprevious.utils.escapeSIDFormat(get_param(blk,'SID'));


                        obj.appendRule(getRuleChangeBlockType(sid,'Reference','Scope'));



                        rmParams={'LibraryVersion','SourceBlock','SourceType'};
                        for rndx=1:numel(rmParams)
                            obj.appendRule(getRuleRemovePair(sid,rmParams{rndx}));
                        end


                        timeRange=slexportprevious.utils.escapeRuleCharacters(timeRange);
                        obj.appendRule(getRuleInsertPair(sid,'TimeRange',timeRange,'Scope'));
                        slScpYMin=slexportprevious.utils.escapeRuleCharacters(slScpYMin);
                        obj.appendRule(getRuleInsertPair(sid,'YMin',slScpYMin,'Scope'));
                        slScpYMax=slexportprevious.utils.escapeRuleCharacters(slScpYMax);
                        obj.appendRule(getRuleInsertPair(sid,'YMax',slScpYMax,'Scope'));
                    else








                        load_system('dspmisc');

                        blkHeight=pos(4)-pos(2);
                        newBlkHeight=floor(blkHeight/numInPorts);



                        try
                            gridVis=getScopeParamValue(ud.Scope.ScopeCfg,'Visuals','Time Domain','Grid');
                        catch ME
                            gridVis=1;
                        end
                        try
                            legendVal=getScopeParamValue(ud.Scope.ScopeCfg,'Visuals','Time Domain','Legend');
                        catch ME %#ok<*NASGU>
                            legendVal=0;
                        end
                        compactVal=false;
                        try
                            yLabelVal=getScopeParamValue(ud.Scope.ScopeCfg,'Visuals','Time Domain','YLabel');
                        catch ME
                            yLabelVal='Amplitude';
                        end
                        openAtMdlStart=ud.Scope.ScopeCfg.OpenAtMdlStart;
                        scpPosition=ud.Scope.Position;

                        newGridVis=offOn{gridVis+1};
                        newLegendVal=offOn{legendVal+1};
                        newCompactVal=offOn{compactVal+1};
                        newOpenAtMdlStart=offOn{openAtMdlStart+1};
                        newScpPosition=['[',num2str(scpPosition),']'];


                        blkLH=get_param(blk,'linehandles');

                        delete_block(blk);






                        srcBlockHandle=zeros(numInPorts,1);
                        srcPortHandle=zeros(numInPorts,1);
                        for ipIdx=1:numInPorts
                            hLine=blkLH.Inport(ipIdx);
                            if hLine~=-1
                                srcBlockHandle(ipIdx)=get(hLine,'SrcBlockHandle');
                                srcPortHandle(ipIdx)=get(hLine,'SrcPortHandle');
                                delete_line(get(hLine,'Handle'));
                            else
                                srcBlockHandle(ipIdx)=-1;
                                srcPortHandle(ipIdx)=-1;
                            end
                        end
                        for ipIdx=1:numInPorts

                            newBlkName=[blkName,'_input',num2str(ipIdx)];
                            newFullBlkName=strrep(blk,blkName,newBlkName);

                            newPos=pos;
                            newPos(2)=floor(pos(2)+newBlkHeight*(ipIdx-1));
                            newPos(4)=floor(newPos(2)+newBlkHeight);

                            add_block(vecScopeBlk,newFullBlkName,...
                            'Name',newBlkName,...
                            'Orientation',orient,...
                            'Position',newPos,...
                            'linkstatus','none');
                            set_param([newFullBlkName,'/Vector Scope'],...
                            'YMin',yMin,...
                            'YMax',yMax,...
                            'AxisGrid',newGridVis,...
                            'AxisLegend',newLegendVal,...
                            'AxisZoom',newCompactVal,...
                            'YLabel',yLabelVal,...
                            'OpenScopeAtSimStart',newOpenAtMdlStart,...
                            'FigPos',newScpPosition);

                            if srcBlockHandle(ipIdx)~=-1
                                srcBlkName=get_param(srcBlockHandle(ipIdx),'Name');
                                srcBlkPortNum=get_param(srcPortHandle(ipIdx),'PortNumber');
                                autoline(obj.modelName,...
                                [srcBlkName,'/',int2str(srcBlkPortNum)],...
                                [newBlkName,'/1']);
                            end

                        end

                    end

                end
            end

        end

    elseif isR2010bOrEarlier(obj.ver)







        timeScopeBlks=find_system(obj.modelName,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'MaskType','Time Scope');

        for indx=1:numel(timeScopeBlks)



            b=timeScopeBlks{indx};
            set_param(b,'LinkStatus','inactive');
            scopeextensions.ScopeBlock.saveAs(b,obj.ver);
            ud=get_param(b,'UserData');
            ud.Scope.AbortDelete=true;
            set_param(b,'LinkStatus','restore');
            ud.Scope.AbortDelete=false;
        end

    end

end



function i_exportAsBuiltInSimulinkScope(tsBlk,obj,origBlock)



    sid=slexportprevious.utils.escapeSIDFormat(get_param(tsBlk,'SID'));

    isViewer=strcmp(get_param(tsBlk,'IOType'),'viewer');
    if isViewer&&isR2014aOrEarlier(obj.ver)
        blockTypeStr='SignalViewerScope';
    else
        blockTypeStr='Scope';
    end










    spec=get_param(tsBlk,'ScopeSpecificationObject');
    vis='off';
    if~isempty(spec)


        vis=char(spec.VisibleAtModelOpen);
    end
    obj.appendRule(getRuleInsertPair(sid,'Open',...
    slexportprevious.utils.escapeRuleCharacters(vis),blockTypeStr));

    stringParams={'TimeRange','TickLabels','ShowLegends',...
    'LimitDataPoints','MaxDataPoints','SaveToWorkspace','SaveName',...
    'YMin','YMax','SampleInput','SampleTime','ZoomMode','Grid'};

    if isR2011bOrEarlier(obj.ver)
        stringParams(strcmp(stringParams,'ShowLegends'))=[];
    end
    s=get_param(tsBlk,'ScopeConfiguration');


    s.UsePreviousFormat=true;
    for pndx=1:numel(stringParams)
        obj.appendRule(getRuleInsertPair(sid,stringParams{pndx},...
        slexportprevious.utils.escapeRuleCharacters(get_param(tsBlk,stringParams{pndx})),blockTypeStr));
    end
    s.UsePreviousFormat=false;



    saveFormat=get_param(tsBlk,'DataFormat');
    if strcmpi(saveFormat,'Dataset')
        saveFormat='StructureWithTime';
    end
    obj.appendRule(getRuleInsertPair(sid,'DataFormat',slexportprevious.utils.escapeRuleCharacters(saveFormat),...
    blockTypeStr));




    decimation=get_param(tsBlk,'Decimation');
    if~s.DataLoggingDecimateData
        decimation='1';
    end
    obj.appendRule(getRuleInsertPair(sid,'Decimation',...
    slexportprevious.utils.escapeRuleCharacters(decimation),blockTypeStr));









    axesTitles=get_param(tsBlk,'AxesTitles');

    isFloating=strcmp(get_param(tsBlk,'Floating'),'on');
    if(isViewer||isFloating)


        nports_str=get_param(tsBlk,'NumInputPorts');
        nports=str2double(nports_str);
        iosignals=get_param(tsBlk,'IOSignals');
        len_iosignals=length(iosignals);
        if(len_iosignals~=nports)



            obj.appendRule(getRuleInsertPair(sid,'NumInputPorts',...
            slexportprevious.utils.escapeRuleCharacters(num2str(len_iosignals)),blockTypeStr));
        end



        titles=struct2cell(axesTitles);
        numTitles=numel(titles);
        if(len_iosignals~=numTitles)
            titlesStr='%<SignalLabel>';




            isTitleDefault=strcmpi(titles,'%<SignalLabel>');
            if any(~isTitleDefault)
                specOrigBlk=get_param([obj.origModelName,origBlock],'ScopeSpecificationObject');
                if~isempty(specOrigBlk)&&isLaunched(specOrigBlk)



                    hDisplays=specOrigBlk.Block.UnifiedScope.Visual.Displays;
                    indxDefTitles=find(isTitleDefault);
                    if~isempty(indxDefTitles)
                        for tndx=indxDefTitles
                            titles{tndx}=hDisplays{tndx}.Axes.Title.String;
                        end
                    end
                    titlesStr=sprintf('%s, ',titles{:});
                    titlesStr(end-1:end)='';
                end
            end
            axesTitles=struct('axes1',titlesStr);
        end
    end





    obj.appendRule(getRuleInsertContainer(sid,'List1'));

    obj.appendRule(getRuleInsertPairInContainer(sid,'List1','ListType','AxesTitles',blockTypeStr));
    f=fieldnames(axesTitles);
    for fndx=1:numel(f)
        fvalue=['"',slexportprevious.utils.escapeRuleCharacters(axesTitles.(f{fndx})),'"'];
        obj.appendRule(getRuleInsertPairInContainer(sid,'List1',f{fndx},fvalue,blockTypeStr));
    end
    obj.appendRule(i_getRuleRenameParameter(sid,'List1','List'));















    if~isR2011aOrEarlier(obj.ver)&&~(isViewer&&isR2014aOrEarlier(obj.ver))



        scopeGraphics=get_param([obj.origModelName,origBlock],'ScopeGraphics');
        defColorOrder=uiscopes.getColorOrder([0,0,0]);

        defColorOrder=defColorOrder(1:6,:);
        defaultTimeScopeGraphics=struct('FigureColor',mat2str((40/255)*ones(1,3)),...
        'AxesColor','[0 0 0]','AxesTickColor',mat2str((175/255)*ones(1,3)),...
        'LineColors',mat2str(defColorOrder),...
        'LineStyles','-|-|-|-|-|-','LineWidths','[0.5 0.5 0.5 0.5 0.5 0.5]',...
        'MarkerStyles','none|none|none|none|none|none');
        if~isequal(scopeGraphics,defaultTimeScopeGraphics)
            obj.appendRule(getRuleInsertContainer(sid,'List2'));
            obj.appendRule(getRuleInsertPairInContainer(sid,'List2','ListType','ScopeGraphics',blockTypeStr));
            if~isempty(scopeGraphics)
                f=fields(scopeGraphics);
                for fndx=1:numel(f)
                    fvalue=['"',scopeGraphics.(f{fndx}),'"'];

                    fvalue=slexportprevious.utils.escapeRuleCharacters(fvalue);
                    obj.appendRule(getRuleInsertPairInContainer(sid,'List2',f{fndx},fvalue,blockTypeStr));
                end
            end
            obj.appendRule(i_getRuleRenameParameter(sid,'List2','List'));
        end
    end


    location=get_param(tsBlk,'Location');
    if~ischar(location)&&~(isstring(location)&&isscalar(location))
        location=mat2str(location);
    end
    obj.appendRule(getRuleInsertPair(sid,'Location',location,blockTypeStr));




    set_param(tsBlk,'ScopeSpecification',[]);



    rmParams={'ScopeSpecification','DefaultConfigurationName'};
    for rndx=1:numel(rmParams)
        obj.appendRule(getRuleRemovePair(sid,rmParams{rndx}));
    end
end



function tsBlks=getDSTTimeScopes(modelName)
    tsBlks=find_scopes(modelName);
    defaultConfigNames=get_param(tsBlks,'DefaultConfigurationName');
    isSimulinkTimeScope=strcmp('Simulink.scopes.TimeScopeBlockCfg',defaultConfigNames);
    tsBlks=tsBlks(~isSimulinkTimeScope);
end



function rule=getRuleInsertContainer(sid,name)
    rule=['<Block<SID|"',sid,'">:','insertcontainer ',name,'>'];
end

function pairValue=addQuotesIfRequired(pairValue)
    try
        Simulink.loadsave.ExportRuleProcessor.validateRule(['<X:repval ',pairValue,'>']);
    catch E
        pairValue=['"',pairValue,'"'];
        Simulink.loadsave.ExportRuleProcessor.validateRule(['<X:repval ',pairValue,'>']);
    end
end

function rule=getRuleInsertPairInContainer(sid,containerName,pairName,pairValue,blockTypeStr)
    rule=['<Block<BlockType|',blockTypeStr,'><SID|"',sid,'"><',containerName,':insertpair '...
    ,pairName,' ',addQuotesIfRequired(pairValue),'>>'];
end

function rule=getRuleInsertPair(sid,pairName,pairValue,blockTypeStr)
    identifyingRule=['<BlockType|',blockTypeStr,'><SID|"',sid,'">'];
    rule=slexportprevious.rulefactory.addParameterToBlock(identifyingRule,...
    pairName,addQuotesIfRequired(pairValue));
end

function rule=getRuleChangeBlockType(sid,oldBlockType,newBlockType)
    rule=['<Block<SID|"',sid,'"><BlockType|',oldBlockType,':repval '...
    ,addQuotesIfRequired(newBlockType),'>>'];
end

function rule=getRuleRemovePair(sid,pairName)
    rule=['<Block<SID|"',sid,'">','<',pairName,':remove>>'];
end

function rule=i_getRuleRenameParameter(sid,oldparamname,newparamname)
    rule=['<Block<SID|"',sid,'">','<',oldparamname,':rename ',newparamname,'>>'];
end

function cleanUpCallback(modelName)




    timeScopeBlocks=find_system(modelName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LockUnderMasks','on',...
    'MaskType','Time Scope');

    tsBlks=[...
    find_scopes(modelName);
timeScopeBlocks
    ];

    for indx=1:numel(tsBlks)
        ud=get_param(tsBlks{indx},'UserData');
        if isfield(ud,'Scope')&&~isempty(ud.Scope)&&isvalid(ud.Scope)
            delete(ud.Scope);
        end
    end

    allScopeBlocks=uiscopes.manager('ScopeBlock','get');
    for indx=1:numel(allScopeBlocks)
        if strncmp(allScopeBlocks(indx).BlockPath,modelName,numel(modelName))
            delete(allScopeBlocks(indx));
        end
    end

end

function tsBlks=find_scopes(modelName)



    tsBlks=find_system(modelName,'LookUnderMasks','on','IncludeCommented','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'AllBlocks','on','BlockType','Scope');
end

function value=getScopeParamValue(hScopeSpec,type,name,propName)




    cfgDb=hScopeSpec.CurrentConfiguration;
    if~isempty(cfgDb)
        cfg=cfgDb.findConfig(type,name);
        propSet=cfg.PropertyDb;
        if~isempty(propSet)&&isValidProperty(propSet,propName)
            value=getValue(propSet,propName);
            return;
        end
    end


    defaults=matlabshared.scopes.getDefaultConfigurationSet(hScopeSpec.getConfigurationFile);
    cfg=defaults.findConfig(type,name);
    if~isempty(cfg)&&~isempty(cfg.PropertySet)&&isValidProperty(cfg.PropertySet,propName)
        value=getValue(cfg.PropertySet,propName);
    else
        library=extmgr.Library.Instance;
        if hScopeSpec.useMCOSExtMgr
            regset=library.getRegistrationSet('scopext','register');
        else
            regset=library.getRegistrationSet('scopext.m');
        end
        reg=regset.findRegistration(type,name);
        value=getValue(reg.getPropertySet,propName);
    end
end

function removeSignalUnitsIdentifier(scopeSpec)

    if~isempty(scopeSpec)
        currentConfig=scopeSpec.CurrentConfiguration;
        if~isempty(currentConfig)
            timeDomainCfg=currentConfig.findConfiguration('Visuals','Time Domain');
            propset=timeDomainCfg.PropertySet;
            if~isempty(propset)&&isValidProperty(propset,'SerializedDisplays')
                sd=propset.getValue('SerializedDisplays');
                if~isempty(sd)
                    for kndx=1:numel(sd)
                        sd{kndx}.YLabelReal=strrep(sd{kndx}.YLabelReal,'%<SignalUnits>','');
                    end
                    setValue(propset,'SerializedDisplays',sd);
                end
            end
        end
    end
end

function changeStemToStairs(scopeSpec)

    if~isempty(scopeSpec)
        currentConfig=scopeSpec.CurrentConfiguration;
        if~isempty(currentConfig)
            timeDomainCfg=currentConfig.findConfiguration('Visuals','Time Domain');
            propset=timeDomainCfg.PropertySet;
            if~isempty(propset)&&isValidProperty(propset,'PlotType')
                pt=propset.getValue('PlotType');
                if isequal(pt,'Stem')
                    setValue(propset,'PlotType','Stairs');
                end
            end
        end
    end
end





function i_addStaticRules(obj)

    targetVersion=obj.ver;

    if isR2014aOrEarlier(targetVersion)




        obj.appendRule('<Block<BlockType|Scope><IOType|viewer><BlockType|Scope:repval SignalViewerScope>>');


        obj.appendRule('<Block<BlockType|SignalViewerScope><List:remove<ListType|ScopeGraphics>>>');


        obj.appendRule('<Block<BlockType|Scope><ScrollMode:remove>>');

    end

    if isR2011bOrEarlier(targetVersion)



        obj.appendRule('<Block<BlockType|Scope><ShowLegends:remove>>');
        obj.appendRule('<Block<BlockType|Scope><LegendLocations:remove>>');

    end

    if isR2011aOrEarlier(targetVersion)


        obj.appendRule('<List:remove<ListType|ScopeGraphics>>');

    end
end


function i_addStaticRulesWebScopes(obj)
    paramsToRemove={'GraphicalSettings','WindowPosition','Visible','SampleTime',...
    'FrameBasedProcessing','OpenAtSimulationStart','DataLogging','DataLoggingVariableName',...
    'DataLoggingSaveFormat','DataLoggingLimitDataPoints','DataLoggingMaxPoints',...
    'DataLoggingDecimateData','DataLoggingDecimation','MultipleDisplayCache',...
    'LayoutDimensionsString','ShowLegend','WasSavedAsWebScope'};
    for pndx=1:length(paramsToRemove)
        obj.appendRule(['<Block<BlockType|Scope><',paramsToRemove{pndx},':remove>>']);
    end
end


function scopeSpec=getScopeSpecForWebScope(obj,origBlock)



    scopeSpec=[];
    blkHandle=[obj.origModelName,origBlock];
    graphicalSettings=get_param(blkHandle,'GraphicalSettings');
    if~isempty(graphicalSettings)
        out=jsondecode(graphicalSettings);


        if isfield(out,'GraphicalSettings')
            out=out.GraphicalSettings;
        end
        style=out.Style;

        measdata=struct;
        allMeas={'Cursors','Peaks','Stats','Bilevel','Trigger'};
        for mndx=1:length(allMeas)
            if isfield(out,allMeas{mndx})
                measdata.(allMeas{mndx})=out.(allMeas{mndx});
            end
        end
    else
        style=struct;
        measdata=struct;
    end
    if strcmpi(get_param(blkHandle,'DefaultConfigurationName'),...
        'Simulink.scopes.TimeScopeBlockCfg')
        scopeSpec=Simulink.scopes.TimeScopeBlockCfg;
    else
        scopeSpec=spbscopes.TimeScopeBlockCfg;
    end
    scopeSpec.OpenAtMdlStart=get_param(blkHandle,'OpenScopeAtSimStart');
    scopeSpec.VisibleAtModelOpen=get_param(blkHandle,'Visible');

    windowPos=get_param(blkHandle,'WindowPosition');
    if~isempty(windowPos)
        if ischar(windowPos)
            windowPos=eval(windowPos);
        end
        scopeSpec.Position=windowPos;
    end
    scopeSpec.CurrentConfiguration=getCurrentConfiguration(blkHandle,style,measdata);
end

function currentConfig=getCurrentConfiguration(blkHandle,style,measdata)

    currentConfig=extmgr.ConfigurationSet;

    buildCoreGeneralUI(currentConfig,style,blkHandle);

    buildSourcesWiredSimulink(currentConfig,blkHandle);

    buildVisualsTimeDomain(currentConfig,style,blkHandle);

    buildPlotNavigation(currentConfig,blkHandle);

    buildToolsMeasurements(currentConfig,measdata);
end


function buildCoreGeneralUI(currentConfig,style,blkHandle)

    config=extmgr.Configuration('Core','General UI',true);
    props={};
    props={'DisplayFullSourceName',uiservices.onOffToLogical(get_param(blkHandle,'DisplayFullPath'))...
    ,'ShowMainToolbar',true};
    if isfield(style,'BackgroundColor')
        props=horzcat(props,{'FigureColor',(style.BackgroundColor(:))'});
    end
    config.PropertySet=extmgr.PropertySet('-notype',props{:});
    currentConfig.add(config);
end


function buildSourcesWiredSimulink(currentConfig,blkHandle)

    config=extmgr.Configuration('Sources','WiredSimulink',true);
    props={'DataLogging',uiservices.onOffToLogical(get_param(blkHandle,'DataLogging')),...
    'DataLoggingVariableName',get_param(blkHandle,'DataLoggingVariableName')...
    ,'DataLoggingLimitDataPoints',uiservices.onOffToLogical(get_param(blkHandle,'DataLoggingLimitDataPoints'))...
    ,'DataLoggingMaxPoints',get_param(blkHandle,'DataLoggingMaxPoints')...
    ,'DataLoggingDecimateData',uiservices.onOffToLogical(get_param(blkHandle,'DataLoggingDecimateData'))...
    ,'DataLoggingDecimation',get_param(blkHandle,'DataLoggingDecimation')...
    ,'DataLoggingSaveFormat',get_param(blkHandle,'DataLoggingSaveFormat'),...
    'SampleTime',get_param(blkHandle,'SampleTime')};
    config.PropertySet=extmgr.PropertySet('-notype',props{:});
    currentConfig.add(config);
end


function buildVisualsTimeDomain(currentConfig,style,blkHandle)

    config=extmgr.Configuration('Visuals','Time Domain',true);
    props={};

    if isfield(style,'AxesColor')
        dc=jsondecode(get_param(blkHandle,'MultipleDisplayCache'));
        if~isempty(dc)
            numDisplays=length(dc);
            props=horzcat(props,{'SerializedDisplays',{}});
            slndx=1;
            for dndx=1:numDisplays
                [dispProps,slndx]=getDisplayProps(dc,style,dndx,slndx);
                props{2}{end+1}=dispProps;
            end
        end
    end
    dispPropDefaults=struct('YLabelReal','','XGrid',true,'YGird',true,'PlotMagPhase',false,...
    'AxesColor',[0,0,0],'AxesTickColor',[0.6863,0.6863,0.6863],'ColorOrder',uiscopes.getColorOrder([0,0,0]));
    if isfield(style,'PlotType')
        ptype=style.PlotType;
    else
        ptype='Auto';
    end
    otherProps={'DisplayPropertyDefaults',dispPropDefaults,...
    'DisplayLayoutDimensions',eval(get_param(blkHandle,'LayoutDimensionsString')),...
    'DisplayContentCache',[],...
    'PlotType',ptype,...
    'TimeUnits',get_param(blkHandle,'TimeUnits'),...
    'TimeSpanOverrunMode',get_param(blkHandle,'TimeSpanOverrunAction'),...
    'TimeDisplayOffset',get_param(blkHandle,'TimeDisplayOffset'),...
    'TimeAxisLabels',get_param(blkHandle,'TimeAxisLabels'),...
    'MaximizeAxes',get_param(blkHandle,'MaximizeAxes'),...
    'ShowTimeAxisLabel',uiservices.onOffToLogical(get_param(blkHandle,'ShowTimeAxisLabel')),...
    };
    props=horzcat(props,otherProps);
    inputProcessing='SampleProcessing';
    timeSpan=get_param(blkHandle,'TimeSpan');
    if uiservices.onOffToLogical(get_param(blkHandle,'FrameBasedProcessing'))
        inputProcessing='FrameProcessing';
        if timeSpan=="Auto"

        elseif timeSpan=="One frame period"
            props=horzcat(props,{'TimeRangeFrames','Spcuilib:scopes:TimeRangeInputSampleTime'});
        else
            props=horzcat(props,{'TimeRangeFrames',timeSpan});
        end
    else
        if timeSpan=="Auto"

        else
            props=horzcat(props,{'TimeRangeSamples',timeSpan});
        end
    end
    props=horzcat(props,{'InputProcessing',inputProcessing});
    config.PropertySet=extmgr.PropertySet('-notype',props{:});
    currentConfig.add(config);
end


function buildPlotNavigation(currentConfig,blkHandle)

    config=extmgr.Configuration('Tools','Plot Navigation',true);
    autosMode=get_param(blkHandle,'AxesScaling');
    if autosMode=="After N Updates"
        amode='Updates';
    else
        amode=autosMode;
    end
    props={'OnceAtStop',true,...
    'YDataDisplay','80',...
    'XDataDisplay','100',...
    'AutoscaleMode',amode,...
    'AutoscaleYAnchor','Center',...
    'AutoscaleXAnchor','Center',...
    'AutoscaleSecondaryAxes',true,...
    'UpdatesBeforeAutoscale',get_param(blkHandle,'AxesScalingNumUpdates')};
    config.PropertySet=extmgr.PropertySet('-notype',props{:});
    currentConfig.add(config);
end


function buildToolsMeasurements(currentConfig,measdata)

    if isempty(fields(measdata))
        return;
    end
    config=extmgr.Configuration('Tools','Measurements',true);
    props={};
    propNames={'Measurements','Version'};
    releaseStr=strrep(char(matlabRelease.Release),'R','');

    mCursors=struct.empty;
    if isfield(measdata,'Cursors')
        mCursors=struct('XCoordinates',measdata.Cursors.XLocation',...
        'YCoordinates',[NaN,NaN],...
        'CursorChannels',[1,1],...
        'WaveformCursors',true,...
        'ShowHorizontal',false,...
        'ShowVertical',false,...
        'LockCursorSpacing',measdata.Cursors.LockSpacing,...
        'SnapToData',measdata.Cursors.SnapToData,...
        'SettingsPanelOpen',false,...
        'MeasurementsPanelOpen',measdata.Cursors.Enabled);
    end
    mPeaks=struct.empty;
    if isfield(measdata,'Peaks')
        if isempty(measdata.Peaks.MinHeight)
            minHeight=-Inf;
        else
            minHeight=measdata.Peaks.MinHeight;
        end
        switch measdata.Peaks.LabelFormat
        case 'x + y'
            lblFormat=1;
        case 'x'
            lblFormat=2;
        case 'y'
            lblFormat=3;
        end
        mPeaks=struct('Threshold',measdata.Peaks.Threshold,...
        'NumPeaks',measdata.Peaks.NumPeaks,...
        'MinPeakDistance',measdata.Peaks.MinDistance,...
        'MinPeakHeight',minHeight,...
        'SortByXAxis',false,...
        'TextLabelFormat',lblFormat,...
        'TextIndices',[],...
        'SortAscending',false,...
        'SettingsPanelOpen',false,...
        'PeaksPanelOpen',measdata.Peaks.Enabled);
    end
    mBilevel=struct.empty;
    if isfield(measdata,'Bilevel')
        if measdata.Bilevel.AutoStateLevel
            stateSource='Auto';
        else
            stateSource='Property';
        end
        mBilevel=struct('StateLevelsSource',stateSource,...
        'StateLevels',[measdata.Bilevel.LowStateLevel,measdata.Bilevel.HighStateLevel],...
        'PercentStateLevelTolerance',measdata.Bilevel.StateLevelTolerance,...
        'PercentReferenceLevels',[measdata.Bilevel.LowerReferenceLevel,measdata.Bilevel.MidReferenceLevel,measdata.Bilevel.UpperReferenceLevel],...
        'SettlingSeekDuration',measdata.Bilevel.SettleSeek,...
        'SettingsPanelOpen',false,...
        'TransitionsPanelOpen',measdata.Bilevel.ShowTransitions,...
        'AberrationsPanelOpen',measdata.Bilevel.ShowAberrations,...
        'CyclesPanelOpen',measdata.Bilevel.ShowCycles);
    end
    mTriggers=struct.empty;
    if isfield(measdata,'Trigger')
        mTriggers=struct('Mode',neasdata.Trigger.Mode,...
        'Position',measdata.Trigger.Position,...
        'Type',measdata.Trigger.Type,...
        'Polarity',measdata.Trigger.Polarity,...
        'AutoLevel',measdata.Trigger.AutoLevel,...
        'Level',measdata.Trigger.Level,...
        'Hysteresis',measdata.Trigger.Hysteresis,...
        'UpperLevel',measdata.Trigger.HighLevel,...
        'LowerLevel',measdata.Trigger.LowLevel,...
        'MinTime',measdata.Trigger.MinDuration,...
        'MaxTime',measdata.Trigger.MaxDuration,...
        'Timeout',measdata.Trigger.Timeout,...
        'Delay',measdata.Trigger.Delay,...
        'Holdoff',measdata.Trigger.Holdoff,...
        'SourceOffset',1,...
        'MainPanelOpen',measdata.Trigger.Enabled,...
        'TypePanelOpen',false,...
        'SettingsPanelOpen',false,...
        'OffsetPanelOpen',false);
    end
    measStruct=struct('traceselector',struct('Line',1),...
    'peaks',mPeaks,'tcursors',mCursors,...
    'signalstats',struct.empty,'bilevel',mBilevel,'triggers',mTriggers);
    props={'Version',releaseStr,...
    'Measurements',measStruct};
    config.PropertySet=extmgr.PropertySet('-notype',props{:});
    currentConfig.add(config);
end


function target=addPropertyIfAvailable(target,source,propName)
    if isfield(source,propName)
        if iscell(target)
            target=horzcat(target,{propName,source.(propName)});
        else
            target.(propName)=source.(propName);
        end
    end
end


function[dispProps,slndx]=getDisplayProps(dc,style,dndx,slndx)

    dispProps.MinYLimReal=num2str(dc(dndx).MinYLimReal);
    dispProps.MaxYLimReal=num2str(dc(dndx).MaxYLimReal);
    dispProps.YLabelReal=dc(dndx).YLabel;
    dispProps.MinYLimMag=num2str(dc(dndx).MinYLimMag);
    dispProps.MaxYLimMag=num2str(dc(dndx).MaxYLimMag);
    dispProps.LegendVisibility=uiservices.logicalToOnOff(dc(dndx).ShowLegend);
    dispProps.XGrid=dc(dndx).ShowGrid;
    dispProps.YGrid=dc(dndx).ShowGrid;
    dispProps.PlotMagPhase=dc(dndx).PlotAsMagnitudePhase;
    dispProps.AxesColor=(style.AxesColor(:))';
    if isfield(style,'AxesTickColor')
        style.LabelsColor(:)=style.AxesTickColor(:);
    end
    dispProps.AxesTickColor=(style.LabelsColor(:))';
    dispProps.ColorOrder=uiscopes.getColorOrder(dispProps.AxesColor);
    dispProps.Title=dc(dndx).Title;

    if isfield(style,'NumLines')&&ischar(style.NumLines)
        style.NumLinesForDisplays=str2double(style.NumLines(dndx));
    end

    numLines=style.NumLinesForDisplays(dndx);
    try
        for lndx=1:numLines
            lpCache.Color=style.LineColor(slndx,:);%#ok<*AGROW>
            lpCache.LineStyle=style.LineStyle{slndx};
            lpCache.LineWidth=style.LineWidth(slndx);
            lpCache.Marker=style.Marker{slndx};
            lpCache.Visible='on';
            dispProps.LinePropertiesCache{lndx}=lpCache;
            slndx=slndx+1;
        end
        if numLines>0
            dispProps.UserDefinedChannelNames={style.ChannelNames};
            dispProps.NumLines=style.NumLinesForDisplays(dndx);
            dispProps.LineNames=style.DefaultLegendLabel(dndx);
            dispProps.ShowContent=true;
        end
    catch
    end
    dispProps.Placement=dndx;
end

