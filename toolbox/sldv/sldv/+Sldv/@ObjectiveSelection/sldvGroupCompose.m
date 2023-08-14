function stmt=sldvGroupCompose(group,varargin)





    if isempty(group)
        stmt=Sldv.ObjectiveSelection.sldvCompose(varargin{1:end});
    end
    for i=1:length(group)
        stmt(i)=Sldv.ObjectiveSelection.sldvCompose(group(i),varargin{1:end});
    end
end
