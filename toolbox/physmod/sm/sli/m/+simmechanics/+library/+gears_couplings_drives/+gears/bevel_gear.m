function varargout=bevel_gear(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2013b';

        msgFcn=@pm_message;

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:gearsAndCouplings:gears:bevel:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';

        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.gears_couplings_drives.gears.sl_postprocess',0,4.50);



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.sl_postprocess',4.50,4.72);


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.helper.translate_hertz_units',4.72,4.82);


        BlockInfoCache.addPorts(gear_ports);


        BlockInfoCache.IconFile=[mfname,'.svg'];


        make_params=@simmechanics.library.helper.make_params;

        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:bevelGearConstraint:TypeId'));

        maskParams=[maskParams,make_params(msgFcn(paramId('baseGearRadius')),...
        msgFcn(defValId('baseGearRadius')),...
        msgFcn(paramId('baseGearRadiusUnits')),...
        msgFcn(defValId('baseGearRadiusUnits')),...
        true)];

        maskParams=[maskParams,make_params(msgFcn(paramId('follGearRadius')),...
        msgFcn(defValId('follGearRadius')),...
        msgFcn(paramId('follGearRadiusUnits')),...
        msgFcn(defValId('follGearRadiusUnits')),...
        true)];

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('assemblyGearRotation'));
        maskParams(end).Value=msgFcn(defValId('assemblyGearRotation'));

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('shaftOrientation'));
        maskParams(end).Value=msgFcn(defValId('shaftOrientation'));

        maskParams=[maskParams,make_params(msgFcn(paramId('shaftAngle')),...
        msgFcn(defValId('shaftAngle')),...
        msgFcn(paramId('shaftAngleUnits')),...
        msgFcn(defValId('shaftAngleUnits')),...
        true)];

        BlockInfoCache.addMaskParameters(maskParams);

    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(...
        BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end

function param_id=paramId(msgId)
    param_id=['mech2:messages:parameters:constraint:bevelGearConstraint:'...
    ,msgId,':ParamName'];
end

function param_id=defValId(pId)
    param_id=['sm:sli:defaults:bevelGearConstraint:',pId];
end


