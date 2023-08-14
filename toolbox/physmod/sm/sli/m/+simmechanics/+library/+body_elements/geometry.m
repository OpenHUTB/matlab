function varargout=geometry(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);


        BlockInfoCache.Hidden='on';

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:bodyElements:geometry:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';
        BlockInfoCache.SLBlockProperties.Orientation='up';


        BlockInfoCache.IconFile=[mfname,'.jpg'];


        reference_port=@simmechanics.library.helper.reference_port;
        BlockInfoCache.addPorts(reference_port('geometryBlock'));


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:geometryBlock:TypeId'));

        maskParams=[maskParams,geometry_params('')];

        BlockInfoCache.addMaskParameters(maskParams);

    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end
