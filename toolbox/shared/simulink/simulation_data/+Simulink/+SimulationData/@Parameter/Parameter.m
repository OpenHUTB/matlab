











classdef Parameter<Simulink.SimulationData.BlockData


    properties(Access='public')
        ParameterName='';
        VariableName='';
    end


    methods


        function this=Parameter()
            this.Version=1;
        end


        function out=isequal(param1,varargin)
            out=loc_eq(@isequal,param1,varargin);
        end


        function out=isequaln(param1,varargin)
            out=loc_eq(@isequaln,param1,varargin);
        end
    end


    properties(Hidden=true,GetAccess=public,SetAccess=private)
        Version=0;
    end
end


function out=loc_eq(fcn,param1,inputs)
    out=true;

    meta=metaclass(param1);
    if~isequal(meta.Name,'Simulink.SimulationData.Parameter')
        out=false;
        return
    end

    props={meta.PropertyList(:).Name};
    skip={'Version'};
    propToCheck=setxor(props,skip);
    for k=1:length(inputs)
        param2=inputs{k};

        meta2=metaclass(param2);
        if~isequal(meta2.Name,'Simulink.SimulationData.Parameter')
            out=false;
            return;
        end

        if~isequal(size(param1),size(param2))
            out=false;
            return;
        end

        for ielm=1:numel(param1)
            param1_elm=param1(ielm);
            param2_elm=param2(ielm);
            for jp=1:length(propToCheck)
                if~fcn(param1_elm.(propToCheck{jp}),param2_elm.(propToCheck{jp}))
                    out=false;
                    return;
                end
            end
        end
    end
end

