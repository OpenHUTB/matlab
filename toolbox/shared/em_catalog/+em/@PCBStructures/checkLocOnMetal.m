function isMetal=checkLocOnMetal(obj,loc)
    if any(loc>numel(obj.Layers))
        error(message('rfpcb:rfpcberrors:InvalidStartorStopLayer'));
    end
    testLayer=obj.Layers(loc);
    isMetal=cellfun(@(x)isa(x,'antenna.Shape'),testLayer);
end