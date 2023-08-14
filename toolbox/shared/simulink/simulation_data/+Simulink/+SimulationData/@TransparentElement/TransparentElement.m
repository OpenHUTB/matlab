

























classdef TransparentElement<Simulink.SimulationData.Element


    properties(Access='public')
        Values=[];
    end


    methods
        function[elementVal,name,retIdx]=find(~,varargin)
            elementVal=[];
            name='';
            retIdx=[];
        end

        function out=copy(this)

            n=numel(this);
            out=this;
            for idx=1:n
                out(idx).Values=Simulink.SimulationData.utCopyRecurse(this(idx).Values);
            end
        end
    end
end
