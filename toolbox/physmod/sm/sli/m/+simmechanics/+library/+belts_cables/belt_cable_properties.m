function varargout=belt_cable_properties(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2018a';

        msgFcn=@pm_message;

        BlockInfoCache.SLBlockProperties.Name=...
        msgFcn('sm:library:beltsCables:beltCableProperties:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';
        BlockInfoCache.SLBlockProperties.Orientation='right';


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.belts_cables.belt_cable_properties_sl_postprocess',...
        0.0,5.22);


        beltCablePort=sm_ports_info('beltcable');
        beltCableName=...
        msgFcn('sm:model:blockNames:beltCableProperties:ports:BeltCable');
        BlockInfoCache.addPorts(simmechanics.sli.internal.PortInfo(...
        beltCablePort.PortType,beltCableName,'left',beltCableName));


        BlockInfoCache.IconFile=[mfname,'.svg'];


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:beltCableProperties:TypeId'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('drumBeltCableAlignment'));
        maskParams(end).Value=msgFcn(defValId('drumBeltCableAlignment'));


        graphic_params=@simmechanics.library.helper.graphic_params;
        maskParams=[maskParams,graphic_params('',msgFcn(defValId('graphicType')))];


        varNames={maskParams.VarName};
        markerIndices=strcmp(varNames,msgFcn(glyphParamId('glyphShape')));
        markerIndices=...
        markerIndices|strcmp(varNames,msgFcn(glyphParamId('glyphSize')));
        markerIndices=...
        markerIndices|strcmp(varNames,msgFcn(glyphParamId('glyphSizeUnits')));

        rtpSuffix=msgFcn('mech2:messages:parameters:common:rtp:Suffix');
        glyphSizeRTP=[msgFcn(glyphParamId('glyphSize')),rtpSuffix];
        markerIndices=markerIndices|strcmp(varNames,glyphSizeRTP);

        maskParams=maskParams(~markerIndices);

        BlockInfoCache.addMaskParameters(maskParams);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,...
        varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end

function param_id=glyphParamId(msgId)
    param_id=['mech2:messages:parameters:graphic:glyph:',msgId,':ParamName'];
end

function param_id=paramId(msgId)
    param_id=['mech2:messages:parameters:beltCable:beltCableProperties:'...
    ,msgId,':ParamName'];
end

function param_id=defValId(pId)
    param_id=['sm:sli:defaults:beltCableProperties:',pId];
end


