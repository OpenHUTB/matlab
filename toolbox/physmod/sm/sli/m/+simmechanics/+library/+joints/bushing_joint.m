function varargout=bushing_joint(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2012a';

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:joints:bushing:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.joints.sl_postprocess',0,4.30);



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.sl_postprocess',4.30,4.72);


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.helper.translate_hertz_units',4.72,4.82);


        base_foll_ports=@simmechanics.library.helper.base_foll_ports;
        BlockInfoCache.addPorts(base_foll_ports('joint'));


        BlockInfoCache.IconFile=[mfname,'.svg'];


        BlockInfoCache.LogsData=true;


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:bushingJoint:TypeId'));

        BlockInfoCache.addMaskParameters(maskParams);

        maskParams=joint_params();
        BlockInfoCache.addMaskParameters(maskParams);

        maskParams=simple_primitive_params('prismatic');
        addPrefixedParams=@simmechanics.library.helper.add_prefixed_params;
        addPrefixedParams(BlockInfoCache,maskParams,pm_message('mech2:messages:parameters:joint:bushingJoint:pxPrimitive:Prefix'));
        addPrefixedParams(BlockInfoCache,maskParams,pm_message('mech2:messages:parameters:joint:bushingJoint:pyPrimitive:Prefix'));
        addPrefixedParams(BlockInfoCache,maskParams,pm_message('mech2:messages:parameters:joint:bushingJoint:pzPrimitive:Prefix'));

        maskParams=simple_primitive_params('revolute');
        addPrefixedParams(BlockInfoCache,maskParams,pm_message('mech2:messages:parameters:joint:bushingJoint:rxPrimitive:Prefix'));
        addPrefixedParams(BlockInfoCache,maskParams,pm_message('mech2:messages:parameters:joint:bushingJoint:ryPrimitive:Prefix'));
        addPrefixedParams(BlockInfoCache,maskParams,pm_message('mech2:messages:parameters:joint:bushingJoint:rzPrimitive:Prefix'));

    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end
