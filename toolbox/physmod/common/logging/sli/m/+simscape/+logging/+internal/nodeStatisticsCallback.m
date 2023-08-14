function nodeStatisticsCallback(nodeStatsLink,source,selectedNode)




    switch nodeStatsLink
    case 'Description'
        lNodeIdSourceCallback(selectedNode);
    case 'Source'
        lBlockSourceCallback(source);
    case 'ZeroCrossingLocation'
        lZeroCrossingLocationCallback(selectedNode);
    otherwise
        return;
    end
end

function lNodeIdSourceCallback(selectedNode)


    assert(numel(selectedNode)==1);

    source=selectedNode.getSource();
    model=lGetModelFromSource(source);
    openSystem=true;

    if~bdIsLoaded(model)
        [openSystem]=lLoadModel(model);
    end

    if openSystem
        open_system(model);
        if lIsSimulinkValid(source)
            if~strcmp(model,source)
                open_system(Simulink.ID.getHandle(source));
            end
        end
    end
end

function lBlockSourceCallback(source)


    model=lGetModelFromSource(source);
    highlight=true;


    if~bdIsLoaded(model)
        [highlight]=lLoadModel(model);
    end

    if highlight
        open_system(model);
        set_param(model,'HiliteAncestors','none')
        if lIsSimulinkValid(source)
            if~strcmp(model,source)
                pm.sli.highlightSystem(source);
            end
        end
    end
end

function lZeroCrossingLocationCallback(selectedNode)

    key='ZeroCrossingLocation';
    tag=selectedNode.getTag(key);
    fileLocation=tag{2};
    if~isempty(fileLocation)
        tokens=textscan(fileLocation,'%s%d%d','Delimiter',',');
        fileName=tokens{1}{1};
        fileRow=tokens{2};
        fileCol=tokens{3};
        if exist(which(fileName),'file')
            opentoline(which(fileName),fileRow,fileCol);
        else
            return;
        end
    end
end

function model=lGetModelFromSource(source)
    strs=strsplit(source,':');
    model=strs{1};
end

function[modelAction]=lLoadModel(model)

    if(exist(model,'file')==4)
        choiceYes=getMessageFromCatalog('Yes');
        choiceNo=getMessageFromCatalog('No');
        result=questdlg(getMessageFromCatalog('ModelNotOpen',model),...
        getMessageFromCatalog('OpenModel'),choiceYes,choiceNo,choiceYes);

        modelAction=strcmp(result,choiceYes);
    else
        str=getMessageFromCatalog('ModelNotOnPath',model);
        errorDialogTitle=getMessageFromCatalog('LoadError');
        errordlg(str,errorDialogTitle,'modal');
        modelAction=false;
    end
end

function isValid=lIsSimulinkValid(source)
    isValid=exist('is_simulink_loaded','file')&&is_simulink_loaded()&&...
    Simulink.ID.isValid(source);
end
