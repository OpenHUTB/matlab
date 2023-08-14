classdef parameters
    properties

        RelTol=1e-3
        AbsTol=1e-6


        OpMaxIters=20
        OpVoltageLimit=0.6
        OpVerbose=false
        OpConductanceToGround=1e-12
        OpJacobianUpdatePeriod=1


TranStep
TranMaxStep
TranStop
        TranMaxIters=10
        TranVoltageLimit=0.3
        TranMethod='trapezoidal'
        TranJacobianUpdatePeriod=3
        TranTrTol=7
        TranMinStep=1e-23
        TranVerbose=true
        TranHistoryLength=100
        TranInitialState='op'



        HbTones=[]
        HbNumHarmonics=[]
        HbVoltageLimit=0.3
        HbTruncation='box'
        HbMaxIters=10
        HbVerbose=false
        HbMethod='trap'
        HbIntegrationMethod='trap'
        HbTestLinearizedJacobian=false
        HbInitialState='op'
        HbConductanceToGround=1e-12
        HbJacobianUpdatePeriod=3
    end

    methods
        function self=parameters(varargin)
            props=properties(self);
            for i=1:2:length(varargin)
                name=varargin{i};
                value=varargin{i+1};

                if any(strcmp(name,props))
                    self.(name)=value;
                else
                    error(['parameter "',name,'" is not defined']);
                end
            end
        end

        function self=test(self,i)
            self.HbNumHarmonics(1,2)=i;
        end
    end
end
