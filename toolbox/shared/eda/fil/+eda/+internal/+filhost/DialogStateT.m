



classdef DialogStateT
    properties
        bitstreamFile='<Specify FPGA programming file>';
        prevBrowsePath='';
        loadOnSim=false;
        loadStatus='Status: FPGA programming file not loaded';
        IPAddress='192.168.0.2';
        Username='root';
        Password='root';
    end
    methods
        function this=DialogStateT(varargin)
            this=eda.internal.mcosutils.ObjUtilsT.Ctor(this,varargin{:});
        end

        function this=set.bitstreamFile(this,val)
            this.bitstreamFile=eda.internal.mcosutils.ObjUtilsT.CheckString(val,'bitstreamFile');
        end
        function this=set.prevBrowsePath(this,val)
            this.prevBrowsePath=eda.internal.mcosutils.ObjUtilsT.CheckString(val,'prevBrowsePath');
        end
        function this=set.loadOnSim(this,val)
            this.loadOnSim=eda.internal.mcosutils.ObjUtilsT.CheckBool(val,'loadOnSim');
        end
        function this=set.loadStatus(this,val)
            this.loadStatus=eda.internal.mcosutils.ObjUtilsT.CheckString(val,'loadStatus');
        end
        function this=set.IPAddress(this,val)
            if isempty(regexp(val,'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$','match'))
                error(message('EDALink:FILSimulation:IPAddress'));
            end
            this.IPAddress=eda.internal.mcosutils.ObjUtilsT.CheckString(val,'IPAddress');
        end
        function this=set.Username(this,val)
            this.Username=eda.internal.mcosutils.ObjUtilsT.CheckString(val,'Username');
        end
        function this=set.Password(this,val)
            this.Password=eda.internal.mcosutils.ObjUtilsT.CheckString(val,'Password');
        end
    end
end
