
function yesno=getSldvModelHighlightStatus(obj)



    modelHandle=get_param(obj.designMdl,'Handle');
    avtH=get_param(modelHandle,'AutoVerifyData');
    if~isempty(avtH)&&isfield(avtH,'modelView')
        modelView=avtH.modelView;
        yesno=modelView.isHighlighted;
    else
        yesno=false;
    end
end