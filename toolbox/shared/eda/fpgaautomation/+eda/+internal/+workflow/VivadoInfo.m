classdef VivadoInfo<eda.internal.workflow.FPGAToolInfo




    properties(SetAccess=protected)
        FPGAToolName='Vivado';
        FPGAToolCmd='vivado';
        FPGAToolTclShell='vivado -mode batch -source';
FPGAToolProcess

        ProjectFileExt='.xpr';
        ProgrammingFileExt='.bit';
        NetlistType={'Netlist'};
        TclScriptType={'Tcl script'};

        FPGABuildProcess={{'compile','"Check Syntax"'},...
        {'synthesize','"Synthesize - XST"'},...
        {'translate','"Translate"'},...
        {'map','"Map"'},...
        {'par','"Place & Route"'},...
        {'implement','"Implement Design"'},...
        {'generateBit','"Generate Programming File"'}};

    end

    methods

        function h=VivadoInfo
            if ispc
                h.FPGAToolProcess={'ise.exe','xtclsh.exe'};
            else
                h.FPGAToolProcess={'_pn'};
            end
        end
    end

    methods(Static)
        function checkFPGATool(checkVersion)


            if nargin==0
                checkVersion=false;
            end
            [stat,result]=system('vivado -version');
            if(stat~=0)
                error(message('EDALink:FPGAProjectManager:XilinxVivadoNotFound'));
            end
            if checkVersion
                expectedVersion='2020.2';
                r=strfind(result,expectedVersion);
                if isempty(r)
                    warning(message('EDALink:FPGAProjectManager:UnsupportedVivadoVersion',expectedVersion));
                end
            end
        end
    end

end

