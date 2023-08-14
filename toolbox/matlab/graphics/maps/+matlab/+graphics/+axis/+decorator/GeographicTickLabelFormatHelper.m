classdef(Hidden)GeographicTickLabelFormatHelper<handle&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer












    properties(Dependent,AbortSet)
        TickLabelFormat='dms'
    end

    properties(Hidden)
        TickLabelFormat_I(1,1)string="dms"
    end

    properties(Hidden,AbortSet)
        TickLabelFormatMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Access=private,Constant)
        ValidTickLabelFormats=["dd","dm","dms","-dd","-dm","-dms"];
    end


    methods
        function set.TickLabelFormat(obj,fmt)
            try
                fmt=validatestring(fmt,obj.ValidTickLabelFormats);
            catch e
                throwAsCaller(e)
            end
            obj.TickLabelFormat_I=fmt;
            obj.TickLabelFormatMode='manual';
        end


        function fmt=get.TickLabelFormat(obj)
            fmt=char(obj.TickLabelFormat_I);
        end


        function set.TickLabelFormat_I(obj,fmt)
            obj.TickLabelFormat_I=fmt;
            setTickLabelFormatFollowup(obj)
        end
    end


    methods(Access=protected,Hidden)
        function setTickLabelFormatFollowup(~)


        end
    end
end
