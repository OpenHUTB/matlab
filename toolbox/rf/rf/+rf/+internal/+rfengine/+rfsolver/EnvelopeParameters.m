classdef EnvelopeParameters




    properties

        RelTol=1e-3
        RelTolMax=1e-3

        AbsTol=1e-6
        epsRelaxationFactor=1e3
        ErrorEstimationType=1;
        SmallSignalApprox=0;
        AllSimFreqs=1;
        SimFreqs=[];


        HbMaxIters=10
        HbVerbose=false
        HbJacobianUpdatePeriod=3
        HbIntegrationMethod='trap'


        HbTestLinearizedJacobian=false
    end

    methods
        function this=EnvelopeParameters(varargin)
            props=properties(this);
            for i=1:2:length(varargin)
                name=varargin{i};
                value=varargin{i+1};

                if any(strcmp(name,props))
                    this.(name)=value;
                else
                    error(['parameter "',name,'" is not defined'])
                end
            end
        end

        function test(o,i)
            o.HbNumHarmonics(1,2)=i;
        end
    end
end
