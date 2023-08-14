function newValue=setDeltaImpl(hObj,newValue,propName,cacheName,axis)






    if isnumeric(newValue)


        newValue=newValue(:)';
        hObj.(cacheName)=newValue;
    else

        assert(isempty(newValue)||isvector(newValue),...
        message('MATLAB:hg:shaped_arrays:VectorDataSize'));


        [rulers{1:2}]=matlab.graphics.internal.getRulersForChild(hObj);
        ruler=rulers{axis+1};

        if isempty(ruler)

            assert(isduration(newValue),message('MATLAB:errorbar:DeltaTypeMustBeNumericOrDuration',propName));
        elseif isa(ruler,'matlab.graphics.axis.decorator.DurationRuler')||...
            isa(ruler,'matlab.graphics.axis.decorator.DatetimeRuler')
            assert(isduration(newValue),message('MATLAB:errorbar:DeltaTypeMustBeDuration',propName));
        elseif isa(ruler,'matlab.graphics.axis.decorator.CategoricalRuler')

            error(message('MATLAB:errorbar:CategoricalDeltaNotSupported',propName));
        else

            error(message('MATLAB:errorbar:DeltaTypeMustBeNumeric',propName));
        end


        hObj.(cacheName)=[];


        newValue=newValue(:)';
    end
