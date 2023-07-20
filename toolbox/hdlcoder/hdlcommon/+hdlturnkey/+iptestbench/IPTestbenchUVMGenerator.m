classdef IPTestbenchUVMGenerator<handle

    properties
        hIPTB=[];

        ModelName='';
        DUTName='';


        IPCoreCompName=[];


        IPCoreOrigBaseRate=0;
        IPCoreCodegenRateScaling=1;
        IPCoreExtraDelayNumber=0;


        IPCoreInportNames={};
        IPCoreOutportNames={};


        hIPCoreGenIOPortList=[];

        hModelIOToCodegenIOMap=[];

        hIOPortToSignalMap=[];
    end

    properties(Access=private)

        uvm_tmplt_path=fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','+hdlturnkey','+iptestbench','+ipuvmcodegen');
sluvm
uvmbfm
svif
sequence
scoreboard
mcfg
ucfg
    end

    methods

        function obj=IPTestbenchUVMGenerator(hIPTB)
            obj.hIPTB=hIPTB;
        end


        function configUVMComponent(obj)

            build_path='./overrides_DUT';

            obj.mcfg=uvmcodegen.mwconfig(obj.DUTName);
            obj.ucfg=uvmcodegen.uvmconfig();
            obj.ucfg.CreateUVMDirHierarchy(build_path,logical([0,0,0]));

            obj.sluvm=uvmcodegen.SimulinkUVM('mwcfg',obj.mcfg,'ucfg',obj.ucfg,'seqblk_path',obj.sequence,'scrblk_path',obj.scoreboard);
            obj.uvmbfm=uvmcodegen.uvm_component('mwcfg',obj.mcfg,'ucfg',obj.ucfg,'IsDUTBuild',true,'UVMComponent','DPI_dut','uvmobj_type','uvm_transaction');
        end


        function getIPCoreCodeGenPIRInfo(obj)

            hDI=obj.hIPTB.hIP.hD;
            obj.ModelName=hDI.getModelName;
            obj.DUTName=hDI.getDutName;

            obj.hIPCoreGenIOPortList=hdlturnkey.data.IOPortList;


            p=pir;
            obj.IPCoreCompName=p.getTopNetwork.Name;
            obj.hIPCoreGenIOPortList.buildIOPortList(p,hDI);


            obj.IPCoreOrigBaseRate=p.getOrigDutBaseRate;
            obj.IPCoreCodegenRateScaling=p.getDutBaseRateScalingFactor;
        end

        function runUVMBuild(obj)
            obj.sequence=[obj.ModelName,'/','sequence'];
            obj.scoreboard=[obj.ModelName,'/','scoreboard'];
            uvmbuild(obj.DUTName,obj.sequence,obj.scoreboard);
        end

        function generateInterface(obj)

            obj.svif=hdlturnkey.iptestbench.ipuvmcodegen.ip_sv_interface(obj,'mwcfg',obj.mcfg,'ucfg',obj.ucfg,...
            'svinf_tmplt',fullfile(obj.uvm_tmplt_path,'lib','mw_interface.sv'),...
            'dut_codeinfo',obj.uvmbfm.mwblkUVMVCodeInfo,'UVMComponent','uvm_artifacts');
            fid10=fopen(obj.svif.get_sv_ifnam_fileLoc(),'w');
            c10=onCleanup(@()fclose(fid10));
            fprintf(fid10,obj.svif.prtsvinf);
        end

        function generateDriver(obj)
            uvmdrv=hdlturnkey.iptestbench.ipuvmcodegen.ip_uvm_driver(obj,'mwcfg',obj.mcfg,'ucfg',obj.ucfg,...
            'uvmcmp_tmplt',fullfile(obj.uvm_tmplt_path,'lib','mw_driver.sv'),'uvmobj_tmplt','',...
            'dut_handle',obj.uvmbfm,'vif_handle',obj.svif,'UVMComponent','uvm_artifacts','DrvMode','PT');
            fid=fopen(uvmdrv.get_uvmcmp_name_fileLoc(),'w');
            c=onCleanup(@()fclose(fid));
            fprintf(fid,uvmdrv.prtuvmcmp);
        end

        function generateAgent(obj)

        end

        function generateMonitor(obj)

        end

        function generateMonitorInput(obj)

        end

        function generateTest(obj)

        end

        function generateTop(obj)

        end

        function generateExtension(obj)

        end

        function generateUVMScripts(obj)

        end
    end
end

