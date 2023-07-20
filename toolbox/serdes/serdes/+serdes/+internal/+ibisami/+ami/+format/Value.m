classdef Value<serdes.internal.ibisami.ami.format.ListCommon

...
...
...
...
...
...



    properties(Constant)
        Name="Value";
    end
    methods

        function format=Value(varargin)

            if nargin>0
                format.Values=varargin{1};
                format.Default=varargin{1};
            end
        end
    end
    methods(Access=protected)

        function[ok,value]=validateDefault(format,value)
...
...
...
...
...



            format.Values=value;
            ok=true;
        end
        function[ok,value]=validateValues(~,value)



            if isscalar(value)
                value=string(value);
                ok=true;
            else

                error(message('serdes:ibis:InvalidConstructor'))
            end
        end
    end
    methods

    end
end

