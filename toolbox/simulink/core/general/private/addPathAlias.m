function xout=addPathAlias(mdl,xin)







    mdl=get_param(mdl,'Name');
    needTerm=false;

    if~isequal(get_param(mdl,'SimulationStatus'),'paused')
        feval(mdl,'init');
        needTerm=true;
    end

    xout=feval(mdl,'addPathAlias',xin);

    if needTerm
        feval(mdl,'term');
    end

end