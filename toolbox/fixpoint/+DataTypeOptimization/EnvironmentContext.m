classdef EnvironmentContext<handle






    properties(SetAccess=private)
TopModel
SUD
AllModels
AllModelsUnderSUD
    end

    methods
        function this=EnvironmentContext(model,sud)
            model=convertStringsToChars(model);
            sud=convertStringsToChars(sud);
            DataTypeOptimization.load_system(model);
            blockPath=Simulink.BlockPath(sud);
            sud=blockPath.convertToCell{1};


            this.TopModel=model;
            this.SUD=Simulink.SimulationData.BlockPath.manglePath(sud);
            this.AllModels=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(model);
            this.validateModel();
        end

        function models=get.AllModelsUnderSUD(this)
            models=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(this.SUD);
            models{end}=this.SUD;
        end
    end

    methods(Hidden,Static)
        function this=loadobj(st)
            this=DataTypeOptimization.EnvironmentContext(st.model,st.sud);
        end
    end

    methods(Hidden)
        function st=saveobj(this)
            st=struct('model',this.TopModel,'sud',this.SUD);
        end

        function validateModel(this)
            validateSimTime(this);
            validateSUDHierarchy(this);
        end

        function validateSimTime(this)

            assert(~strcmpi(get_param(this.TopModel,'StopTime'),'Inf'),...
            message('SimulinkFixedPoint:dataTypeOptimization:infSimulationTime',this.TopModel));
        end

        function validateSUDHierarchy(this)
            assert(contains(this.SUD,this.AllModels),...
            message('SimulinkFixedPoint:autoscaling:sudNotUnderTop',this.TopModel,this.SUD));

            if~isequal(this.SUD,this.TopModel)&&...
                ~isequal(this.SUD,Simulink.ID.getSID(this.SUD))
                assert(fxptopo.internal.areBlocksUnderSUD(this.SUD,this.TopModel),...
                message('SimulinkFixedPoint:autoscaling:sudNotUnderTop',this.TopModel,this.SUD));
            end
        end
    end
end

