classdef MLCExecTime_Report<coder.profile.ExecTime_Report



    methods(Access=protected)

        function element=getAdvisorElement(~)
            element=Advisor.Element;
        end

    end

    methods(Access=public)

        function this=MLCExecTime_Report(htmlFile,lCodeDir)

            initialize(this,htmlFile,lCodeDir);


            helpPath={'toolbox','ecoder','helptargets.map'};
            helpTag='mc_sil_pil_code_execution_profiling';
            setHelpButtonHelpArgs(this,{helpPath,helpTag});
            setIntroTextHelpArgs(this,{helpPath,helpTag});


            this.DisplayIcon=fullfile...
            ('toolbox','shared','dastudio','resources','MatlabIcon.png');

        end
    end
end
