


classdef IPCoreConfig<hwcli.base.IPCoreBase&hwcli.base.DeployBase






    properties



IPAddress
SSHUsername
SSHPassword
    end





    methods
        function obj=IPCoreConfig(tool)
            obj=obj@hwcli.base.IPCoreBase('IP Core Generation',tool);
            obj=obj@hwcli.base.DeployBase();


            obj.RunTaskProgramTargetDevice=false;
            try
                if startsWith(obj.SynthesisTool,'Altera')||startsWith(obj.SynthesisTool,'Intel')
                    hBoardParams=codertarget.hdlcintel.internal.BoardParameters;
                elseif startsWith(obj.SynthesisTool,'Xilinx')
                    hBoardParams=codertarget.hdlcxilinx.internal.BoardParameters;
                end

                obj.IPAddress=hBoardParams.getParam('ipaddress');
                obj.SSHUsername=hBoardParams.getParam('username');
                obj.SSHPassword=hBoardParams.getParam('password');
            catch


                obj.IPAddress='';
                obj.SSHUsername='';
                obj.SSHPassword='';
            end


            obj.Tasks={...
            'RunTaskGenerateRTLCodeAndIPCore',...
            'RunTaskCreateProject',...
            'RunTaskGenerateSoftwareInterface',...
            'RunTaskBuildFPGABitstream',...
            'RunTaskProgramTargetDevice'};


            obj.Properties(...
            'RunTaskProgramTargetDevice')=...
            {'ProgrammingMethod',...
            'IPAddress',...
            'SSHUsername',...
            'SSHPassword'};

        end
    end





    methods
        function val=get.IPAddress(obj)
            if obj.ProgrammingMethod~=hdlcoder.ProgrammingMethod.Download
                val='';
            else
                val=obj.IPAddress;
            end
        end

        function val=get.SSHUsername(obj)
            if obj.ProgrammingMethod~=hdlcoder.ProgrammingMethod.Download
                val='';
            else
                val=obj.SSHUsername;
            end
        end

        function val=get.SSHPassword(obj)
            if obj.ProgrammingMethod~=hdlcoder.ProgrammingMethod.Download
                val='';
            else
                val=obj.SSHPassword;





            end
        end

        function set.IPAddress(obj,val)
            if obj.ProgrammingMethod==hdlcoder.ProgrammingMethod.Download
                downstream.tool.validateIPAddress(val);
            end
            obj.IPAddress=val;
        end
    end
end


