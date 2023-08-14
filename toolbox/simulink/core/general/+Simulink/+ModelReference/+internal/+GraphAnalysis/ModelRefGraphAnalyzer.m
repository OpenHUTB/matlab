classdef ModelRefGraphAnalyzer<handle



















































    properties(Access=private)
        MyGraph;
        MyOptions;
        MySelector;
        MyTable;
    end


    methods(Access=public)

        function this=ModelRefGraphAnalyzer()
            this.resetProperties();
        end



        function result=analyze(obj,varargin)
            obj.parseInputAndInitParams(varargin{:});
            obj.analysisEntry();
            result=obj.MySelector.getQueryResult();
        end


        function result=getTable(obj)
            result=obj.MyTable;
        end


        function result=getOptions(obj)
            result=obj.MyOptions;
        end
    end


    methods(Access=private)

        function obj=resetProperties(obj)
            obj.MyGraph=[];
            obj.MyOptions.SimModeChoice=[];
            obj.MyOptions.IncludeTopModel=true;
            obj.MyOptions.ResultView='File';
            obj.MySelector=[];
        end


        function parseInputAndInitParams(obj,varargin)

            p=inputParser;
            p.addRequired('GraphObject',@obj.validateGraphObject);
            p.addRequired('SimModeChoice',@obj.validateSimModeChoice);
            p.addParameter('IncludeTopModel',true,@obj.validateIncludeTopModel);
            p.addParameter('ResultView','File',@obj.validateResultView);
            p.parse(varargin{:});


            obj.MyGraph=p.Results.GraphObject;

            obj.MyOptions.SimModeChoice=lower(p.Results.SimModeChoice);
            factory=Simulink.ModelReference.internal.GraphAnalysis.SimModeSelectorFactory();
            obj.MySelector=factory.makeSelector(obj.MyOptions.SimModeChoice,obj);


            obj.MyOptions.IncludeTopModel=p.Results.IncludeTopModel;
            obj.MyOptions.ResultView=p.Results.ResultView;
        end


        function result=validateGraphObject(~,x)
            if isempty(x)||~isequal(class(x),'Simulink.ModelReference.internal.ModelRefGraph')
                DAStudio.error('Simulink:modelReference:ModelRefGraphAnalyzerInvalidGraphObject');
            end
            result=true;
        end


        function result=validateSimModeChoice(~,x)
            if~ischar(x)||~any(strcmpi(x,{'OnlyNormal','AnyNormal','AnyAccel','OnlyAccel','All'}))
                DAStudio.error('Simulink:modelReference:ModelRefGraphAnalyzerInvalidSimModeChoice');
            end
            result=true;
        end


        function result=validateIncludeTopModel(~,x)
            if~islogical(x)
                DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue','IncludeTopModel');
            end
            result=true;
        end


        function result=validateResultView(~,x)
            if~ischar(x)||~any(strcmpi(x,{'File','Instance'}))
                DAStudio.error('Simulink:modelReference:ModelRefGraphAnalyzerInvalidResultView');
            end
            result=true;
        end




        function analysisEntry(obj)

            obj.MyGraph.createInstanceGraph();


            vertices=obj.MyGraph.getAllInstanceVertexIDs();
            dataStruct=arrayfun(@(x)(obj.MyGraph.getInstanceVertex(x).Data),vertices);
            obj.MyTable=struct2table(dataStruct,'AsArray',true);



            if obj.MyOptions.IncludeTopModel&&obj.isTopModelAccelerated()
                obj.MyTable.Tag=obj.createAccelArray(dataStruct);
            end
        end


        function result=isTopModelAccelerated(obj)
            v=obj.MyGraph.getInstanceVertex(obj.MyGraph.getInstanceTopVertexID());
            result=~strcmpi(v.Data.SimulationMode,'Normal');
        end



        function result=createAccelArray(~,sizeObj)
            row=size(sizeObj,1);
            col=size(sizeObj,2);
            value=Simulink.ModelReference.internal.GraphAnalysis.SimulationMode.Accel;
            result=repmat(value,row,col);
        end

    end
end