



function setScaleColors(scaleColorsData,widgetId,model,isLibWidget,isSlimDialog)


    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    gaugeDlgSrc=[];
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        curIsSlim=~dlgs(i).isStandAlone;
        if curIsSlim==isSlimDialog&&utils.isWidgetDialog(dlgSrc,widgetId,model)
            gaugeDlgSrc=dlgSrc;
            break;
        end
    end

    if~isempty(gaugeDlgSrc)

        if strcmpi(gaugeDlgSrc.blockObj.BlockType,'SubSystem')

            locSetLegacyColors(scaleColorsData,gaugeDlgSrc);
        else

            locSetCoreBlockColors(scaleColorsData,gaugeDlgSrc);
        end


        if isSlimDialog
            utils.slimDialogUtils.gaugeScaleColorsChanged(...
            gaugeDlgSrc,widgetId,model,isLibWidget);
        else
            gaugeDlgs=gaugeDlgSrc.getOpenDialogs(true);
            for k=1:length(gaugeDlgs)
                gaugeDlgs{k}.enableApplyButton(true,true);
            end
        end
    end
end


function locSetLegacyColors(newData,dlgSrc)
    switch newData.action
    case 1

        dlgSrc.ScaleColors=...
        [dlgSrc.ScaleColors;newData.scaleColor.'];
        dlgSrc.ScaleColorLimits{length(dlgSrc.ScaleColorLimits)+1}=...
        {'0','0'};

    case 2

        indexesToDelete=int32(newData.PropIndexes);
        dlgSrc.ScaleColors(indexesToDelete,:)=[];

        dlgSrc.ScaleColorLimits(indexesToDelete)=[];

    case 3

        dlgSrc.ScaleColorLimits{newData.PropIndex}{1}=...
        newData.MinValue;

    case 4

        dlgSrc.ScaleColorLimits{newData.PropIndex}{2}=...
        newData.MaxValue;

    case 5

        dlgSrc.ScaleColors(newData.PropIndex,:)=...
        newData.UpdatedScaleColor;

    end
end


function locSetCoreBlockColors(newData,dlgSrc)
    switch newData.action
    case 1

        newState.Min=0;
        newState.Max=0;
        newState.Color=(1/255).*newData.scaleColor.';
        dlgSrc.ScaleColors(end+1)=newState;

    case 2

        indexesToDelete=int32(newData.PropIndexes);
        dlgSrc.ScaleColors(indexesToDelete)=[];

    case 3

        dlgSrc.ScaleColors(newData.PropIndex).Min=str2double(newData.MinValue);

    case 4

        dlgSrc.ScaleColors(newData.PropIndex).Max=str2double(newData.MaxValue);

    case 5

        dlgSrc.ScaleColors(newData.PropIndex).Color=(1/255).*newData.UpdatedScaleColor;

    end
end
