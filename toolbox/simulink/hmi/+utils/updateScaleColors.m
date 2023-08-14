function updateScaleColors(obj,dlg)
    scChannel='/hmi_scalecolors_controller_/';
    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');

    gaugeScaleColorsData={};
    gaugeDlgSrc=dlg.getSource();
    numStates=numel(gaugeDlgSrc.ScaleColors);
    gaugeScaleColorsData{1}=zeros(numStates,3);
    gaugeScaleColorsData{2}=cell(1,numStates);
    for idx=1:numStates
        gaugeScaleColorsData{1}(idx,:)=uint32(255.*gaugeDlgSrc.ScaleColors(idx).Color);
        gaugeScaleColorsData{2}{idx}=cell(1,2);
        gaugeScaleColorsData{2}{idx}{1}=num2str(gaugeDlgSrc.ScaleColors(idx).Min);
        gaugeScaleColorsData{2}{idx}{2}=num2str(gaugeDlgSrc.ScaleColors(idx).Max);
    end
    message.publish([scChannel,'updateProperties'],...
    {false,obj.widgetId,mdl,gaugeScaleColorsData});
end

