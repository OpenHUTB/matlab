function maskParams=graphic_params(prefix,defGraphicType,defColor,defGlyph)

    if nargin<1||isempty(prefix)
        prefix='';
    else
        prefix=matlab.lang.makeValidName(prefix);
    end

    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    if nargin<2||isempty(defGraphicType)
        defGraphicType=msgFcn(fullValueId('glyph'));
    end

    if nargin<3||isempty(defColor)
        defColor=msgFcn('sm:sli:defaults:graphic:color3');
    end

    if nargin<4||isempty(defGlyph)
        defGlyph=msgFcn('sm:sli:defaults:graphic:glyph');
    end

    maskParams(1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn(fullParamId('graphicType:ParamName'))];
    maskParams(end).Value=defGraphicType;


    maskParams(end+1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix...
    ,msgFcn(fullParamId('glyph:glyphShape:ParamName'))];
    maskParams(end).Value=defGlyph;


    if strcmp(defGlyph,msgFcn('sm:sli:defaults:inertiaBlock:graphic:glyphType'))
        glyphSize=msgFcn('sm:sli:defaults:inertiaBlock:graphic:glyphSize');
    else
        glyphSize=msgFcn('sm:sli:defaults:graphic:glyphSize');
    end
    maskParams=[maskParams,make_params(...
    msgFcn(fullParamId('glyph:glyphSize:ParamName')),glyphSize,...
    msgFcn(fullParamId('glyph:glyphSizeUnits:ParamName')),'',true)];


    visual_params=@simmechanics.library.helper.visual_params;
    maskParams=[maskParams,visual_params(...
    [prefix,msgFcn(fullParamId('visualProperties:Prefix'))],true,defColor)];

end

function fullMsgId=fullParamId(msgId)
    fullMsgId=['mech2:messages:parameters:graphic:',msgId];
end

function fullMsgId=fullValueId(msgId)
    fullMsgId=['mech2:sli:blockParameters:graphic:graphicType:',msgId,':Value'];
end
