function varargout=worm_and_gear(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2017a';

        msgFcn=@pm_message;

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:gearsAndCouplings:gears:wormAndGear:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';


        BlockInfoCache.addPorts(gear_ports);


        BlockInfoCache.IconFile=[mfname,'.svg'];


        make_params=@simmechanics.library.helper.make_params;

        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:wormAndGearConstraint:TypeId'));


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('wormDirection'));
        maskParams(end).Value=msgFcn(defValId('wormDirection'));


        maskParams=[maskParams,make_params(msgFcn(paramId('wormLeadAngle')),...
        msgFcn(defValId('wormLeadAngle')),...
        msgFcn(paramId('wormLeadAngleUnits')),...
        msgFcn(defValId('wormLeadAngleUnits')),...
        true)];


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=msgFcn(paramId('specificationMethod'));
        maskParams(end).Value=msgFcn(defValId('specificationMethod'));


        maskParams=[maskParams,make_params(msgFcn(paramId('centerDistance')),...
        msgFcn(defValId('centerDistance')),...
        msgFcn(paramId('centerDistanceUnits')),...
        msgFcn(defValId('centerDistanceUnits')),...
        true)];


        maskParams=[maskParams,make_params(msgFcn(paramId('ratio')),...
        msgFcn(defValId('ratio')),...
        true)];


        maskParams=[maskParams,make_params(msgFcn(paramId('wormRadius')),...
        msgFcn(defValId('wormRadius')),...
        msgFcn(paramId('wormRadiusUnits')),...
        msgFcn(defValId('wormRadiusUnits')),...
        true)];


        maskParams=[maskParams,make_params(msgFcn(paramId('gearRadius')),...
        msgFcn(defValId('gearRadius')),...
        msgFcn(paramId('gearRadiusUnits')),...
        msgFcn(defValId('gearRadiusUnits')),...
        true)];

        BlockInfoCache.addMaskParameters(maskParams);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,...
        varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end

function param_id=paramId(msgId)
    param_id=['mech2:messages:parameters:constraint:wormAndGearConstraint:'...
    ,msgId,':ParamName'];
end

function param_id=defValId(pId)
    param_id=['sm:sli:defaults:wormAndGearConstraint:',pId];
end


