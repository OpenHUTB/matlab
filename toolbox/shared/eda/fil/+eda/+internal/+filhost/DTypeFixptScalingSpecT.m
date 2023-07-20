



classdef DTypeFixptScalingSpecT
    properties
        wordLength=uint32(0.0);
        fractionLength=int32(0.0);
        totalSlope=double(0.0);
        bias=double(0.0);
    end
    methods
        function this=DTypeFixptScalingSpecT(varargin)
            this=eda.internal.mcosutils.ObjUtilsT.Ctor(this,varargin{:});
        end

        function this=set.wordLength(this,val)
            this.wordLength=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'uint32',[0,128],'wordLength');
        end
        function this=set.fractionLength(this,val)
            this.fractionLength=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'int32',[intmin('int32'),intmax('int32')],'fractionLength');
        end
        function this=set.totalSlope(this,val)
            this.totalSlope=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'double',[-1*realmax,realmax],'totalSlope');
        end
        function this=set.bias(this,val)
            this.bias=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'double',[-1*realmax,realmax],'bias');
        end
    end
end