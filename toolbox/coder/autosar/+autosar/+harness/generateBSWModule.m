function[slFunctions,canvasArea,addedBlocks]=generateBSWModule(ownerH,harnessH,...
    slFunctions,canvasArea,cutBlockPos,onCreate)%#ok<INUSD>






    addedBlocks=[];

    isBlockDiagram=strcmp(get_param(ownerH,'Type'),'block_diagram');
    isCompositionBlock=...
    autosar.composition.Utils.isCompositionBlock(ownerH);
    isModelBlock=strcmp(get_param(ownerH,'Type'),'block')&&...
    strcmp(get_param(ownerH,'BlockType'),'ModelReference');

    addingBSWSupported=isBlockDiagram||isModelBlock||isCompositionBlock;

    if~addingBSWSupported










        return
    end



    bswFcnCallerIndices=[];
    serviceBlocks={};
    for fcnIdx=1:length(slFunctions)
        slFunction=slFunctions{fcnIdx};

        serviceBlock=autosar.bsw.ServiceComponent.getServiceBlockForAppFcnName(slFunction.name);
        if~isempty(serviceBlock)
            bswFcnCallerIndices(end+1)=fcnIdx;%#ok<AGROW>
            serviceBlocks{end+1}=serviceBlock;%#ok<AGROW>
        end
    end

    if isempty(serviceBlocks)
        return
    end


    if~bdIsLoaded('autosarlibdem')
        load_system('autosarlibdem');
    end
    if~bdIsLoaded('autosarlibnvm')
        load_system('autosarlibnvm');
    end


    serviceBlocks=unique(serviceBlocks);
    harnessName=get_param(harnessH,'Name');
    midX=(cutBlockPos(1)+cutBlockPos(3))/2;
    verticalGap=100;
    bottom=canvasArea(4)+verticalGap;
    for compIdx=1:length(serviceBlocks)
        serviceBlock=serviceBlocks{compIdx};


        serviceBlockAlreadyExist=~isempty(find_system(harnessName,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'MaskType',get_param(serviceBlock,'MaskType')));
        if serviceBlockAlreadyExist
            continue;
        end
        blkPath=[harnessName,'/',get_param(serviceBlock,'Name')];
        addedBlock=add_block(serviceBlock,blkPath,...
        'MakeNameUnique','on');
        autosar.mm.mm2sl.MRLayoutManager.moveBlk(addedBlock,midX-70,bottom);
        addedBlocks(end+1)=addedBlock;%#ok<AGROW>
        bottom=bottom+verticalGap;
    end



    if~isempty(addedBlocks)
        topBlkPosition=get_param(addedBlocks(1),'Position');
        bottomBlkPosition=get_param(addedBlocks(end),'Position');
        offset=30;
        areaX=topBlkPosition(1)-offset;
        areaY=topBlkPosition(2)-offset;
        areaW=topBlkPosition(3)-topBlkPosition(1)+offset*2;
        areaH=bottomBlkPosition(4)-topBlkPosition(2)+offset*2;
        posArea=[areaX,areaY,areaX+areaW,areaY+areaH];
        violetColor='[0.901961, 0.901961, 1.000000]';
        add_block('built-in/Area',[harnessName,'/Service_Component_Blocks_Area'],...
        'Position',posArea,...
        'Text','AUTOSAR Basic Software Services',...
        'FontSize',12,...
        'ForegroundColor',violetColor);
    end


    slFunctions(bswFcnCallerIndices)=[];
    canvasArea(4)=bottom;

end




