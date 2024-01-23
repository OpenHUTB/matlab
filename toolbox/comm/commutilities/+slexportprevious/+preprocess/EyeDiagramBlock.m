function EyeDiagramBlock(obj)

    webporting=false;
    if webporting&&isR2021bOrEarlier(obj.ver)

        obj.appendRule('<Block<BlockType|EyeDiagram><PlotImaginaryAxes:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><SamplesPerSymbol:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><SampleOffset:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><SymbolsPerTrace:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><TracesToDisplay:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><ShowGrid:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><InputInterpolation:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><ColorFading:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><Title:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><YLimits:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><RealAxesLabel:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><ImaginaryAxesLabel:remove>>');

        obj.appendRule('<Block<BlockType|EyeDiagram><EyeDisplay:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><DisplayMode:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><ColorScale:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><HistogramOverlay:remove>>');

        obj.appendRule('<Block<BlockType|EyeDiagram><EnableMeasurements:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><ShowBathtubs:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><TargetBER:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><OpenAtSimulationStart:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><FrameBasedProcessing:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><Visible:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><OpenAtSimulationStart:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><GraphicalSettings:remove>>');
        obj.appendRule('<Block<BlockType|EyeDiagram><WindowPosition:remove>>');

        eyeBlks=find_scopes(obj);
        for idx=1:numel(eyeBlks)
            mapScopeParameters(obj,eyeBlks{idx},obj.modelName);
        end
    end
    if isR2014aOrEarlier(obj.ver)
        edBlocks=find_system(obj.modelName,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'IncludeCommented','on','IOType','none','BlockType','EyeDiagram');
        edViewers=find_system(obj.modelName,'AllBlocks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'IOType','viewer','BlockType','EyeDiagram');

        if~isempty(edBlocks)||~isempty(edViewers)

            allEDBlks=cell(2,1);
            allEDBlks{1}=edBlocks;
            allEDBlks{2}=edViewers;
            viewer=2;
            MaskVariables='sampPerSymb=@1;offsetEye=@2;symbPerTrace=@3;numTraces=@4;numNewFrames=@5;LineMarkers=&6;LineStyles=&7;LineColors=&8;dupPoints=@9;fading=@10;render=@11;AxisGrid=&12;yMin=@13;yMax=@14;inphaseLabel=&15;quadratureLabel=&16;openScopeAtSimStart=@17;dispDiagram=@18;FrameNumber=&19;FigPos=@20;figTitle=&21;block_type_=@22;numLinesMax=@23;';

            for edIdx=1:2

                if~isempty(allEDBlks{edIdx})
                    edBlks=allEDBlks{edIdx};
                else
                    continue;
                end

                if edIdx==viewer
                    lib_mdl=obj.getTempViewerLib;
                else
                    lib_mdl=getTempLib(obj);
                end
                libBlock=[lib_mdl,'/',obj.generateTempName];
                set_param(lib_mdl,'LibraryType','BlockLibrary');
                add_block('built-in/S-Function',libBlock);

                if edIdx==viewer
                    set_param(lib_mdl,'LibraryType','ssMgrViewerLibrary');
                    set_param(libBlock,'IOType','viewer');
                end

                set_param(libBlock,...
                'Mask','on',...
                'MaskVariables',MaskVariables,...
                'MaskType','Discrete-Time Eye Diagram Scope');
                pmask=Simulink.Mask.get(libBlock);
                y=pmask.getParameter('dispDiagram');
                y.Evaluate='off';

                save_system(lib_mdl);

                sfuncBlock=libBlock;
                for i=1:length(edBlks)
                    blk=edBlks{i};
                    s=get_param(blk,'ScopeConfiguration');
                    figPos=sprintf('[%s]',num2str(s.Position));

                    if edIdx==viewer
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
                        end
                    catch

                    end
                    [newParamsNames,newParamsValues]=convertParameters(ud);

                    ud.Scope=[];
                    set_param(blk,'UserData',ud);

                    obj.replaceBlock(blk,sfuncBlock);

                    set_param(blk,'FigPos',figPos);

                    for j=1:length(newParamsNames)
                        set_param(blk,newParamsNames{j},newParamsValues{j});
                    end

                    if edIdx==viewer
                        set_param(blk,'IOSignals',vs);
                    end

                end

                newRef=sfuncBlock;

                if edIdx==viewer

                    oldRef='commviewers2/Discrete-Time\nEye Diagram\nScope';

                else
                    oldRef='commsink2/Discrete-Time\nEye Diagram\nScope';
                end
                obj.appendRule(slexportprevious.rulefactory.replaceInSourceBlock(...
                'SourceBlock',newRef,oldRef));

            end

        end

    end

end


function[newParamsNames,newParamsValues]=convertParameters(ud)
    lineProperties=ud.Scope.getScopeParam('Visuals','Eye Diagram','LineProperties');

    index=1;

    newParamsNames{index}='sampPerSymb';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Eye Diagram','SamplesPerSymbol');
    index=index+1;

    newParamsNames{index}='offsetEye';
    newVersionOffset=ud.Scope.getScopeParam('Visuals','Eye Diagram','SampleOffset');
    sps=str2double(ud.Scope.getScopeParam('Visuals','Eye Diagram','SamplesPerSymbol'));
    symbPerTrace=str2double(ud.Scope.getScopeParam('Visuals','Eye Diagram','SymbolsPerTrace'));
    oldVersionOffset=str2double(newVersionOffset)-round(sps/2);
    if oldVersionOffset<0
        oldVersionOffset=sps*symbPerTrace-abs(oldVersionOffset);
    end
    newParamsValues{index}=num2str(oldVersionOffset);
    index=index+1;

    newParamsNames{index}='symbPerTrace';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Eye Diagram','SymbolsPerTrace');
    index=index+1;

    newParamsNames{index}='numTraces';
    nt=ud.Scope.getScopeParam('Visuals','Eye Diagram','TracesToDisplay');
    newParamsValues{index}=nt;
    index=index+1;

    newParamsNames{index}='numNewFrames';

    newParamsValues{index}=nt;
    index=index+1;

    newParamsNames{index}='LineMarkers';
    if~isempty(lineProperties)
        newParamsValues{index}=lineProperties.Marker;
    else
        newParamsValues{index}='';
    end
    index=index+1;

    newParamsNames{index}='LineStyles';
    if~isempty(lineProperties)
        newParamsValues{index}=lineProperties.LineStyle;
    else
        newParamsValues{index}='-';
    end
    index=index+1;

    newParamsNames{index}='LineColors';
    newParamsValues{index}='b';
    index=index+1;

    newParamsNames{index}='dupPoints';

    newParamsValues{index}='on';
    index=index+1;

    newParamsNames{index}='fading';
    if ud.Scope.getScopeParam('Visuals','Eye Diagram','ColorFading')
        newParamsValues{index}='on';
    else
        newParamsValues{index}='off';
    end
    index=index+1;

    newParamsNames{index}='render';

    newParamsValues{index}='on';
    index=index+1;

    newParamsNames{index}='AxisGrid';
    if ud.Scope.getScopeParam('Visuals','Eye Diagram','Grid')
        newParamsValues{index}='on';
    else
        newParamsValues{index}='off';
    end
    index=index+1;

    newParamsNames{index}='yMin';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Eye Diagram','MinYLim');
    index=index+1;

    newParamsNames{index}='yMax';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Eye Diagram','MaxYLim');
    index=index+1;

    newParamsNames{index}='inphaseLabel';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Eye Diagram','InphaseLabel');
    index=index+1;

    newParamsNames{index}='quadratureLabel';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Eye Diagram','QuadratureLabel');
    index=index+1;

    newParamsNames{index}='openScopeAtSimStart';
    if ud.Scope.ScopeCfg.OpenAtMdlStart
        newParamsValues{index}='on';
    else
        newParamsValues{index}='off';
    end
    index=index+1;

    newParamsNames{index}='dispDiagram';
    strValue=ud.Scope.getScopeParam('Visuals','Eye Diagram','EyeDisplay');
    if strcmp(strValue,'InPhaseAndQuadrature')||strcmp(strValue,'Eye_Display_two')
        newParamsValues{index}='In-phase and Quadrature';
    elseif strcmp(strValue,'InPhaseOnly')||strcmp(strValue,'Eye_Display_one')
        newParamsValues{index}='In-phase Only';
    end
    index=index+1;

    newParamsNames{index}='FrameNumber';

    newParamsValues{index}='off';
    index=index+1;

    newParamsNames{index}='figTitle';
    newParamsValues{index}=ud.Scope.getScopeParam('Visuals','Eye Diagram','Title');
    index=index+1;

    newParamsNames{index}='block_type_';

    newParamsValues{index}='eye';
    index=index+1;

    newParamsNames{index}='numLinesMax';

    newParamsValues{index}='8';

end


function edBlks=find_scopes(obj)
    edBlks=obj.findBlocksOfType('EyeDiagram');
    edBlks_viewers=obj.findBlocksOfType('EyeDiagram','IOType','viewer');
    edBlks=[edBlks;edBlks_viewers];
end


function mapScopeParameters(~,edBlk,~)
    cfg=get_param(edBlk,'ScopeConfiguration');
    set_param(edBlk,'ScopeSpecificationString',toScopeSpecificationString(cfg));
    set_param(edBlk,'DefaultConfigurationName','comm.scopes.EyeDiagramBlockCfg');
end


