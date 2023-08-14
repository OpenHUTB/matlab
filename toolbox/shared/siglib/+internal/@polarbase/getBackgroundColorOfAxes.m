function bgcolor=getBackgroundColorOfAxes(p)





    hax=p.hAxes;
    if isempty(hax)

        bgcolor=[];

    elseif strcmpi(hax.Visible,'on')

        bgcolor=hax.Color;
    else


        par=p.Parent;
        if strcmpi(par.Type,'tiledlayout')
            par=p.Parent.Parent;
        end
        if strcmpi(par.Type,'figure')
            bgcolor=par.Color;
        else
            bgcolor=par.BackgroundColor;
        end
    end
