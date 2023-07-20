classdef(Hidden)ip_uvm_driver<uvmcodegen.uvm_driver

    properties(Access=private)
        hUVMGenerator;
    end

    methods

        function this=ip_uvm_driver(h,varargin)
            this=this@uvmcodegen.uvm_driver(varargin{:});
            this.hUVMGenerator=h;
        end

        function str=get_uvmcmp_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths(obj.DrvComp),['mw_DUT_AXIRTL_driver','.sv']));
        end

        function str=prtuvmcmp(this)
            dpigenerator_disp(['Generating IP Core UVM driver ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc())]);

            tpl=prtuvmcmp@uvmcodegen.uvm_component(this);


            tpl=replace(tpl,'%MW_INFO%','');

            tpl=replace(tpl,'%IMPORTS%','');

            tpl=replace(tpl,'%DPI_INIT%','');

            tpl=replace(tpl,'%DRVNAME%','mw_DUT_AXIRTL_driver');
            tpl=replace(tpl,'%OBJHANDLE_DECL%','');
            tpl=replace(tpl,'%ASSERTION_STRUCT_INFO_DECL%','');
            tpl=replace(tpl,'%TSASSERTION_STRUCT_INFO_DECL%','');


            tpl=replace(tpl,'%INFNAME%',[this.ucfg.prefix,this.mwcfg.sldut_name,'AXIRTL',this.ucfg.inf_suffix]);

            tpl=replace(tpl,'%IPCLOCKNAME%',this.hUVMGenerator.hIPCoreGenIOPortList.InputPortNameList{1});
            tpl=replace(tpl,'%IPRESETNAME%',this.hUVMGenerator.hIPCoreGenIOPortList.InputPortNameList{2});

            tpl=replace(tpl,'%SEQITM%','mw_DUT_sequence_trans');
            tpl=replace(tpl,'%TRANSREC_START%','send_inputs_to_monitor(req);');
            tpl=replace(tpl,'%DRIVESIG%','drive_data(req);');
            tpl=replace(tpl,'%BYPASSSIG%','drive_data_not_valid(req, 2);');
            tpl=replace(tpl,'%TRANSREC_STOP%','');


            cellStr=cellfun(@(x)sprintf('\t%s%s%s;\n','dutvif.',x,' <= ''h0'),this.hUVMGenerator.hIPCoreGenIOPortList.InputPortNameList(3:end),'UniformOutput',false);
            AXIInputPorts=sprintf(char(join(cellStr,'')));
            tpl=replace(tpl,'%IPAXIINPUTS%',AXIInputPorts);

            str=tpl;
        end
    end
end