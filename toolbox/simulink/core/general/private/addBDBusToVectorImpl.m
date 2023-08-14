function[dstBlocks,busToVectorBlocks,ignoredBlocks]=addBDBusToVectorImpl(model,includeLibs,reportOnly,strictOnly)



















































































































    wStates=[warning;warning('query','backtrace')];
    warning off backtrace;

    s=onCleanup(@()warning(wStates));


    busToVectorBlocks=[];
    dstBlocks=[];
    ignoredBlocks=[];


    if(nargin<1||nargin>4)
        DAStudio.error('Simulink:utility:slAddBusToVectorUsage');
    end


    if nargin<4
        strictOnly=false;
    end
    if nargin<3
        reportOnly=true;
    end
    if nargin<2
        includeLibs=false;
    end



    model=check_input_model_l(model);



    [unique_buses_as_vectors,dstBlocks,ignoredBlocks]=get_buses_treated_as_vectors_l(model,includeLibs,strictOnly);
    if(isempty(unique_buses_as_vectors))
        disp(['###',DAStudio.message('Simulink:utility:slAddBusToVectorNoBusesFound')]);
        return;
    end

    if~reportOnly


        cell_buses_as_vectors_blockPaths={unique_buses_as_vectors.BlockPath};


        bds=strtok(cell_buses_as_vectors_blockPaths,'/');
        uniqueBds=unique(bds);
        uniqueLibs=setdiff(unique(bds),model);



        for idx=1:length(uniqueLibs)
            set_param(uniqueLibs{idx},'lock','off');
        end


        busToVectorBlocks=cell(length(unique_buses_as_vectors),1);
        insertErrors=[];
        for idx=1:length(unique_buses_as_vectors)
            try
                tmpBlockPath=getfullname(insert_BusToVector_block_l(unique_buses_as_vectors(idx)));
                busToVectorBlocks{idx}=tmpBlockPath;
            catch me
                newError.OrigBlockPath=unique_buses_as_vectors(idx).OrigBlockPath;
                newError.Inport=unique_buses_as_vectors(idx).InputPort;
                newError.Error=me;
                insertErrors=[insertErrors;newError];%#ok<AGROW>
            end
        end
        numErrors=length(insertErrors);

        if(numErrors==0)

            disp(['### ',DAStudio.message('Simulink:utility:slAddBusToVectorSuccessfullyInserted')]);
            disp(['### ',DAStudio.message('Simulink:utility:slAddBusToVectorEnableStrictBusError')]);
        else

            display_insert_warning_l(insertErrors);
            disp(['### ',DAStudio.message('Simulink:utility:slAddBusToVectorNotAllBlocksWereInserted')]);
        end


        save_and_close_if_has_lib_l(model,uniqueBds,uniqueLibs);


    end


    disp(['### ',DAStudio.message('Simulink:utility:slAddBusToVectorDoneProcessing',model)]);






end

function ioMdl=check_input_model_l(ioMdl)

    if isstring(ioMdl)
        ioMdl=convertStringsToChars(ioMdl);
    end

    if~ischar(ioMdl)

        if~ishandle(ioMdl)
            DAStudio.error('Simulink:utility:slAddBusToVectorUsage');
        end
        ioMdl=get_param(ioMdl,'Name');
    end


    load_system(ioMdl);


    simStatus=get_param(ioMdl,'SimulationStatus');
    if~strcmpi(simStatus,'stopped')
        DAStudio.error('Simulink:utility:slAddBusToVectorBadSimulationStatus',simStatus);
    end


    dirtyStr=get_param(ioMdl,'Dirty');
    if strcmpi(dirtyStr,'on')
        DAStudio.error('Simulink:utility:slAddBusToVectorUnsavedChanges');
    end

    currSetting=get_param(ioMdl,'StrictBusMsg');
    if(~isempty(strmatch(currSetting,{'None','Warning'},'exact')))
        DAStudio.error('Simulink:utility:slAddBusToVectorInvalidStrictBusMsg');
    end











end

function save_and_close_if_has_lib_l(model,uniqueBds,uniqueLibs)

    libModified=~isempty(uniqueLibs);
    mdlModified=length(uniqueBds)>length(uniqueLibs);


    if libModified
        disp(['### ',DAStudio.message('Simulink:utility:slAddBusToVectorLibrariesModified')]);

        savedAll=true;
        okToErr=false;



        for idx=1:length(uniqueBds)
            isOk=save_system_l(uniqueBds{idx},okToErr);
            if isOk
                close_system(uniqueBds{idx});
            else
                savedAll=false;
            end
        end




        if~mdlModified
            close_system(model,0);
        end


        if~savedAll
            DAStudio.error('Simulink:utility:slAddBusToVectorUnableToSaveModelLib');
        end
    else



        okToErr=true;
        save_system_l(model,okToErr);
    end







end

function isOk=save_system_l(model,okToError)
    isOk=true;
    try
        save_system(model);
    catch me
        isOk=false;

        if okToError
            DAStudio.error('Simulink:utility:slAddBusToVectorUnableToSave',model,me.message);
        else
            MSLDiagnostic('Simulink:utility:slAddBusToVectorUnableToSave',model,me.message).reportAsWarning;
        end
    end










end

function[unique_buses_as_vectors,buses_as_vectors,ignoredBlocks]=get_buses_treated_as_vectors_l(model,includeLibs,strictOnly)

    try




        if(strictOnly)
            sl('busUtils','SetUpgradeStatus',model,'on');
            c=onCleanup(@()sl('busUtils','SetUpgradeStatus',model,'off'));
        end

        cmd=[model,'(''init'');'];
        evalc(cmd);

        if(strictOnly)
            buses_as_vectors=get_param(model,'BusInputIntoStrictlyForbiddenNonBusBlock');
        else
            buses_as_vectors=get_param(model,'BusInputIntoNonBusBlock');
        end

        cmd=[model,'(''term'');'];
        evalc(cmd);

    catch me
        DAStudio.error('Simulink:utility:slAddBusToVectorCompilationError',me.message);
    end




    ignoredBlocks=[];
    if~isempty(buses_as_vectors)
        [buses_as_vectors,ignoredBlocks]=filter_blocks_l(buses_as_vectors,strictOnly);
    end




    buses_as_vectors=get_top_level_block_l(buses_as_vectors);

    unique_buses_as_vectors=buses_as_vectors;

    if isempty(buses_as_vectors),
        return;
    end

    disp(['### ',DAStudio.message('Simulink:utility:slAddBusToVectorUpdatingBD',model)]);



    for idx=1:length(unique_buses_as_vectors)
        unique_buses_as_vectors(idx).OrigBlockPath=unique_buses_as_vectors(idx).BlockPath;
    end


    buses_as_vectors(1).LibPath='';


    cell_buses_as_vectors_blockPaths={buses_as_vectors.BlockPath};
    cell_buses_as_vectors_portNums={buses_as_vectors.InputPort}';

    refBlks=get_param(cell_buses_as_vectors_blockPaths,'ReferenceBlock');




    ParentBlock=get_param(cell_buses_as_vectors_blockPaths,'Parent');
    isBlockDiagram=strcmp(get_param(ParentBlock,'Type'),'block_diagram');
    ParentRef=get_param(ParentBlock(~isBlockDiagram),'ReferenceBlock');
    RefReplaceMask=isBlockDiagram;
    RefReplaceMask(~isBlockDiagram)=strcmp(ParentRef,'');
    refBlks(RefReplaceMask)=repmat({''},sum(RefReplaceMask),1);







    refBlksIdx=find(~cellfun('isempty',refBlks));
    ParentRef=get_param(ParentBlock(refBlksIdx),'ReferenceBlock');
    BName=get_param(cell_buses_as_vectors_blockPaths(refBlksIdx),'Name');
    refBlks(refBlksIdx)=strcat(ParentRef,'/',BName);


    libBds=strtok(ParentRef,'/');
    if~iscell(libBds)
        libBds={libBds};
    end
    uniquelibBds=unique(libBds);

    for i=1:length(uniquelibBds)
        if~bdIsLoaded(uniquelibBds{i})
            load_system(uniquelibBds{i});
        end
    end


    refBlksP=strcat(refBlks,':',cellstr(num2str(cell2mat(cell_buses_as_vectors_portNums))));
    badLibIdx=[];
    badLibArray=[];





    for i=1:length(refBlksIdx)
        if~isempty(refBlksP{refBlksIdx(i)})
            libPath=get_param(refBlks{refBlksIdx(i)},'Parent');
            blkName=get_param(refBlks{refBlksIdx(i)},'Name');


            libInstances=find_system(model,'FollowLinks','on','LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'ReferenceBlock',libPath);
            refInst=strcat(libInstances,'/',blkName);




            libIdx=strmatch(refBlksP{refBlksIdx(i)},refBlksP,'exact');
            if length(libIdx)~=length(refInst)
                badLib=struct('libIdx',{refBlksIdx(i)},'libRefs',{refInst});
                badLibArray=[badLibArray;badLib];%#ok<AGROW>
            end




            refBlksP(libIdx)=repmat({''},length(libIdx),1);
        end
    end



    if~isempty(badLibArray)
        badLibIdx=[badLibArray.libIdx];
        badLibRefBlks=refBlks(badLibIdx);
        refBlksPrts=strcat(badLibRefBlks,':',...
        num2str(cell2mat(cell_buses_as_vectors_portNums(badLibIdx))));
        for iBadLib=1:length(refBlksPrts)



            msgStr=DAStudio.message('Simulink:utility:slAddBusToVectorErrorInsertingBlockMsg',...
            refBlksPrts{iBadLib});

            for i=1:size(badLibArray(iBadLib).libRefs,1)
                msgStr=[msgStr,sprintf('%s\n',badLibArray(iBadLib).libRefs{i})];%#ok<AGROW>
            end

            warning(message('Simulink:utility:slAddBusToVectorErrorInsertingBlock',msgStr));
        end
    end



    buses_as_vectors(badLibIdx)=[];
    refBlks(badLibIdx)=[];
    cell_buses_as_vectors_portNums(badLibIdx)=[];
    unique_buses_as_vectors(badLibIdx)=[];
    nFound=length(buses_as_vectors);
    if(nFound>0)



        DstBlksInMdlIdx=strmatch('',refBlks,'exact');
        if(includeLibs)
            [uniqueBlks,uniqueBlksIdx]=unique(strcat(refBlks,':',num2str(cell2mat(cell_buses_as_vectors_portNums))));
            allUniqueBlksIdx=union(DstBlksInMdlIdx,uniqueBlksIdx);
            uniqueBlksIdx=allUniqueBlksIdx;
            for refBlkIdx=1:length(refBlks)
                if~isempty(refBlks{refBlkIdx})
                    buses_as_vectors(refBlkIdx).LibPath=refBlks{refBlkIdx};
                    unique_buses_as_vectors(refBlkIdx).BlockPath=refBlks{refBlkIdx};
                end
            end
        else
            uniqueBlksIdx=DstBlksInMdlIdx;
        end
        unique_buses_as_vectors=unique_buses_as_vectors(uniqueBlksIdx);
    end

    disp(['### ',DAStudio.message('Simulink:utility:slAddBusToVectorReportModifiedNumbers',nFound)]);










end

function hB2VBlk=insert_BusToVector_block_l(block_info)


    DstBlock=block_info.BlockPath;
    DstPortIdx=block_info.InputPort;

    BlockParent=get_param(DstBlock,'Parent');

    hDstBlock=get_param(DstBlock,'handle');
    DstBlockOrient=get_param(hDstBlock,'Orientation');

    DstPortLineHandles=get_param(hDstBlock,'LineHandles');
    DstPortLineH=DstPortLineHandles.Inport(DstPortIdx);
    LinePoints=get_param(DstPortLineH,'Points');


    Girth=20;MinGirth=14;Separation=14;
    switch(lower(DstBlockOrient))
    case 'left'
        LastSegmentLen=abs(LinePoints(end,1)-LinePoints(end-1,1));
        Girth=max(MinGirth,min(Girth,LastSegmentLen-2*Separation));
        x1=LinePoints(end,1)+Separation;
        y1=max(0,LinePoints(end,2)-Girth/2);
    case 'right'
        LastSegmentLen=abs(LinePoints(end,1)-LinePoints(end-1,1));
        Girth=max(MinGirth,min(Girth,LastSegmentLen-2*Separation));
        x1=max(0,LinePoints(end,1)-Girth-Separation);
        y1=max(0,LinePoints(end,2)-Girth/2);
    case 'up'
        LastSegmentLen=abs(LinePoints(end,2)-LinePoints(end-1,2));
        Girth=max(MinGirth,min(Girth,LastSegmentLen-2*Separation));
        x1=max(0,LinePoints(end,1)-Girth/2);
        y1=LinePoints(end,2)+Separation;
    case 'down'
        LastSegmentLen=abs(LinePoints(end,2)-LinePoints(end-1,2));
        Girth=max(MinGirth,min(Girth,LastSegmentLen-2*Separation));
        x1=max(0,LinePoints(end,1)-Girth/2);
        y1=max(0,LinePoints(end,2)-Separation-Girth);
    end

    pos=[x1,y1,x1+Girth,y1+Girth];

    decorations=get_decoration_params_l(hDstBlock);

    hB2VBlk=add_block('built-in/BusToVector',...
    [BlockParent,'/Bus to Vector'],'MakeNameUnique','on','Position',...
    pos,decorations{:});




    hSrcBlk=get_param(DstPortLineH,'SrcBlockHandle');
    hSrcPrt=get_param(DstPortLineH,'SrcPortHandle');
    strSrc=sprintf('%s/%d',get_param(hSrcBlk,'Name'),get_param(hSrcPrt,'PortNumber'));
    strDst=sprintf('%s/%d',get_param(hB2VBlk,'Name'),1);
    hNewB2VInportLine=add_line(BlockParent,strSrc,strDst,'autorouting','on');%#ok<NASGU>
    delete_line(DstPortLineH);


    strSrc=sprintf('%s/%d',get_param(hB2VBlk,'Name'),1);
    strDst=sprintf('%s/%d',get_param(hDstBlock,'Name'),DstPortIdx);
    hNewDstInportLineHandle=add_line(BlockParent,strSrc,strDst,'autorouting','on');%#ok<NASGU>







end

function decorations=get_decoration_params_l(block)
    decorations={
    'Orientation',[];
    'ForegroundColor',[];
    'BackgroundColor',[];
    'DropShadow',[];
    'NamePlacement',[];
    'FontName',[];
    'FontSize',[];
    'FontWeight',[];
    'FontAngle',[];
    'ShowName',[]
    };

    num=size(decorations,1);
    for i=1:num,
        decorations{i,2}=get_param(block,decorations{i,1});
    end
    decorations=reshape(decorations',1,length(decorations(:)));



end

function display_insert_warning_l(insertErrors)

    msg='';
    for idx=1:length(insertErrors)
        msg=[msg,DAStudio.message('Simulink:utility:slAddBusToVectorErrorInsertingBlockDescription',...
        insertErrors(idx).OrigBlockPath,insertErrors(idx).Inport,insertErrors(idx).Error.message)];%#ok<AGROW>
    end
    warning(message('Simulink:utility:slAddBusToVectorErrorInsertingBlock',msg));






end

function[buses_as_vectors,ignoredBlocks]=filter_blocks_l(buses_as_vectors,strictOnly)

    blocks={buses_as_vectors.BlockPath};
    isMixedAttrib=logical([buses_as_vectors.MixedAttributes]');

    if~strictOnly
        isSelectorMask=strcmp('Selector',get_param(blocks,'BlockType'));
        if any(isSelectorMask)

            msg=[];
            bkIdx=find(isSelectorMask);
            for i=1:length(bkIdx)
                msg=[msg,sprintf('%s\n',blocks{bkIdx(i)})];%#ok<AGROW>
            end

            MSLDiagnostic('Simulink:utility:slAddBusToVectorIgnoringSelector',msg).reportAsWarning;
        end



        isMixedAttrib(isSelectorMask)=false;
    end

    if any(isMixedAttrib)

        msg=[];
        bkIdx=find(isMixedAttrib);
        for i=1:length(bkIdx)
            msg=[msg,sprintf('%s\n',blocks{bkIdx(i)})];%#ok<AGROW>
        end

        if~strictOnly
            MSLDiagnostic('Simulink:utility:slAddBusToVectorIgnoringDemux',msg).reportAsWarning;
        end




    end

    if~strictOnly
        ignoredBlocks=buses_as_vectors(isSelectorMask|isMixedAttrib);
        buses_as_vectors(isSelectorMask|isMixedAttrib)=[];
    else
        ignoredBlocks=buses_as_vectors(isMixedAttrib);
        buses_as_vectors(isMixedAttrib)=[];
    end
    ignoredBlocks=rmfield(ignoredBlocks,'MixedAttributes');
    buses_as_vectors=rmfield(buses_as_vectors,'MixedAttributes');











end

function buses_as_vectors=get_top_level_block_l(buses_as_vectors)

    for iBlockPort=1:numel(buses_as_vectors)

        hDstBlock=get_param(buses_as_vectors(iBlockPort).BlockPath,'Handle');
        DstPortIdx=buses_as_vectors(iBlockPort).InputPort;

        [hTopBlock,TopPortIdx]=get_top_block_and_port_l(hDstBlock,DstPortIdx);

        buses_as_vectors(iBlockPort).BlockPath=getfullname(hTopBlock);
        buses_as_vectors(iBlockPort).InputPort=TopPortIdx;
    end



end

function[hTopBlock,TopPortIdx]=get_top_block_and_port_l(hTopBlock,TopPortIdx)

    DstPortLineHandles=get_param(hTopBlock,'LineHandles');

    if(~isempty(DstPortLineHandles.Inport)&&...
        (numel(DstPortLineHandles.Inport)>=TopPortIdx)&&...
        DstPortLineHandles.Inport(TopPortIdx)~=-1)

        hTopPortLine=DstPortLineHandles.Inport(TopPortIdx);

        hSrcBlock=get_param(hTopPortLine,'SrcBlockHandle');

        if(~isempty(hSrcBlock)&&strcmpi(get_param(hSrcBlock,'BlockType'),'Inport'))
            Parent=get_param(hSrcBlock,'Parent');
            if(~strcmpi(get_param(Parent,'type'),'block_diagram'))
                hParent=get_param(Parent,'Handle');
                [hTopBlock,TopPortIdx]=get_top_block_and_port_l(hParent,str2double(get_param(hSrcBlock,'Port')));
            end
        end
    end




end

