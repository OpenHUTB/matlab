





function bringUpInformer(obj,SID)

    modelH=get_param(obj.designMdl,'Handle');
    avData=get_param(modelH,'AutoVerifyData');

    modelView=[];
    if isfield(avData,'modelView')&&avData.modelView.isvalid

        modelView=avData.modelView;
        modelView.bringInformerToFront;
    else

        modelView=Sldv.ModelView(obj.sldvData);
        modelView.view;
        Simulink.ID.hilite(SID);
        Simulink.ID.hilite(SID,'none');
        avData.modelView=modelView;

        set_param(modelH,'AutoVerifyData',avData);
    end


    modelView.displayDataforSid(SID);

end
