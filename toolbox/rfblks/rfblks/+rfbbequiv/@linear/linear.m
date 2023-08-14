classdef(CaseInsensitiveProperties,TruncatedProperties)...
    linear<rfbbequiv.rfbbequiv





















    properties

        RFckt=[];
    end
    methods
        function set.RFckt(obj,value)

            obj.RFckt=setckt(obj,value,'RFckt');
        end
    end

    properties(Hidden)

        DeleteCkt=true;
    end
    methods
        function set.DeleteCkt(obj,value)
            if~isequal(obj.DeleteCkt,value)
                checkbool(obj,'DeleteCkt',value)
                obj.DeleteCkt=logical(value);
            end
        end
    end

    properties(Hidden)

        AllPassFilter=false;
    end
    methods
        function set.AllPassFilter(obj,value)
            if~isequal(obj.AllPassFilter,value)
                checkbool(obj,'AllPassFilter',value)
                obj.AllPassFilter=logical(value);
            end
        end
    end

    methods
        function h=linear(varargin)








            if nargin==1&&strcmp(varargin{1},'PhantomConstruction')
                return
            end

            if nargin>0
                [varargin{:}]=convertStringsToChars(varargin{:});
            end





            set(h,'Name','rfbbequiv.linear object',varargin{:});
        end

    end

    methods
        h=analyze(h,freq)
        out=convertfreq(h,in,varargin)
        h=destroy(h,destroyData)
        z0=findimpedance(h)
        data=getdata(h)
    end

    methods
        function tf=islinearvalid(obj)
            tf=isvalid(obj)&&isrfcktvalid(obj.RFckt);
        end
    end

end


function out=setckt(h,out,prop_name)
    if isempty(out)
        return
    end
    if(~isa(out,'rfckt.rfckt'))
        error(message('rfblks:rfbbequiv:linear:schema:NotACKTObj',...
        h.Name,prop_name));
    end
end

