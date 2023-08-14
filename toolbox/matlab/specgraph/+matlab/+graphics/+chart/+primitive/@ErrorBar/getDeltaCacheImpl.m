function deltaCache=getDeltaCacheImpl(hObj,propName,cacheName,delta,deltaCache,axis)





    if isempty(deltaCache)&&~isempty(delta)
        if isnumeric(delta)


            deltaCache=delta;
        else

            [rulers{1:2}]=matlab.graphics.internal.getRulersForChild(hObj);
            ruler=rulers{axis+1};


            if~isempty(ruler)
                if isa(ruler,'matlab.graphics.axis.decorator.DurationRuler')


                    deltaCache=ruler.makeNumeric(delta);
                elseif isa(ruler,'matlab.graphics.axis.decorator.DatetimeRuler')








                    deltaCache=ruler.makeNumeric(delta+ruler.ReferenceDate);
                elseif isa(ruler,'matlab.graphics.axis.decorator.CategoricalRuler')

                    error(message('MATLAB:errorbar:CategoricalDeltaNotSupported',propName));
                else

                    error(message('MATLAB:errorbar:DeltaTypeMustBeNumeric',propName));
                end
            end
        end


        hObj.(cacheName)=deltaCache;
    end
