classdef(CaseInsensitiveProperties,TruncatedProperties)...
    ampinput<rfckt.rfckt














    properties

        OriginalCkt=[];
    end
    methods
        function set.OriginalCkt(obj,value)

            obj.OriginalCkt=setamplifier(obj,value,'OriginalCkt');
        end
    end


    methods
        function h=ampinput(varargin)











            set(h,'Name','Amplifier Input Part',varargin{:});
        end

    end

    methods
        [cmatrix,ctype]=noise(h,freq)
        [type,netparameters,z0]=nwa(h,freq)

        function checkproperty(h)
        end
    end

end


function out=setamplifier(h,out,prop_name)
    if isempty(out)
        return
    end
    if(~isa(out,'rfckt.amplifier'))
        error(message('rfblks:rfbbequiv:ampinput:schema:NotAnAmplifier',...
        h.Name,prop_name));
    end
end

