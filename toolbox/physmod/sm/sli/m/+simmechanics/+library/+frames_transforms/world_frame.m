function varargout=world_frame(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2012a';

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:framesAndTransforms:world:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';
        BlockInfoCache.SLBlockProperties.Orientation='right';

        BlockInfoCache.setForwardingTableEntries('R2013b',...
        sprintf('sm_lib/Frames and\n Transforms/World Frame'));



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.sl_postprocess',0,4.72);


        reference_port=@simmechanics.library.helper.reference_port;
        BlockInfoCache.addPorts(reference_port('worldFrame'));


        BlockInfoCache.IconFile=[mfname,'.svg'];


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:worldFrame:TypeId'));

        BlockInfoCache.addMaskParameters(maskParams);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

