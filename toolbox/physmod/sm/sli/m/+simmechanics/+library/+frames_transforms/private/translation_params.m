function maskParams=translation_params(prefix)

    if nargin<1||isempty(prefix)
        prefix='';
    else
        prefix=genvarname(prefix);
    end

    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    maskParams(1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn(fullParamId('translationMethod'))];
    maskParams(end).Value=msgFcn(fullValueId('zeroTranslation'));

    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('elementaryTranslation:translationOffset')),'0',...
    msgFcn(fullParamId('elementaryTranslation:transLengthUnit')),'m',true)];


    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix...
    ,msgFcn(fullParamId('elementaryTranslation:elementaryTransAxis'))];
    maskParams(end).Value='+Z';


    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('cartesianTranslation:translationOffset')),'[0 0 0]',true)];


    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('cylindricalTranslation:transROffset')),'0',...
    msgFcn(fullParamId('cylindricalTranslation:transROffsetUnits')),'m',true)];

    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('cylindricalTranslation:transZOffset')),'0',...
    msgFcn(fullParamId('cylindricalTranslation:transZOffsetUnits')),'m',true)];


    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('cylindricalTranslation:transThetaOffset')),'0',...
    msgFcn(fullParamId('cylindricalTranslation:transThetaOffsetUnits')),'deg',...
    true)];

end

function fullMsgId=fullParamId(msgId)
    fullMsgId=['mech2:messages:parameters:translation:',msgId,':ParamName'];
end

function fullMsgId=fullValueId(msgId)
    fullMsgId=['mech2:sli:blockParameters:translation:translationMethod:'...
    ,msgId,':Value'];
end
