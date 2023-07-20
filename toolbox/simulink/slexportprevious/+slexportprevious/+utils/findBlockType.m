function foundBlocks=findBlockType(modelName,blockName,varargin)







    p=inputParser;
    p.addRequired('modelName',@isscalarstring);
    p.addRequired('blockName',@isscalarstring);
    p.parse(modelName,blockName);

    function b=isscalarstring(v)
        b=ischar(v)||(isstring(v)&&numel(v)==1);
    end



    foundBlocks=find_system(modelName,...
    'LookUnderMasks','on',...
    'IncludeCommented','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType',blockName,...
    varargin{:});

end