function blockParam=setBlockParam(this,block,varargin)%#ok

    p=inputParser;
    blkParam=block.blkParams;
    for i=1:length(blkParam.required)
        p.addParameter(blkParam.required{i},'')
    end

    for i=1:length(blkParam.optional)
        p.addOptional(blkParam.optional{i},'')
    end

    p.parse(varargin{:});
    blockParam=p.Results;
end
