
function varargout=iconpreview(varargin)
    try
        varargout{1}=i_GenerateImage(varargin{1});
    catch
        varargout{1}='';
    end
end


function[aImageLocation]=i_GenerateImage(aSystemHandle)
    aImageLocation=[];
    aMaskObj=Simulink.Mask.get(aSystemHandle);

    if isempty(aMaskObj)
        return;
    end

    if isempty(aMaskObj.Display)&&isempty(aMaskObj.BlockDVGIcon)
        return;
    end

    aImageLocation=i_TakeSnapshot(aSystemHandle);
end


function[aImageLocation]=i_TakeSnapshot(aSystemHandle)
    aImageLocation=[];


    aSnapshot=i_InitSnapshot(aSystemHandle);
    if isempty(aSnapshot)
        return;
    end


    aBlockHdl=maskeditor('GetBlockHandle',aSystemHandle);
    aSnapshot=i_ConfigureSnapshot(aSnapshot,aBlockHdl);


    if~aSnapshot.isTargetValid()
        return;
    end


    aSnapshot.export();


    aImageLocation=aSnapshot.exportOptions.fileName;
end


function aSnapshot=i_InitSnapshot(aSystemHandle)
    aSnapshot=GLUE2.Portal;
    aSnapshot.suppressBadges=true;
    aSnapshot.targetContext='ShowTargetOnly';
    aSnapshot.excludeFilters={'BlockName'};

    aOptions=aSnapshot.exportOptions;
    aOptions.format='PNG';
    aOptions.backgroundColorMode='Transparent';
    aOptions.sizeMode='UseSpecifiedSize';
    aOptions.centerWithAspectRatioForSpecifiedSize=false;
    aSnapshot.exportOptions.fileName=maskeditor('GetPreviewFile',aSystemHandle);
end



function aSnapshot=i_ConfigureSnapshot(aSnapshot,aMaskBlkHdl)
    aDiagramElement=SLM3I.SLDomain.handle2DiagramElement(aMaskBlkHdl);
    if isempty(aDiagramElement)
        return;
    end

    aSnapshot.setTarget('Simulink',aMaskBlkHdl);


    minH=200;minW=200;

    aWidth=max(aSnapshot.targetSceneRect(3),minW);
    aHeight=max(aSnapshot.targetSceneRect(4),minH);

    aOptions=aSnapshot.exportOptions;
    aSnapshot.targetOutputRect=[0,0,aWidth,aHeight];
    aOptions.size=[aWidth,aHeight];
end
