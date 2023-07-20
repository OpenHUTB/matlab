function Blocks=findActiveBlocks(varargin)








    model=varargin{1};
    varargin(1)=[];
    if Simulink.internal.useFindSystemVariantsMatchFilter()




        Blocks=find_system(model,'MatchFilter',@Simulink.match.activeVariants,...
        varargin{:});
    else
        Blocks=find_system(model,'Variants','ActiveVariants',varargin{:});
    end

