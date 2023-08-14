


classdef CommIPAddressInfoT
    properties
        localURL='0.0.0.0';
        localPort=int32(-1);
        remoteURL='0.0.0.0';
        remotePort=int32(0);
    end
    methods
        function this=CommIPAddressInfoT(varargin)
            this=eda.internal.mcosutils.ObjUtilsT.Ctor(this,varargin{:});
        end

        function this=set.localURL(this,val)
            this.localURL=eda.internal.mcosutils.ObjUtilsT.CheckString(...
            val,'localURL');
        end
        function this=set.localPort(this,val)
            this.localPort=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(...
            val,'int32',[-1,intmax('int32')],'localPort');
        end
        function this=set.remoteURL(this,val)
            this.remoteURL=eda.internal.mcosutils.ObjUtilsT.CheckString(...
            val,'remoteURL');
        end
        function this=set.remotePort(this,val)
            this.remotePort=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(...
            val,'int32',[-1,intmax('int32')],'remotePort');
        end

    end
end
