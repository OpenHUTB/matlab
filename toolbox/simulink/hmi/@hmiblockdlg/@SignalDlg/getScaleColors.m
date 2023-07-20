
function gaugeScaleColorsData=getScaleColors(widgetId,model)




    gaugeScaleColorsData={};
    gaugeDlgSrc='';

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            gaugeDlgSrc=dlgSrc;
            break;
        end
    end

    if strcmpi(gaugeDlgSrc.blockObj.BlockType,'SubSystem')

        if~isempty(gaugeDlgSrc.ScaleColorLimits)
            gaugeScaleColorsData{1}=gaugeDlgSrc.ScaleColors;
            gaugeScaleColorsData{2}=gaugeDlgSrc.ScaleColorLimits;
        end
    else

        if~isempty(gaugeDlgSrc.ScaleColors)
            numStates=numel(gaugeDlgSrc.ScaleColors);
            gaugeScaleColorsData{1}=zeros(numStates,3);
            gaugeScaleColorsData{2}=cell(1,numStates);
            for idx=1:numStates
                gaugeScaleColorsData{1}(idx,:)=uint32(255.*gaugeDlgSrc.ScaleColors(idx).Color);
                gaugeScaleColorsData{2}{idx}=cell(1,2);
                gaugeScaleColorsData{2}{idx}{1}=num2str(gaugeDlgSrc.ScaleColors(idx).Min);
                gaugeScaleColorsData{2}{idx}{2}=num2str(gaugeDlgSrc.ScaleColors(idx).Max);
            end
        end
    end

end
