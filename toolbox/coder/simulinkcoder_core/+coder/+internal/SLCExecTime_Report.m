classdef SLCExecTime_Report<coder.profile.ExecTime_Report



    methods(Access=protected)

        function element=getAdvisorElement(~)
            element=ModelAdvisor.Element;
        end

    end


    methods(Access=public)

        function this=SLCExecTime_Report(htmlFile,lCodeDir)

            initialize(this,htmlFile,lCodeDir);


            helpPath={'toolbox','ecoder','helptargets.map'};
            helpTag='sil_pil_code_exe_profile';
            setHelpButtonHelpArgs(this,{helpPath,helpTag});
            setIntroTextHelpArgs(this,{helpPath,helpTag});
        end
    end
end
