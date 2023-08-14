function stackHeight=findPcbStackHeight(obj)
    if isDielectricSubstrate(obj)
        stackHeight=max(cumsum([0,obj.Substrate.Thickness]));
    else
        stackHeight=obj.BoardThickness;
    end

end