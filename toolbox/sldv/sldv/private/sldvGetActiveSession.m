function session=sldvGetActiveSession(modelH)





    session=[];

    avDataHandle=get_param(modelH,'AutoVerifyData');
    if~isempty(avDataHandle)&&isfield(avDataHandle,'sldvSession')&&...
        ~isempty(avDataHandle.sldvSession)&&isvalid(avDataHandle.sldvSession)

        session=avDataHandle.sldvSession;
    end
end
