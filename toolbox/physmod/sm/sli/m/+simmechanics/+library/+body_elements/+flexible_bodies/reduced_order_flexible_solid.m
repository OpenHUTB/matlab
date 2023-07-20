function varargout=reduced_order_flexible_solid(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        blockReader=simmechanics.library.helper.BlockXmlReader('reducedOrderFlexibleSolid');
        srcFile=mfilename('fullpath');
        blkName=pm_message('sm:library:bodyElements:flexibleBodies:reducedOrderFlexibleSolid:Name');

        BlockInfoCache=blockReader.generateBlockInfo(srcFile,blkName);

        tempReader=simmechanics.library.helper.BlockXmlReader('lengthMassTimeUnits');
        tempInfo=tempReader.generateBlockInfo(srcFile,blkName,false);
        BlockInfoCache.addMaskParameters(tempInfo.MaskParameters);

        tempReader=simmechanics.library.helper.BlockXmlReader('proportionalDamping');
        tempInfo=tempReader.generateBlockInfo(srcFile,blkName,false);
        BlockInfoCache.addMaskParameters(tempInfo.MaskParameters);

        tempReader=simmechanics.library.helper.BlockXmlReader('uniformModalFlexibleBodyDamping');
        tempInfo=tempReader.generateBlockInfo(srcFile,blkName,false);
        BlockInfoCache.addMaskParameters(tempInfo.MaskParameters);

        tempReader=simmechanics.library.helper.BlockXmlReader('generalDamping');
        tempInfo=tempReader.generateBlockInfo(srcFile,blkName,false);
        BlockInfoCache.addMaskParameters(tempInfo.MaskParameters);


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.body_elements.flexible_bodies.reduced_order_flexible_solid_sl_postprocess',...
        0,7.52);
    end


    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end


