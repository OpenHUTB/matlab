
function objectPaths=i_findSystem(graphPath,varargin)



    objectPaths=find_system(graphPath,...
    'Allblocks','on',...
    'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.allVariants,...
    varargin{:});








    objectPaths=i_removeBlksInSFChartFromList(objectPaths);
end
