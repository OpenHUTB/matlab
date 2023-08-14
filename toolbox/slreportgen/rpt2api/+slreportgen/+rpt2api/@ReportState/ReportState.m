classdef ReportState<mlreportgen.rpt2api.ReportState

































    properties




        CurrentModelHandle=[];





        CurrentModelOptions=[];






        CurrentModelReportedSystems=[];






        CurrentSystem=[];






        CurrentChart=[];






        CurrentBlock=[];






        CurrentSignal=[];






        CurrentAnnotation=[];






        CurrentModelVariable=[];






        CurrentStateflowObject=[];






        CurrentState=[];


        PreRunCurrentSystem=[];


        PreRunOpenModels=[];
    end

    methods
        function obj=ReportState()


            obj=obj@mlreportgen.rpt2api.ReportState();


            obj.PreRunCurrentSystem=get_param(0,'CurrentSystem');



            obj.PreRunOpenModels=find_system(0,"SearchDepth",1,"type","block_diagram");
        end

        function cleanup(this)



            cleanup@mlreportgen.rpt2api.ReportState(this);


            if~isempty(this.PreRunCurrentSystem)
                set_param(0,'CurrentSystem',this.PreRunCurrentSystem);
            end


            okModels=this.PreRunOpenModels;

            if any(isnan(okModels))
                okModels=[];
            end

            allModels=find_system(0,...
            'SearchDepth',1,...
            'type','block_diagram');

            badModels=setdiff(allModels,okModels);

            lenBadModels=length(badModels);
            for i=1:lenBadModels
                try
                    bdclose(badModels(i));
                catch ME %#ok
                end
            end
        end
    end
end

