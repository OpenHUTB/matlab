classdef(Hidden)ip_sv_interface<uvmcodegen.sv_interface

    properties(Access=private)
        hUVMGenerator;
    end

    methods

        function this=ip_sv_interface(h,varargin)
            this=this@uvmcodegen.sv_interface(varargin{:});
            this.hUVMGenerator=h;
        end

        function str=get_sv_ifnam_fileLoc(obj)
            str=replace(fullfile(obj.ucfg.component_paths('uvm_artifacts'),['mw_DUT_AXIRTL_if','.sv']),'\','/');
        end

        function str=prtsvinf(this)
            dpigenerator_disp(['Generating IP Core UVM interface ',dpigenerator_getfilelink(this.get_sv_ifnam_fileLoc())]);

            fid=fopen(this.svinf_tmplt,'rt');
            tpl=fscanf(fid,'%c');
            fclose(fid);

            tpl=replace(tpl,'%MW_INFO%','');
            tpl=replace(tpl,'%IMPORT_COMMON_TYPES_PKG%','`timescale 1ns/1ns');
            tpl=replace(tpl,'%INFNAME%',[this.ucfg.prefix,this.mwcfg.sldut_name,'AXIRTL',this.ucfg.inf_suffix]);


            tpl=replace(tpl,'%IPCLOCKNAME%',this.hUVMGenerator.hIPCoreGenIOPortList.InputPortNameList{1});
            tpl=replace(tpl,'%IPRESETNAME%',this.hUVMGenerator.hIPCoreGenIOPortList.InputPortNameList{2});


            cellStr=cellfun(@(x)n_iodeclarations(x),this.hUVMGenerator.hIPCoreGenIOPortList.InputPortNameList(3:end),'UniformOutput',false);
            AXIInputPorts=sprintf(char(join(cellStr,'')));
            tpl=replace(tpl,'%IPAXIINPUTS%',AXIInputPorts);


            cellStr=cellfun(@(x)n_iodeclarations(x),this.hUVMGenerator.hIPCoreGenIOPortList.OutputPortNameList(:),'UniformOutput',false);
            AXIOutputPorts=sprintf(char(join(cellStr,'')));
            tpl=replace(tpl,'%IPAXIOUTPUTS%',AXIOutputPorts);


            tpl=replace(tpl,'%SEQOPORTS%','');

            function n_str=n_iodeclarations(x)
                wLength=this.hUVMGenerator.hIPCoreGenIOPortList.IOPortMap(x).WordLength;
                if(wLength==1)
                    n_str=sprintf('\t%s  %s;\n','logic',x);
                else
                    n_str=sprintf('\t%s  [%s:0]  %s;\n','logic',num2str(wLength-1),x);
                end
            end

            str=tpl;
        end
    end
end