function pvpairs=parseBoundaryLineInputs(args)





    [numericArgs,pvpairs]=parseparams(args);
    if numel(numericArgs)~=2
        error(message("aero_graphics:BoundaryLine:TwoNumericInputs"))
    end

    l=[];
    c=[];
    m=[];
    if mod(numel(pvpairs),2)
        [l,c,m,msg]=colstyle(pvpairs{1});
        if~isempty(msg)
            error(msg.message,msg.identifier)
        end
        pvpairs(1)=[];
    end

    if~isempty(l)
        pvpairs=Aero.internal.namevalues.addNameValuePair(pvpairs,'LineStyle',l);
    end
    if~isempty(c)
        pvpairs=Aero.internal.namevalues.addNameValuePair(pvpairs,'Color',c);
    end
    if~isempty(m)
        pvpairs=Aero.internal.namevalues.addNameValuePair(pvpairs,'Marker',m);
    end

    pvpairs=Aero.internal.namevalues.addNameValuePair(pvpairs,'XData',numericArgs{1});
    pvpairs=Aero.internal.namevalues.addNameValuePair(pvpairs,'YData',numericArgs{2});

end