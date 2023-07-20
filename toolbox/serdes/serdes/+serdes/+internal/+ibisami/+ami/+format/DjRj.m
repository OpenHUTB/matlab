classdef DjRj<serdes.internal.ibisami.ami.format.JitterFormat
...
...
...
...
...
...
...
...
...
...
...



    properties(Constant)
        Name="DjRj";
    end
    properties(Constant,Access=private)
        MinIndex=1;
        MaxIndex=2;
        SigmaIndex=3;
    end
    properties(Dependent)
MinDj
MaxDj
Sigma
    end
    methods

        function djRj=DjRj(varargin)
            if nargin==1
                values=varargin{1};
            elseif nargin==3
                values=varargin;
            else
                values={};
            end
            djRj.Values=values;
        end
    end
    methods

        function set.MinDj(djRj,minDj)
            djRj.setValue(minDj,djRj.MinIndex);
        end
        function minDj=get.MinDj(djRj)
            minDj=djRj.Values(djRj.MinIndex);
        end
        function set.MaxDj(djRj,maxDj)
            djRj.setValue(maxDj,djRj.MaxIndex);
        end
        function maxDj=get.MaxDj(djRj)
            maxDj=djRj.Values(djRj.MaxIndex);
        end
        function set.Sigma(djRj,sigma)
            djRj.setValue(sigma,djRj.SigmaIndex);
        end
        function sigma=get.Sigma(djRj)
            sigma=djRj.Values(djRj.SigmaIndex);
        end
    end
end

