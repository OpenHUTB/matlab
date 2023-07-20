function out=plc_find_system(varargin)




    opts={};
    if numel(varargin)>1
        opts=varargin(2:end);
    end
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        out=find_system(varargin{1},'MatchFilter',@Simulink.match.activeVariants,opts{:});
    else
        out=find_system(varargin{1},opts{:});
    end
end
