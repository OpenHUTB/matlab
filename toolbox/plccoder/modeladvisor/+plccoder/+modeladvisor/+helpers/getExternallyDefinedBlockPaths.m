function blocks = getExternallyDefinedBlockPaths(modelH, varargin)
%

%   Copyright 2021 The MathWorks, Inc.

    blocks = {};

    if ~ishandle(modelH)
        modelH = get_param(modelH, 'Handle');
    end

    if ~isempty(varargin) && numel(varargin) == 1
        if strcmp(varargin{1}, 'FUN')
            blocks = getBlockPathsFromProperty(modelH, 'PLC_ExcludeBlocksAsFunction');
        elseif strcmp(varargin{1}, 'FB')
            blocks = getBlockPathsFromProperty(modelH, 'PLC_ExcludeBlocksAsFunctionBlock');
        end
    else
        if plcfeature('PLCExternallyDefinedBlocks') == 1
            blocks = getBlockPathsFromProperty(modelH, 'PLC_ExternalDefinedBlocks');
        else
            excludeAsFUNBlocks = getBlockPathsFromProperty(modelH, 'PLC_ExcludeBlocksAsFunction');
            excludeAsFBBlocks = getBlockPathsFromProperty(modelH, 'PLC_ExcludeBlocksAsFunctionBlock');
            commonPaths = intersect(excludeAsFUNBlocks, excludeAsFBBlocks);
            if ~isempty(commonPaths)
                msl = MSLException(get_param(commonPaths{1}, 'Handle'), ...
                    message('plccoder:plccg_ext:UnsupportedBlockExclusion', commonPaths{1}));
                throw(msl);
            end
            blocks = [blocks excludeAsFUNBlocks excludeAsFBBlocks];
        end
    end
end

function blockPaths = getBlockPathsFromProperty(modelH, propName)

    try
        blockPaths = strtrim(get_param(modelH, propName));
    catch
        blockPaths = {};
    end

    if ~isempty(blockPaths)
        blockPaths = strrep(blockPaths, ',', '|');
        blockPaths = strrep(blockPaths, ';', '|');
        blockPaths = strrep(blockPaths, newline, '|');
        blockPaths = strsplit(blockPaths, '|');
    end
end

% LocalWords:  plccg
