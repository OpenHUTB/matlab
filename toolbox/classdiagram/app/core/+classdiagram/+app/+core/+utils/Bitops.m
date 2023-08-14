classdef Bitops
    methods(Static)
        function flag=unsetFlag(flag,varargin)
            val=classdiagram.app.core.utils.Bitops.getCumulutive(varargin{:});
            flag=bitand(flag,bitcmp(val,'uint8'));
        end

        function flag=setFlag(flag,varargin)
            val=classdiagram.app.core.utils.Bitops.getCumulutive(varargin{:});
            flag=bitor(flag,val);
        end

        function isSet=isAllSet(flag,varargin)
            val=classdiagram.app.core.utils.Bitops.getCumulutive(varargin{:});
            isSet=bitand(flag,val)==val;
        end

        function isSet=isAnySet(flag,varargin)
            val=classdiagram.app.core.utils.Bitops.getCumulutive(varargin{:});
            isSet=bitand(flag,val)>0;
        end

        function t=getCumulutive(varargin)
            if nargin==1
                t=varargin{1};
                return;
            end
            val=varargin;
            t=val{1};
            while numel(val)>1
                t=bitor(t,val{2});
                val(1)=[];
            end
        end
    end
end