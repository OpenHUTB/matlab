function configureAxes(ax,x,y,z)























    narginchk(3,4)

    num=true(1,3);
    num(1)=~doesClassHaveDedicatedRuler(x);
    num(2)=~doesClassHaveDedicatedRuler(y);
    try
        if nargin<4
            if isempty(ax)
                ax=gca;
            end
            [isCartesianAxes,configRulers]=checkChildren(num,ax,x,y);
        else
            num(3)=~doesClassHaveDedicatedRuler(z);
            if isempty(ax)
                ax=gca;
            end
            [isCartesianAxes,configRulers]=checkChildren(num,ax,x,y,z);
        end
    catch e
        throwAsCaller(e)
    end

    if isCartesianAxes
        if configRulers(1)&&(~isempty(x)||~num(1))
            matlab.graphics.internal.configureRuler(ax,'X',0,x)
        end
        if configRulers(2)&&(~isempty(y)||~num(2))
            matlab.graphics.internal.configureRuler(ax,'Y',1,y)
        end
        if nargin>3&&configRulers(3)&&(~isempty(z)||~num(3))
            matlab.graphics.internal.configureRuler(ax,'Z',2,z)
        end
    end
end

function[isCartesianAxes,configRulers]=checkChildren(num,ax,x,y,z)
    isCartesianAxes=isa(ax,'matlab.graphics.axis.Axes');

    if any(~num)&&~isCartesianAxes
        error(message('MATLAB:graphics:configureAxes:CartesianOnly'));
    end

    configRulers=true(1,3);
    if~isCartesianAxes
        return
    end

    configRulers(1)=checkDim(ax,'X',x,num(1));
    configRulers(2)=checkDim(ax,'Y',y,num(2));
    if nargin>4
        configRulers(3)=checkDim(ax,'Z',z,num(3));
    end
end

function configRuler=checkDim(ax,dim,val,isnum)

    configRuler=true;
    if isnum&&isempty(val)
        configRuler=false;
        return;
    end

    prop=['Active',dim,'Ruler'];
    if~isprop(ax,prop)
        return;
    end

    oldRuler=ax.(prop);
    ch=matlab.graphics.internal.getChildrenForRuler(oldRuler);

    if isempty(ch)
        return
    end

    if isnum&&~isa(oldRuler,'matlab.graphics.axis.decorator.NumericRuler')
        configRuler=false;
        return
    end

    cls='';
    if~isa(val,'datetime')&&isa(oldRuler,'matlab.graphics.axis.decorator.DatetimeRuler')
        cls='datetime';
    elseif~isa(val,'duration')&&isa(oldRuler,'matlab.graphics.axis.decorator.DurationRuler')
        cls='duration';
    elseif~isa(val,'categorical')&&isa(oldRuler,'matlab.graphics.axis.decorator.CategoricalRuler')
        cls='categorical';
    elseif~isnum&&isa(oldRuler,'matlab.graphics.axis.decorator.NumericRuler')
        error(message('MATLAB:graphics:configureAxes:Mixing'));
    end
    if~isempty(cls)
        if strcmp(dim,'X')
            error(message('MATLAB:graphics:configureAxes:MixingX',cls,cls,cls));
        else
            error(message('MATLAB:graphics:configureAxes:MixingOther',cls,cls,cls));
        end
    end
end

function tf=doesClassHaveDedicatedRuler(val)

    tf=isa(val,'datetime')||isa(val,'duration')||isa(val,'categorical');

end
