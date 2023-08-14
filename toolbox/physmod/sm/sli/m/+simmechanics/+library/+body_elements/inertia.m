function varargout=inertia(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2012a';

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:bodyElements:inertia:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';
        BlockInfoCache.SLBlockProperties.Orientation='right';



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.sl_postprocess',0,4.72);


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.helper.translate_hertz_units',4.72,4.82);


        BlockInfoCache.IconFile=[mfname,'.svg'];


        reference_port=@simmechanics.library.helper.reference_port;
        BlockInfoCache.addPorts(reference_port('inertiaBlock'));


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:inertiaBlock:TypeId'));

        maskParams=[maskParams,inertia_params('')];

        graphic_params=@simmechanics.library.helper.graphic_params;
        maskParams=[maskParams,graphic_params('',...
        pm_message('sm:sli:defaults:inertiaBlock:graphic:graphicType'),'',...
        pm_message('sm:sli:defaults:inertiaBlock:graphic:glyphType'))];

        BlockInfoCache.addMaskParameters(maskParams);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,...
        varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end
