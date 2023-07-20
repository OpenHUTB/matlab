classdef ParamStatus<int8
    enumeration
        Normal(0)
        ReadOnly(1)
        InAccessible(2)
        UnAvailable(3)
    end

    methods(Static)
        function obj=create(str)
            lstr=lower(str);
            switch lstr
            case{'n','normal','accessible','~readonly','available','~unavailable','enable','~disable','inuse'}
                obj=configset.internal.data.ParamStatus.Normal;
            case{'r','readonly','~writable','~enable','disable'}
                obj=configset.internal.data.ParamStatus.ReadOnly;
            case{'i','inaccessible','~accessible'}
                obj=configset.internal.data.ParamStatus.InAccessible;
            case{'u','unavailable','~available','~inuse'}
                obj=configset.internal.data.ParamStatus.UnAvailable;
            otherwise
                error(['wrong status type: ',str]);
            end
        end

    end

    methods
        function str=toString(x)
            switch x
            case configset.internal.data.ParamStatus.Normal
                str='Normal';
            case configset.internal.data.ParamStatus.ReadOnly
                str='ReadOnly';
            case configset.internal.data.ParamStatus.InAccessible
                str='InAccessible';
            case configset.internal.data.ParamStatus.UnAvailable
                str='UnAvailable';
            end
        end

        function out=toInt(x)
            out=x+1-1;
        end

        function jsonStr=jsonencode(x,varargin)
            jsonStr=num2str(int8(x));
        end
    end

end
