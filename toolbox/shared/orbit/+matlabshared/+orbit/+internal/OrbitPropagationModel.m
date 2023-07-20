classdef(Abstract,Hidden)OrbitPropagationModel<handle %#codegen





    properties(SetAccess=protected)
InitialPosition
InitialVelocity
InitialTime
Position
Velocity
Time
    end

    properties(Hidden,Constant)
        StandardGravitationalParameter=398600.4418e9
        EarthRadius=6378137
        EarthAngularVelocity=0.0000729211585530
    end

    methods
        function reset(propagator)





            coder.allowpcode('plain');


            initialize(propagator);
        end

        function[position,velocity,time]=step(propagator,t)




























            coder.allowpcode('plain');



            if isnumeric(t)
                time=propagator.Time+seconds(t);
            else
                if isempty(coder.target)&&~isequal(t.TimeZone,'UTC')


                    t.TimeZone='UTC';
                end
                time=t;
            end


            [position,velocity]=stepImpl(propagator,time);


            propagator.Position=position(:,end);
            propagator.Velocity=velocity(:,end);
            propagator.Time=time(:,end);
        end
    end

    methods(Abstract,Access=protected)
        initialize(propagator)
        [position,velocity,time]=stepImpl(propagator,tStep)
    end
end


