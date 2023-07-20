classdef(CaseInsensitiveProperties,TruncatedProperties)...
    ampoutput<rfckt.rfckt
















    properties

        OriginalCkt=[];
    end
    methods
        function set.OriginalCkt(obj,value)

            obj.OriginalCkt=setamplifier(obj,value,'OriginalCkt');
        end
    end

    properties(GetAccess=public,Hidden)

        EqualToOriginal=false;
    end


    methods
        function h=ampoutput(varargin)










            set(h,'Name','Amplifier Output Part',varargin{:});
        end

    end

    methods
        out=convertfreq(h,in,varargin)
        [cmatrix,ctype]=noise(h,freq)
        [type,netparameters,z0]=nwa(h,freq)

        function checkproperty(~)
        end
    end

end


function out=setamplifier(h,out,prop_name)
    if isempty(out)
        return
    end
    if(~isa(out,'rfckt.amplifier'))
        error(message('rfblks:rfbbequiv:ampoutput:schema:NotAnAmplifier',...
        h.Name,prop_name));
    end
end

