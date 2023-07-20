



classdef SoftwareVersionT
    properties
        majorRev=uint8(2);
        minorRev=uint8(0);
    end
    methods
        function this=SoftwareVersionT(varargin)
            this=eda.internal.mcosutils.ObjUtilsT.Ctor(this,varargin{:});
        end
        function this=set.majorRev(this,val)
            this.majorRev=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'uint8',[0,intmax('uint8')],'majorRev');
        end
        function this=set.minorRev(this,val)
            this.minorRev=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'uint8',[0,intmax('uint8')],'minorRev');
        end
    end
end
