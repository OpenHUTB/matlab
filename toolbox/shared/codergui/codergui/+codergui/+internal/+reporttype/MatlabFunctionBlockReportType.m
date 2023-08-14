classdef(Sealed)MatlabFunctionBlockReportType<codergui.ReportType




    properties(Constant)
        ClientTypeValue='stateflow'
        FileCategory='MATLAB_Function_Report'
    end

    methods
        function this=MatlabFunctionBlockReportType()
            this.MapFilePath=fullfile('simulink','helptargets.map');
            this.AppendFilePathToTitle=false;
            this.Priority=2;
            this.BaseProducts='simulink';
        end

        function matched=isType(~,reportContext)
            matched=reportContext.IsStateflow;
        end

        function title=getWindowTitle(this,manifest)
            blockName=this.manifestToBlockName(manifest);
            title=message('coderWeb:matlab:browserTitleMatlabBlock',blockName).getString();
        end
    end

    methods(Static,Hidden)
        function name=manifestToBlockName(manifest)
            name='';
            if manifest.hasProperty(codergui.ReportServices.SIMULINK_SID_PROPERTY)
                sid=manifest.getProperty(codergui.ReportServices.SIMULINK_SID_PROPERTY);
                if~isempty(sid)
                    try
                        name=get_param(sid,'Name');
                    catch
                        name=sid;
                    end
                end
            end
        end
    end
end