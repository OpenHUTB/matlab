function varargout=rack_and_pinion(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2013a';

        msgFcn=@pm_message;
        make_params=@simmechanics.library.helper.make_params;

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:gearsAndCouplings:gears:rackAndPinion:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';


        BlockInfoCache.setForwardingTableEntries('R2013b',...
        {sprintf('sm_lib/Gears, Couplings\nand Drives/Gears/Rack and \nPinion')});

        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.gears_couplings_drives.gears.sl_postprocess',0,4.50);



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.sl_postprocess',4.50,4.72);


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.helper.translate_hertz_units',4.72,4.82);


        BlockInfoCache.addPorts(gear_ports);


        BlockInfoCache.IconFile=[mfname,'.svg'];


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:rackAndPinionConstraint:TypeId'));

        maskParams=[maskParams,make_params(...
        msgFcn(paramId('pinionRadius')),...
        msgFcn(defValId('pinionRadius')),...
        msgFcn(paramId('pinionRadiusUnits')),...
        msgFcn(defValId('pinionRadiusUnits')),true)];



















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
    param_id=['mech2:messages:parameters:constraint:rackAndPinionConstraint:'...
    ,msgId,':ParamName'];
end

function param_id=defValId(pId)
    param_id=['sm:sli:defaults:rackAndPinionConstraint:',pId];
end
