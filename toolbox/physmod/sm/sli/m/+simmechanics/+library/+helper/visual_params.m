function maskParams=visual_params(prefix,isSimple,defColor)

    msgFcn=@pm_message;

    if nargin<2
        isSimple=true;
        if nargin<1||isempty(prefix)
            prefix='';
        end
    else
        prefix=genvarname(prefix);
    end

    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;

    if nargin<3
        if isSimple
            defColor=msgFcn(defValSimpleVisPropId('color'));
        else
            defColor=msgFcn(defValAdvancedVisPropId('diffuseColor'));
        end
    end

    maskParams(1)=pm.sli.MaskParameter;

    maskParams(end).VarName=[prefix,msgFcn(fullId('visPropType'))];
    maskParams(end).Value=msgFcn('sm:sli:defaults:graphic:visPropType');

    maskParams=[maskParams,make_params(...
    [prefix,msgFcn(fullId('advancedVisualProperties:diffuseColor'))],defColor,true)];

    maskParams=[maskParams,make_params(...
    [prefix,msgFcn(fullId('advancedVisualProperties:specularColor'))],msgFcn(defValAdvancedVisPropId('specularColor')),true)];

    maskParams=[maskParams,make_params(...
    [prefix,msgFcn(fullId('advancedVisualProperties:ambientColor'))],msgFcn(defValAdvancedVisPropId('ambientColor')),true)];

    maskParams=[maskParams,make_params(...
    [prefix,msgFcn(fullId('advancedVisualProperties:emissiveColor'))],msgFcn(defValAdvancedVisPropId('emissiveColor')),true)];

    maskParams=[maskParams,make_params(...
    [prefix,msgFcn(fullId('advancedVisualProperties:shininess'))],msgFcn(defValAdvancedVisPropId('shininess')),true)];

    maskParams=[maskParams,make_params(...
    [prefix,msgFcn(fullId('simpleVisualProperties:opacity'))],'1.0',true)];

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:visualProperties:',msgId,':ParamName'];
end

function param_id=defValAdvancedVisPropId(pId)
    param_id=['sm:sli:defaults:visualProperties:advancedVisualProperties:',pId];
end

function param_id=defValSimpleVisPropId(pId)
    param_id=['sm:sli:defaults:visualProperties:simpleVisualProperties:',pId];
end