function ConstellationDiagramBlock(obj)







    if isR2021bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|ConstellationDiagram><ScopeFrameLocation:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><IsFloating:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><WasSavedAsWebScope:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><ExpandToolstrip:remove>>');


        obj.appendRule('<Block<BlockType|ConstellationDiagram><NumInputPorts:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><SamplesPerSymbol:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><SampleOffset:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><SymbolsToDisplaySource:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><SymbolsToDisplay:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><ReferenceConstellation:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><ReferenceMarker:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><ReferenceColor:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><ShowReferenceConstellation:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><ShowGrid:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><ShowLegend:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><ShowTrajectory:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><ColorFading:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><Title:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><XLimits:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><YLimits:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><XLabel:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><YLabel:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><EnableMeasurements:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><MeasurementInterval:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><EVMNormalization:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><MaximizeAxes:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><OpenAtSimulationStart:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><FrameBasedProcessing:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><Visible:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><GraphicalSettings:remove>>');
        obj.appendRule('<Block<BlockType|ConstellationDiagram><WindowPosition:remove>>');



        cdBlks=find_scopes(obj);
        for idx=1:numel(cdBlks)

            mapScopeParameters(obj,cdBlks{idx},obj);
        end
    end
    if isR2018bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|ConstellationDiagram><ScopeSpecificationString:remove>>');


        consBlocks=find_system(obj.modelName,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType','ConstellationDiagram');
        for jndx=1:numel(consBlocks)
            [~,origBlock]=strtok(consBlocks{jndx},'/');
            parentSys=get_param(consBlocks{jndx},'Parent');
            numInputPorts=str2double(get_param([obj.origModelName,origBlock],'NumInputPorts'));
            if numInputPorts>1
                currBlk=consBlocks{jndx};

                CDPorts=get_param(currBlk,'PortHandles');
                hLines=-ones(length(CDPorts.Inport),1);
                hLineSrcPort=-ones(length(CDPorts.Inport),1);
                for indx=1:length(CDPorts.Inport)
                    hLines(indx)=get_param(CDPorts.Inport(indx),'Line');
                    if hLines(indx)~=-1
                        hLineSrcPort(indx)=get_param(hLines(indx),'SrcPortHandle');
                    end
                end

                set_param(currBlk,'NumInputPorts','1');







                for indx=1:numInputPorts
                    if hLines(indx)~=-1

                        pos=get_param(currBlk,'Position');
                        switch get_param(currBlk,'Orientation')
                        case 'up'
                            CDPos=pos-[0,30,0,30];
                        case 'down'
                            CDPos=pos+[0,30,0,30];
                        case 'left'
                            CDPos=pos-[30,0,30,0];
                        case 'right'
                            CDPos=pos+[30,0,30,0];
                        end
                        set_param(currBlk,'Position',CDPos);

                        Newblock=add_block(currBlk,[currBlk,':',num2str(indx)]);
                        NewblockPort=get_param(Newblock,'PortHandles');
                        hLine_Concat=get_param(NewblockPort.Inport(1),'Line');
                        if hLineSrcPort(indx)~=-1




                            if hLine_Concat==-1||...
                                ~isequal(get_param(hLine_Concat,'SrcPortHandle'),hLineSrcPort(indx))
                                lineName=get_param(hLines(indx),'Name');
                                delete_line(hLines(indx));
                                CDPorts=get_param(Newblock,'PortHandles');
                                newLine=add_line(parentSys,hLineSrcPort(indx),...
                                CDPorts.Inport(1),'autorouting','on');
                                set_param(newLine,'Name',lineName);
                            end
                        else


                            delete_line(hLines(indx));
                        end
                    end
                end

                delete_block(currBlk);
            end
        end
    end

    if isR2014aOrEarlier(obj.ver)
        obj.appendRule('<Block<BlockType|ConstellationDiagram><ScopeSpecificationString:remove>>');


        consBlocks=find_system(obj.modelName,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType','ConstellationDiagram');
        for indx=1:numel(consBlocks)
            [~,origBlock]=strtok(consBlocks{indx},'/');
            scopeSpec=get_param([obj.origModelName,origBlock],'ScopeSpecificationObject');
            if~isempty(scopeSpec)
                scopeSpec=copy(scopeSpec);
                set_param(consBlocks{indx},...
                'ScopeSpecificationObject',scopeSpec,...
                'ScopeSpecification',scopeSpec);
                scopeSpec.SaveAsString=false;
                if isempty(scopeSpec.ScopeCLI)
                    scopeSpec.ScopeCLI=uiscopes.ScopeCLI;
                end
                if~isempty(scopeSpec.CurrentConfiguration)
                    cc=scopeSpec.CurrentConfiguration.Children;
                    for jndx=1:numel(cc)
                        if isempty(cc(jndx).PropertySet)
                            cc(jndx).PropertySet=extmgr.PropertySet;
                        end
                    end
                end
            end
        end



        i_replaceConstellationDiagramWithDiscreteTimeBlock(obj,true);
    end

    if isR2013bOrEarlier(obj.ver)


        consBlocks=find_system(obj.modelName,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'IncludeCommented','on','BlockType','ConstellationDiagram');
        for indx=1:numel(consBlocks)
            scopeSpec=get_param(consBlocks{indx},'ScopeSpecification');
            if~isempty(scopeSpec)
                scopeSpec.SaveAsString=false;
            end
        end
    end

    if isR2013aOrEarlier(obj.ver)


        i_replaceConstellationDiagramWithDiscreteTimeBlock(obj,false);


    end


end

function i_replaceConstellationDiagramWithDiscreteTimeBlock(obj,toTrajectoryScope)











    tsBlocks=find_system(obj.modelName,'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'IncludeCommented','on','IOType','none','BlockType','ConstellationDiagram');





    tsViewers=find_system(obj.modelName,'AllBlocks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'IOType','viewer','BlockType','ConstellationDiagram');

    if~isempty(tsBlocks)||~isempty(tsViewers)

        allCDBlks=cell(2,1);
        allCDBlks{1}=tsBlocks;
        allCDBlks{2}=tsViewers;
        viewer=2;

        MaskVariables='sampPerSymb=@1;offsetEye=@2;numTraces=@3;numNewFrames=@4;LineMarkers=&5;LineStyles=&6;LineColors=&7;fading=@8;render=@9;AxisGrid=&10;xMin=@11;xMax=@12;yMin=@13;yMax=@14;inphaseLabel=&15;quadratureLabel=&16;openScopeAtSimStart=&17;FrameNumber=&18;FigPos=@19;figTitle=&20;numLinesMax=@21;block_type_=@22;';




        for cdIdx=1:2

            if~isempty(allCDBlks{cdIdx})
                tsBlks=allCDBlks{cdIdx};
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


            if toTrajectoryScope
                set_param(libBlock,'Mask','on','MaskVariables',...
                MaskVariables,'MaskType','Discrete-Time Signal Trajectory Scope');
            else
                set_param(libBlock,'Mask','on','MaskVariables',...
                MaskVariables,'MaskType','Discrete-Time Scatter Plot Scope');
            end


            save_system(lib_mdl);


            for i=1:length(tsBlks)
                blk=tsBlks{i};


                scopeConfig=get_param(blk,'ScopeConfiguration');
                blkShowTrajectory=scopeConfig.ShowTrajectory;

                if blkShowTrajectory~=toTrajectoryScope
                    continue;
                end


                params={'Orientation','Position','FigPos'};
                paramValues=cell(size(params));
                paramValues{1}=get_param(blk,params{1});
                paramValues{2}=get_param(blk,params{2});
                paramValues{3}=sprintf('[%s]',num2str(scopeConfig.Position));

                if cdIdx==viewer
                    vs=get_param(blk,'IOSignals');
                end

                scope=scopeextensions.ScopeBlock.getInstanceForCoreBlock(blk);

                ud=get_param(blk,'UserData');

                try
                    if isempty(ud)
                        ud=struct;
                    end
                    if~isempty(scope)
                        ud.Scope=scope;
                        scopeCfg=get_param(blk,'ScopeSpecification');
                        if~isempty(scopeCfg)
                            scope.pScopeCfg=copy(scopeCfg);
                        end
                        if~isempty(scope.ScopeCfg)
                            scope.ScopeCfg.SaveAsString=false;
                        end
                    end
                catch

                end

                [newParamsNames,newParamsValues]=convertParameters(ud,toTrajectoryScope);

                ud.Scope=[];
                set_param(blk,'UserData',ud);



                if~isR2012aOrEarlier(obj.ver)
                    commented=get_param(blk,'Commented');
                end


                delete_block(blk);


                add_block(libBlock,blk);

                if~isR2012aOrEarlier(obj.ver)
                    set_param(blk,'Commented',commented);
                end


                for j=1:length(params)
                    set_param(blk,params{j},paramValues{j});
                end
                for j=1:length(newParamsNames)
                    set_param(blk,newParamsNames{j},newParamsValues{j});
                end

                if cdIdx==viewer
                    set_param(blk,'IOSignals',vs);
                end

            end


            newRef=libBlock;

            if cdIdx==viewer

                if toTrajectoryScope
                    oldRef='commviewers2/Discrete-Time\nSignal Trajectory\nScope';
                else
                    oldRef='commviewers2/Discrete-Time\nScatter Plot\nScope';
                end
            else

                if toTrajectoryScope
                    oldRef='commsink2/Discrete-Time\nSignal Trajectory\nScope';
                else
                    oldRef='commsink2/Discrete-Time\nScatter Plot\nScope';
                end
            end

            obj.appendRule(slexportprevious.rulefactory.replaceInSourceBlock(...
            'SourceBlock',newRef,oldRef));
        end

    end

end


function[newParamsNames,newParamsValues]=convertParameters(ud,showTrajectory)




    lineProperties=ud.Scope.getScopeParam('Visuals','Constellation','LineProperties');

    index=1;


    newParamsNames{index}='sampPerSymb';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Constellation','SamplesPerSymbol');
    index=index+1;


    newParamsNames{index}='offsetEye';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Constellation','SampleOffset');
    index=index+1;


    newParamsNames{index}='numTraces';
    if ud.Scope.getScopeParam('Visuals','Constellation','SymbolsToDisplayFromInput')

        nt='40';
    else
        nt=ud.Scope.getScopeParam('Visuals','Constellation','SymbolsToDisplay');
    end
    newParamsValues{index}=nt;
    index=index+1;


    newParamsNames{index}='numNewFrames';

    newParamsValues{index}=nt;
    index=index+1;


    newParamsNames{index}='LineMarkers';
    if showTrajectory
        newParamsValues{index}='';
    else
        if~isempty(lineProperties)
            newParamsValues{index}=lineProperties.Marker;
        else
            newParamsValues{index}='.';
        end
    end
    index=index+1;


    newParamsNames{index}='LineStyles';
    if showTrajectory
        if~isempty(lineProperties)
            newParamsValues{index}=lineProperties.LineStyle;
        else
            newParamsValues{index}='-';
        end
    else

        newParamsValues{index}='';
    end
    index=index+1;



    newParamsNames{index}='LineColors';
    newParamsValues{index}='b';
    index=index+1;



    newParamsNames{index}='fading';
    if ud.Scope.getScopeParam('Visuals','Constellation','ColorFading')
        newParamsValues{index}='on';
    else
        newParamsValues{index}='off';
    end
    index=index+1;


    newParamsNames{index}='Render';

    newParamsValues{index}='on';
    index=index+1;


    newParamsNames{index}='AxisGrid';
    if ud.Scope.getScopeParam('Visuals','Constellation','Grid')
        newParamsValues{index}='on';
    else
        newParamsValues{index}='off';
    end
    index=index+1;


    newParamsNames{index}='xMin';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Constellation','MinXLim');
    index=index+1;


    newParamsNames{index}='xMax';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Constellation','MaxXLim');
    index=index+1;


    newParamsNames{index}='yMin';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Constellation','MinYLim');
    index=index+1;


    newParamsNames{index}='yMax';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Constellation','MaxYLim');
    index=index+1;


    newParamsNames{index}='inphaseLabel';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Constellation','XLabel');
    index=index+1;


    newParamsNames{index}='quadratureLabel';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Constellation','YLabel');
    index=index+1;


    newParamsNames{index}='openScopeAtSimStart';
    if ud.Scope.ScopeCfg.OpenAtMdlStart
        newParamsValues{index}='on';
    else
        newParamsValues{index}='off';
    end
    index=index+1;

    newParamsNames{index}='numLinesMax';

    newParamsValues{index}='8';
    index=index+1;


    newParamsNames{index}='FrameNumber';

    newParamsValues{index}='off';
    index=index+1;


    newParamsNames{index}='figTitle';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Constellation','Title');
    index=index+1;


    newParamsNames{index}='numLinesMax';

    newParamsValues{index}='8';
    index=index+1;


    newParamsNames{index}='block_type_';

    if showTrajectory
        newParamsValues{index}='xy';
    else
        newParamsValues{index}='scatter';
    end

end

function cdBlks=find_scopes(obj)

    cdBlks=obj.findBlocksOfType('ConstellationDiagram');
    cdBlks_viewers=obj.findBlocksOfType('ConstellationDiagram','IOType','viewer');
    cdBlks=[cdBlks;cdBlks_viewers];
end

function mapScopeParameters(~,newCDBlk,obj)
    oldCDBlk=regexprep(newCDBlk,obj.modelName,obj.origModelName);
    oldcfg=get_param(oldCDBlk,'ScopeConfiguration');

    new_ScopeSpecStr='';
    try
        new_ScopeSpecStr=toScopeSpecificationString(oldcfg);
    catch
        if~isempty(get_param(newCDBlk,'ScopeSpecificationString'))
            new_ScopeSpecStr=get_param(newCDBlk,'ScopeSpecificationString');
        end
    end
    set_param(newCDBlk,'ScopeSpecificationString',new_ScopeSpecStr);

    set_param(newCDBlk,'DefaultConfigurationName','comm.scopes.ConstellationDiagramBlockCfg');

    sid=slexportprevious.utils.escapeSIDFormat(get_param(newCDBlk,'SID'));
    prop='ShowTrajectory';
    obj.appendRule(['<Block<SID|"',sid,'">','<',prop,':remove>>']);
end
