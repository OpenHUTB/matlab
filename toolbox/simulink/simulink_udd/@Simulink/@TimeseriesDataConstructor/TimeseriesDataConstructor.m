function h=TimeseriesDataConstructor(inCell)


    h=Simulink.TimeseriesDataConstructor;
    if nargin>0
        h.Constructor=inCell;
    end