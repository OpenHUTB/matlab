classdef Corner<serdes.internal.ibisami.ami.format.ListCommon
...
...
...
...
...
...
...


    properties(Dependent)
Typ
Slow
Fast
    end
    properties(Constant)
        Name="Corner";
    end
    properties(Constant,Access=private)
        TypIndex=1;
        SlowIndex=2;
        FastIndex=3;
    end
    methods

        function format=Corner(varargin)
            if nargin==1
                values=varargin{1};
                if length(values)==3
                    format.Values=values;
                    format.Default=values{1};
                end
            elseif nargin==3
                values=varargin;
                format.Values=values;
                format.Default=values{1};
            else
                error(message('serdes:ibis:InvalidConstructor'))
            end
        end
    end
    methods

    end
    methods
        function typ=get.Typ(corner)
            typ=corner.Values(corner.TypIndex);
        end
        function set.Typ(corner,typ)
            corner.setValue(typ,corner.TypIndex);
        end
        function slow=get.Slow(corner)
            slow=corner.Values(corner.SlowIndex);
        end
        function set.Slow(corner,slow)
            corner.setValue(slow,corner.SlowIndex);
        end
        function fast=get.Fast(corner)
            fast=corner.Values(corner.FastIndex);
        end
        function set.Fast(corner,fast)
            corner.setValue(fast,corner.FastIndex);
        end
    end
end

