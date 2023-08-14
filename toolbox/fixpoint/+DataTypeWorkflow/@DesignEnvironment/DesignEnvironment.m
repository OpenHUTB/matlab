classdef DesignEnvironment<handle




    properties(SetAccess=protected)

        TopModel='';


        SelectedSystemToScale='';
    end

    properties(SetAccess=protected,Hidden)

        AllSystems={};


        MdlRefGraph=[];

    end


    methods
        function env=DesignEnvironment()

        end
    end


    methods
        function set.SelectedSystemToScale(env,selectedSystemToScale)
            selectedSystemToScale=convertStringsToChars(selectedSystemToScale);



            env.assertModelLoaded(strtok(selectedSystemToScale,'/'));


            mdlObj=get_param(selectedSystemToScale,'object');
            if~isa(mdlObj,'Simulink.BlockDiagram')&&~isa(mdlObj,'Simulink.SubSystem')
                error(message('SimulinkFixedPoint:autoscaling:invalidSystemToScale'));
            end


            env.SelectedSystemToScale=selectedSystemToScale;
        end

        function set.TopModel(this,topModel)
            topModel=convertStringsToChars(topModel);


            this.assertModelLoaded(strtok(topModel,'/'));


            mdlObj=get_param(topModel,'object');
            if~isa(mdlObj,'Simulink.BlockDiagram')||strcmpi(get_param(topModel,'SimulinkSubdomain'),'Architecture')
                error(message('SimulinkFixedPoint:autoscaling:invalidTopModel'));
            end


            this.TopModel=topModel;
        end
    end

    methods(Access=public,Hidden)


        function setup(this,systemToScale,varargin)


            if~hasFixedPointDesigner()
                DAStudio.error('SimulinkFixedPoint:autoscaling:licenseCheck');
            end

            p=inputParser();


            verificationFunction=@(x)validateattributes(x,{'char','string'},{'nonempty','row'});


            p.addRequired('SystemUnderDesign',verificationFunction);


            p.addParameter('TopModel','',verificationFunction);


            p.parse(systemToScale,varargin{:});


            systemToScale=p.Results.SystemUnderDesign;

            topModelName=p.Results.TopModel;


            this.SelectedSystemToScale=systemToScale;


            if isempty(topModelName)
                this.TopModel=bdroot(systemToScale);
            else
                this.TopModel=topModelName;
            end


            this.loadSystems();



            this.assertModelHierarchy();

        end

        function loadSystems(this)
            this.assertModelLoaded(this.TopModel);

            [this.AllSystems,~,this.MdlRefGraph]=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(this.TopModel);


            load_system(this.AllSystems);
        end

        function assertDEValid(this)
            assert(isvalid(this),message('SimulinkFixedPoint:autoscaling:invalidCLIHandle'));
        end

        function assertModelLoaded(~,modelName)
            assert(bdIsLoaded(modelName),message('SimulinkFixedPoint:autoscaling:ModelNotLoaded',modelName));
        end

        function assertModelHierarchy(this)
            assert(contains(this.SelectedSystemToScale,this.AllSystems),...
            message('SimulinkFixedPoint:autoscaling:sudNotUnderTop',this.TopModel,this.SelectedSystemToScale));
        end

        function assertModelUnlocked(~,modelName)
            lockStatus=get_param(modelName,'Lock');
            assert(strcmp(lockStatus,'off'),message('FixedPointTool:fixedPointTool:errorModelLocked'));
        end
    end
end
