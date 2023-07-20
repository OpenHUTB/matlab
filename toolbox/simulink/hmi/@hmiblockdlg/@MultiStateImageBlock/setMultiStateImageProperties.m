


function setMultiStateImageProperties(props,widgetId,model,isLibWidget,isSlimDialog)


    bLookingForStandalone=~isSlimDialog;
    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    dlgSrc=[];
    for i=1:length(dlgs)
        curSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(curSrc,widgetId,model)
            if bLookingForStandalone==dlgs(i).isStandAlone
                dlgSrc=curSrc;
                break;
            end
        end
    end


    locSetPropsCoreBlock(dlgSrc,props);


    if~isempty(dlgSrc)
        if isSlimDialog
            utils.slimDialogUtils.multiStateImageDataChanged(...
            dlgSrc,widgetId,model,isLibWidget);
        else
            multiStateImageDlgs=dlgSrc.getOpenDialogs(true);
            for k=1:length(multiStateImageDlgs)
                multiStateImageDlgs{k}.enableApplyButton(true,true);
            end
        end
    end
end


function locSetPropsCoreBlock(dlgSrc,props)
    switch props.action
    case 1

        dlgSrc.States(end+1).State=props.States;
        dlgSrc.States(end).Image=props.StateImages;
        dlgSrc.States(end).Thumbnail=props.StateImageThumbs;
        dlgSrc.States(end).Size=uint64(props.StateImageSizes);
    case 2

        dlgSrc.States(props.PropIndexes)=[];
    case 3

        dlgSrc.States(props.PropIndex).State=props.States;

    case 4

        dlgSrc.States(props.PropIndex).Image=props.StateImages;
        dlgSrc.States(props.PropIndex).Thumbnail=props.StateImageThumbs;
        dlgSrc.States(props.PropIndex).Size=uint64(props.StateImageSizes);
    case 5

        dlgSrc.DefaultImage.Image=props.StateImages;
        dlgSrc.DefaultImage.Thumbnail=props.StateImageThumbs;
        dlgSrc.DefaultImage.Size=uint64(props.StateImageSizes);
    case 6

        dlgSrc.DefaultImage.Image='';
        dlgSrc.DefaultImage.Thumbnail='';
        dlgSrc.DefaultImage.Size=uint64([0,0]);
    case 7

        dlgSrc.States(props.PropIndex).Image='';
        dlgSrc.States(props.PropIndex).Thumbnail='';
        dlgSrc.States(props.PropIndex).Size=uint64([0,0]);
    end
end

