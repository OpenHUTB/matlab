function coderID=getCoderID(systemH)





    modelName=get_param(bdroot(systemH),'Name');
    if isempty(modelName)
        error('pslink:noModelOpen',message('polyspace:gui:pslink:noModelOpen').getString())
    end


    allowGrtTarget=isPslinkAvailable()&&pslinkprivate('pslinkattic','getBinMode','allowGrtTarget');
    isForSFcn=~isempty(which('pslink.verifier.sfcn.isVerifiableSFcn'))&&pslink.verifier.sfcn.isVerifiableSFcn(systemH);
    isForEC=~isForSFcn&&isErtTarget(modelName)||allowGrtTarget;
    isForTL=~isForSFcn&&isTlInstalled()&&isTlTarget(modelName,true)&&~isForEC;

    if isForTL
        coderID=pslink.verifier.tl.Coder.CODER_ID;
    elseif isForEC
        coderID=pslink.verifier.ec.Coder.CODER_ID;
    elseif isForSFcn
        coderID=pslink.verifier.sfcn.Coder.CODER_ID;
    else
        coderID='';
    end
