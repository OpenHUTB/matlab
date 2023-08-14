function varargout=spline(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        blockReader=simmechanics.library.helper.BlockXmlReader('splineGeometry');
        BlockInfoCache=blockReader.generateBlockInfo(mfilename('fullpath'),...
        pm_message('sm:library:curvesSurfaces:spline:Name'));



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.sl_postprocess',0,4.72);


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.helper.translate_hertz_units',4.72,4.82);

        BlockInfoCache.HasDialogGraphics=true;
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end
