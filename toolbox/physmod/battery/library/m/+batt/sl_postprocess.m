function sl_postprocess(h)




    thisLibraryPath=fullfile(matlabroot,'toolbox','physmod','battery','library','m','batt_lib.slx');
    addLibraryLinks(h,thisLibraryPath);


    reorganizeLibrary(h);


    updateAnnotationPosition(h);


    validateNames=nesl_private('nesl_validatenames');
    validateNames(h);
end

function addLibraryLinks(thisLibrary,thisLibraryPath)



    energyStorageSublibraryName='Cells';
    fromBlockToSublibrary={'batteryecm_lib/Battery',energyStorageSublibraryName;...
    ['batteryecm_lib/Battery',newline,'(Table-Based)'],energyStorageSublibraryName;...
    };
    thisLibraryName=get_param(thisLibrary,'Name');


    allLibraries=strtok(fromBlockToSublibrary(:,1),'/');
    allLibraries=unique(allLibraries);
    otherLibraries=setdiff(allLibraries,thisLibraryName);
    load_system(otherLibraries);



    if exist(thisLibraryPath,'file')
        delete(thisLibraryPath);
    end
    save_system(thisLibrary,thisLibraryPath);

    for blockIdx=1:size(fromBlockToSublibrary,1)

        source=fromBlockToSublibrary{blockIdx,1};
        [~,shortBlockName,~]=fileparts(source);

        dest=[thisLibraryName,'/',fromBlockToSublibrary{blockIdx,2},'/',shortBlockName];
        h=add_block(source,dest);
        set_param(h,'ShowName','on','HideAutomaticName','on');
    end


    nesl_libautolayout(thisLibrary);


    bdclose(otherLibraries);
end

function reorganizeLibrary(thisLibrary)



    horizontalSpacingFactor=1;
    verticalSpacingFactor=1.3;


    if ishandle(thisLibrary)
        thisPath=get_param(thisLibrary,'Path');
        thisName=get_param(thisLibrary,'Name');
        if~isempty(thisPath)
            thisLibrary=[thisPath,'/',thisName];
        else
            thisLibrary=thisName;
        end
    end


    blocks=find_system(thisLibrary,'SearchDepth',1,'Type','Block');

    blocks=blocks(~strcmp(thisLibrary,blocks));
    nBlocks=length(blocks);


    if isempty(blocks)
        return
    end


    if ischar(blocks)



        blocks={blocks};
    end

    blockTypes=get_param(blocks,'BlockType');

    for idx=1:nBlocks
        block=blocks{idx};
        blockType=blockTypes{idx};
        if strcmp('SubSystem',blockType)
            reorganizeLibrary(block);
        end
    end


    if strcmp(thisLibrary,bdroot(thisLibrary))
        verticalSpacingFactor=1.15;


        sliSubSystem=sprintf('%s/BMS',thisLibrary);
        set_param(sliSubSystem,'OpenFcn','batt_sl_lib');
        mask=Simulink.Mask.get(sliSubSystem);
        mask.addParameter('Type','checkbox','Name','ShowInLibBrowser','Value','on','Evaluate','off','Tunable','off','ReadOnly','on','Hidden','on','NeverSave','off');


        newBlockOrder=[find(strcmp(sliSubSystem,blocks));
        find(~strcmp(sliSubSystem,blocks))];
    else

        newBlockOrder=[find(strcmp('SubSystem',blockTypes));
        find(strcmp('SimscapeBlock',blockTypes))];
    end


    newPositions=zeros(nBlocks,4);
    for idx=1:nBlocks



        oldBlock=blocks{idx};
        newBlock=blocks{newBlockOrder(idx)};

        oldPosition=get_param(oldBlock,'Position');
        newPosition=get_param(newBlock,'Position');

        oldCenterX=mean(oldPosition([1,3]));
        oldCenterY=mean(oldPosition([2,4]));

        newCenterX=horizontalSpacingFactor*oldCenterX;
        newCenterY=verticalSpacingFactor*oldCenterY;

        if strcmp(get_param(newBlock,'Tag'),'simscape_sublibrary')
            blockWidth=60;
            blockHeight=60;
        else
            blockWidth=newPosition(3)-newPosition(1);
            blockHeight=newPosition(4)-newPosition(2);
        end

        newLeft=floor(newCenterX-blockWidth/2);
        newTop=floor(newCenterY-blockHeight/2);
        newRight=floor(newCenterX+blockWidth/2);
        newBottom=floor(newCenterY+blockHeight/2);

        newPositions(idx,:)=[newLeft,newTop,newRight,newBottom];
    end

    for idx=1:nBlocks
        newBlock=blocks{newBlockOrder(idx)};
        newPosition=newPositions(idx,:);
        set_param(newBlock,'Position',newPosition);
    end
end

function updateAnnotationPosition(thisLibrary)
    dy_top=60;
    dy_bot=20;


    libAnnotation=find_system(bdroot(thisLibrary),'MatchFilter',@Simulink.match.activeVariants,'FindAll','on','Type','Annotation');
    oldPos=get_param(libAnnotation,'Position');
    newPos=[oldPos(1),oldPos(2)+dy_top,oldPos(3),oldPos(4)+dy_bot];
    set_param(libAnnotation,'Position',newPos);


    oldLoc=get_param(bdroot(thisLibrary),'Location');
    set_param(bdroot(thisLibrary),'Location',[oldLoc(1:3),oldLoc(4)+dy_top]);
end


