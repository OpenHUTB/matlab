













classdef Element


    properties(Access='public')

        Name='';

    end


    methods

        function this=set.Name(this,val)


            if ischar(val)||isstring(val)
                this.Name=char(val);
            else
                Simulink.SimulationData.utError('InvalidDatasetElementName');
            end
        end

        function val=copy(this)



            val=this;
        end


    end


    methods(Abstract)

        [elementVal,name,retIdx]=find(this,varargin)

    end

end
