function varargout=twist_joint(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);


        BlockInfoCache.Hidden='on';

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:joints:twist:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';
        BlockInfoCache.SLBlockProperties.DropShadow=true;


        base_foll_ports=@simmechanics.library.helper.base_foll_ports;
        BlockInfoCache.addPorts(base_foll_ports('joint'));


        BlockInfoCache.IconFile=[mfname,'.jpg'];


        BlockInfoCache.LogsData=true;


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:twistJoint:TypeId'));

        BlockInfoCache.addMaskParameters(maskParams);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end
