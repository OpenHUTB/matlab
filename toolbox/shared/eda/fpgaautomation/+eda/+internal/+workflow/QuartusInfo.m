classdef QuartusInfo<eda.internal.workflow.FPGAToolInfo




    properties(SetAccess=protected)
        FPGAToolName='Quartus II';
        FPGAToolCmd='quartus';
        FPGAToolTclShell='quartus_sh -t';
FPGAToolProcess

        ProjectFileExt='.qpf';
        ProgrammingFileExt='.sof';
        NetlistType={'EDIF netlist','VQM netlist','HEX file'};
        TclScriptType={'QSF file','Tcl script'};
        FPGABuildProcess={...
        {'compile','execute_flow -analysis_and_elaboration'},...
        {'map','execute_module -tool map'},...
        {'fit','execute_module -tool fit'},...
        {'sta','execute_module -tool sta'},...
        {'asm','execute_module -tool asm'},...
        {'bitgen','execute_flow -compile'}};
    end

    methods

        function h=QuartusInfo
            if ispc
                h.FPGAToolProcess={'quartus.exe','quartus_sh.exe'};
            else
                h.FPGAToolProcess={'quartus','quartus_sh'};
            end
        end
    end

    methods(Static)
        function checkFPGATool(checkVersion)


            if nargin==0
                checkVersion=false;
            end
            [stat,result]=system('quartus_sh -v');
            if(stat~=0)
                error(message('EDALink:FPGAProjectManager:AlteraQuartusIINotFound'));
            end
            if checkVersion
                expectedVersion='20.1';
                r=strfind(result,expectedVersion);
                if isempty(r)
                    warning(message('EDALink:FPGAProjectManager:UnsupportedQuartusVersion',expectedVersion));
                end
            end
        end
    end


end

