function varargout=getColor(~)






    persistent colorIdx;
    colors=num2cell(get(0,'defaultAxesColorOrder'),2);

    if isempty(colorIdx)
        colorIdx=0;
    end

    if nargin==1
        colorIdx=0;
    else
        color=colors{mod(colorIdx,numel(colors))+1};
        colorIdx=colorIdx+1;
        varargout{1}=color;
    end



end
