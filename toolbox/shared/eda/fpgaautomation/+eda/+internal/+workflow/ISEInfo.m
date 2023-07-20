classdef ISEInfo<eda.internal.workflow.FPGAToolInfo




    properties(SetAccess=protected)
        FPGAToolName='ISE';
        FPGAToolCmd='ise';
        FPGAToolTclShell='xtclsh';
FPGAToolProcess

        ProjectFileExt='.xise';
        ProgrammingFileExt='.bit';
        NetlistType={'Netlist'};
        TclScriptType={'Tcl script'};
        OldProjectFileExt='.ise';

        FPGABuildProcess={{'compile','"Check Syntax"'},...
        {'synthesize','"Synthesize - XST"'},...
        {'translate','"Translate"'},...
        {'map','"Map"'},...
        {'par','"Place & Route"'},...
        {'implement','"Implement Design"'},...
        {'generateBit','"Generate Programming File"'}};

    end

    methods

        function h=ISEInfo
            if ispc
                h.FPGAToolProcess={'ise.exe','xtclsh.exe'};
            else
                h.FPGAToolProcess={'_pn'};
            end
        end
    end

    methods(Static)
        function checkFPGATool
            [stat,~]=system('xtclsh -h');
            if(stat~=0)
                error(message('EDALink:FPGAProjectManager:XilinxISENotFound'));
            end
        end
    end

end

