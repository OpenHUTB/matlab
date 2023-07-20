function arg=componentArg(varargin)







    tmp=varargin(2:end);
    for i=1:2:length(tmp{:})
        arg.(tmp{1}{i})=tmp{1}{i+1};
    end

