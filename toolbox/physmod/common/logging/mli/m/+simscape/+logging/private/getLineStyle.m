function varargout=getLineStyle(~)






    persistent idx;
    lineStyles={'-','--',':','-.'};

    if isempty(idx)
        idx=0;
    end

    if nargin==1
        idx=0;
    else
        lineStyle=lineStyles{mod(idx,numel(lineStyles))+1};
        idx=idx+1;
        varargout{1}=lineStyle;
    end

end
