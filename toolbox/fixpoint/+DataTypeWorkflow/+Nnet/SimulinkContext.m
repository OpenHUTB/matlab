classdef SimulinkContext<handle







    properties
        SystemUnderDesign=''
        TopModel=''
        EnumWorkflow=DataTypeWorkflow.RangeCollectionMode.Simulation
        NetworkBlock=''
        LibraryInfo=''
    end

    methods
        function this=SimulinkContext(varargin)
            p=createInputParser();
            p.parse(varargin{:});
            this.SystemUnderDesign=p.Results.Model;
            this.initTopModel(p.Results.TopModel);
            this.EnumWorkflow=p.Results.EnumWorkflow;
        end

        function setTopModelFromSUD(this)

            if~isempty(this.SystemUnderDesign)&&isempty(this.TopModel)
                this.TopModel=bdroot(this.SystemUnderDesign);
            end
        end
    end

    methods(Access=private)
        function initTopModel(this,topModel)
            if~isempty(this.SystemUnderDesign)


                this.TopModel=topModel;
            elseif~isempty(topModel)


                warning(message('FixedPointTool:fixedPointTool:MissingSUDForTopModel'));
            end
        end
    end
end

function parser=createInputParser()
    parser=inputParser;

    validModel=@(x)assert((ischar(x)&&isvector(x))||isStringScalar(x),...
    message('FixedPointTool:fixedPointTool:InvalidInputModelName'));

    defaultWorkflow=DataTypeWorkflow.RangeCollectionMode.Simulation;
    validWorkflow=@(x)assert(isa(x,'DataTypeWorkflow.RangeCollectionMode'),...
    message('FixedPointTool:fixedPointTool:InvalidEnumWorkflow'));

    parser.addParameter('Model','',validModel);
    parser.addParameter('TopModel','',validModel);
    parser.addParameter('EnumWorkflow',defaultWorkflow,validWorkflow);
end


