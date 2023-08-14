classdef DualDirac<serdes.internal.ibisami.ami.format.JitterFormat

...
...
...
...
...
...
...
...


    properties(Constant)
        Name="Dual-Dirac";
    end
    properties(Constant,Access=private)
        Mean1Index=1;
        Mean2Index=2;
        SigmaIndex=3;
    end
    properties(Dependent)
Mean1
Mean2
Sigma
    end
    methods
        function dualDirac=DualDirac(varargin)
            if nargin==1
                values=varargin{1};
            elseif nargin==3
                values=varargin;
            else
                values={};
            end
            dualDirac.Values=values;
        end
    end
    methods

        function set.Mean1(dualDirac,mean)
            dualDirac.setValue(mean,dualDirac.Mean1Index);
        end
        function mean1=get.Mean1(dualDirac)
            mean1=dualDirac.Values(dualDirac.Mean1Index);
        end
        function set.Mean2(dualDirac,mean)
            dualDirac.setValue(mean,dualDirac.Mean2Index);
        end
        function mean2=get.Mean2(dualDirac)
            mean2=dualDirac.Values(dualDirac.Mean2Index);
        end
        function set.Sigma(dualDirac,sigma)
            dualDirac.setValue(sigma,dualDirac.SigmaIndex);
        end
        function sigma=get.Sigma(dualDirac)
            sigma=dualDirac.Values(dualDirac.SigmaIndex);
        end
    end
end

