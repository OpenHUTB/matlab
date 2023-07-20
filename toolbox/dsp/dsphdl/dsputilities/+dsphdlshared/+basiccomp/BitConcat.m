classdef BitConcat<dsphdlshared.basiccomp.abstractElabHDLComp













    properties(Dependent=true,SetAccess=protected,GetAccess=protected)
Inputs
Outputs
    end


    methods

        function this=BitConcat(varargin)
            this=this@dsphdlshared.basiccomp.abstractElabHDLComp(varargin{:});
        end
    end


    methods(Access=protected)
        function hC=interfaceFcn(this,s)%#ok<MANU>

            hC=emlainterface.getBitConcat(s);
        end
    end


    methods


        function set.Inputs(this,val)%#ok<INUSD,MANU>

        end

        function set.Outputs(this,val)%#ok<INUSD,MANU>

        end

    end


    methods(Access=protected)

        function setConstructorPVs(this,pv)






            fn=fieldnames(pv);
            for ii=1:numel(fn),
                this.(fn{ii})=pv.(fn{ii});
            end
        end
    end




end