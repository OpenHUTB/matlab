function configureRuler(ax,dim,num,val)




    if~isa(ax,'matlab.graphics.axis.Axes')
        error(message('MATLAB:graphics:configureAxes:CartesianOnly'));
    end

    activeProp=['Active',dim,'Ruler'];
    oldRuler=ax.(activeProp);

    ruler=[];

    if isa(val,'datetime')&&~isa(oldRuler,'matlab.graphics.axis.decorator.DatetimeRuler')
        ruler=matlab.graphics.axis.decorator.DatetimeRuler;
        ruler.DataFormat=val.Format;
        finiteVals=isfinite(val);
        if any(finiteVals,'all')
            ruler.ReferenceDate_I=val(find(finiteVals,1,'first'));
        elseif~isempty(val.TimeZone)
            ruler.ReferenceDate_I.TimeZone=val.TimeZone;
        end
    elseif isa(val,'duration')&&~isa(oldRuler,'matlab.graphics.axis.decorator.DurationRuler')
        ruler=matlab.graphics.axis.decorator.DurationRuler;
        singleUnits={'y','d','h','m','s'};
        converter={@years,@days,@hours,@minutes,@seconds};
        ind=strcmp(val.Format,singleUnits);
        if any(ind)
            ruler.Converter=converter{ind};
        end
        ruler.TickLabelFormat=val.Format;
    elseif isa(val,'categorical')&&~isa(oldRuler,'matlab.graphics.axis.decorator.CategoricalRuler')
        ruler=matlab.graphics.axis.decorator.CategoricalRuler;
    elseif~isa(val,'datetime')&&~isa(val,'duration')&&~isa(val,'categorical')&&~isa(oldRuler,'matlab.graphics.axis.decorator.NumericRuler')
        ruler=matlab.graphics.axis.decorator.NumericRuler;
    end


    if~isempty(ruler)
        if isa(ruler,'matlab.graphics.axis.decorator.NumericRuler')
            ax.setActiveRuler(ruler,num);
        else
            if isa(ax,'matlab.graphics.axis.AbstractAxes')
                b=hggetbehavior(ax,'DataDescriptor');
                b.Enable=false;
                b.Serialize=true;
                b=hggetbehavior(ax,'Print');
                b.CheckDataDescriptorBehavior='off';
            end
            ax.setActiveRuler(ruler,num);
            addData(ruler,val);
        end
    else
        if~isa(oldRuler,'matlab.graphics.axis.decorator.NumericRuler')
            addData(oldRuler,val);
        end
    end
