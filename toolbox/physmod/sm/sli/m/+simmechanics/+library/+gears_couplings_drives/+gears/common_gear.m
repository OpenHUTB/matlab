function varargout=common_gear(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2013a';

        msgFcn=@pm_message;

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:gearsAndCouplings:gears:common:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';


        BlockInfoCache.setForwardingTableEntries('R2013b',...
        'sm_lib/Gears, Couplings and Drives/Gears/Common Gear');

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
        pm_message('sm:model:blockNames:commonGearConstraint:TypeId'));

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('gearType'));
        maskParams(end).Value=msgFcn(defValId('gearType'));

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('specificationType'));
        maskParams(end).Value=msgFcn(defValId('specificationType'));

        maskParams=[maskParams,make_params(msgFcn(paramId('centerDistance')),...
        msgFcn(defValId('centerDistance')),...
        msgFcn(paramId('centerDistanceUnits')),...
        msgFcn(defValId('centerDistanceUnits')),...
        true)];

        maskParams=[maskParams,make_params(msgFcn(paramId('gearRatio')),...
        msgFcn(defValId('gearRatio')),...
        true)];

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
    param_id=['mech2:messages:parameters:constraint:commonGearConstraint:'...
    ,msgId,':ParamName'];
end

function param_id=defValId(pId)
    param_id=['sm:sli:defaults:commonGearConstraint:',pId];
end


