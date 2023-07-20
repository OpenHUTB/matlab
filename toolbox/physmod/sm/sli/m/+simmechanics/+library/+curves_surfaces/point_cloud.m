function varargout=point_cloud(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        className=pm_message('mech2:pointCloud:parameters:className:Value');

        mfname=mfilename('fullpath');
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:curvesSurfaces:pointCloud:Name');
        simmechanics.library.helper.readXml(BlockInfoCache,className);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end