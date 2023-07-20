function varargout=general_flexible_beam(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        blockReader=simmechanics.library.helper.BlockXmlReader('generalFlexibleBeam');
        srcFile=mfilename('fullpath');
        blkName=pm_message('sm:library:bodyElements:flexibleBodies:beams:generalFlexibleBeam:Name');

        BlockInfoCache=blockReader.generateBlockInfo(srcFile,blkName);

        tempReader=simmechanics.library.helper.BlockXmlReader('proportionalDamping');
        tempInfo=tempReader.generateBlockInfo(srcFile,blkName);
        BlockInfoCache.addMaskParameters(tempInfo.MaskParameters);

        tempReader=simmechanics.library.helper.BlockXmlReader('uniformModalFlexibleBodyDamping');
        tempInfo=tempReader.generateBlockInfo(srcFile,blkName);
        BlockInfoCache.addMaskParameters(tempInfo.MaskParameters);
    end
    BlockInfoCache.HasDialogGraphics=true;

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end
