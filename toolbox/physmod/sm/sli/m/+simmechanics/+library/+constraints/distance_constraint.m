function varargout=distance_constraint(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2012a';

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:constraints:distance:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';


        BlockInfoCache.setForwardingTableEntries('R2013b',...
        sprintf('sm_lib/Constraints/Distance \nConstraint'));

        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.constraints.sl_postprocess',0,4.49);



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.sl_postprocess',4.49,4.72);


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.helper.translate_hertz_units',4.72,4.82);


        base_foll_ports=@simmechanics.library.helper.base_foll_ports;
        BlockInfoCache.addPorts(base_foll_ports('constraint'));


        BlockInfoCache.IconFile=[mfname,'.svg'];


        msgFcn=@pm_message;
        make_params=@simmechanics.library.helper.make_params;

        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:distanceConstraint:TypeId'));






        maskParams=[maskParams,make_params(...
        msgFcn(fullId('distance')),...
        '1',...
        msgFcn(fullId('distanceUnits')),...
        'm',true)];

        maskParams(end+1)=pm.sli.MaskParameter;

        maskParams(end).VarName=msgFcn(fullId('senseSignedForceMagnitude'));
        maskParams(end).Value='off';

        BlockInfoCache.addMaskParameters(maskParams);

        maskParams=constraint_params('');
        BlockInfoCache.addMaskParameters(maskParams);

    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:constraint:distanceConstraint:',msgId,':ParamName'];
end


