


classdef abstractArithHDLComp<dsphdlshared.basiccomp.abstractElabHDLComp

    properties(Dependent=true,SetAccess=protected,GetAccess=protected)
RoundingMethod
OverflowAction
    end


    methods




        function this=abstractArithHDLComp(varargin)
            this=this@dsphdlshared.basiccomp.abstractElabHDLComp(varargin{:});
        end
    end

    methods
        function set.RoundingMethod(this,rnd)

            if~any(strcmp(rnd,{'Ceiling','Convergent','Floor','Nearest','Round','Zero'})),
                this.validationError([rnd,' is not a valid value for property RoundingMethod.']);
            end


        end

        function set.OverflowAction(this,sat)

            if~any(strcmp(sat,{'Wrap','Saturate'})),
                this.validationError([sat,' is not a valid value for property OverflowAction.']);
            end


        end
    end

    methods(Access=protected)
        function c=getDefaultPropVals(this)




            c=['RoundingMethod','Floor',...
            'OverflowAction','Wrap',...
            getDefaultPropVals@dsphdlshared.basiccomp.abstractElabHDLComp(this)];
        end

    end
end
