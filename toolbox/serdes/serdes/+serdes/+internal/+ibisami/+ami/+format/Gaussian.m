classdef Gaussian<serdes.internal.ibisami.ami.format.JitterFormat
...
...
...
...
...
...
...
...



    properties(Constant)
        Name="Gaussian";
    end
    properties(Constant,Access=private)
        MeanIndex=1;
        SigmaIndex=2;
    end
    properties(Dependent)
Mean
Sigma
    end
    methods
        function gaussian=Gaussian(varargin)
            if nargin==1
                values=varargin{1};
            elseif nargin==2
                values=varargin;
            else
                values={};
            end
            gaussian.Values=values;
        end
    end
    methods

        function set.Mean(gaussian,mean)
            gaussian.setValue(mean,gaussian.MeanIndex);
        end
        function mean=get.Mean(gaussian)
            mean=gaussian.Values(gaussian.MeanIndex);
        end
        function set.Sigma(gaussian,sigma)
            gaussian.setValue(sigma,gaussian.SigmaIndex);
        end
        function sigma=get.Sigma(gaussian)
            sigma=gaussian.Values(gaussian.SigmaIndex);
        end
    end
end

