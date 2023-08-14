classdef DataSegmentAnalyzer<handle





    properties(SetAccess=private)
        Design char
        CostEstimate designcostestimation.internal.costestimate.DataSegmentEstimate
    end

    properties
        NeedsBuild=true
    end

    methods

        function obj=DataSegmentAnalyzer(modelName)
            obj.Design=modelName;
            obj.CostEstimate=designcostestimation.internal.costestimate.DataSegmentEstimate(modelName);
        end


        function analyze(obj)


            prevDirty=get_param(obj.Design,'Dirty');
            restoreDirty=onCleanup(@()set_param(obj.Design,'Dirty',prevDirty));
            if(obj.NeedsBuild)
                obj.preProcess();
                obj.buildDesign();
            end
            estimationResult=obj.getDataFromDatabase();
            obj.setInformationOnEstimate(estimationResult);
        end
    end

    methods(Hidden)

        function preProcess(obj)
            Preprocessor=designcostestimation.internal.preprocessing.PreprocessingService(obj.Design);
            Preprocessor.process();
        end



        function[TotalMemoryConsumption,CostTable]=postProcess(~,estimationResult)
            IdentifierInformation=containers.Map;


            postProcess=@(VariableName,Field,StaticLifetime,GlobalVisibility,Size,SourceLocation,IsStruct)...
            designcostestimation.internal.util.postProcessVarsFromDB(VariableName,Field,Size,...
            SourceLocation,IsStruct,IdentifierInformation);
            rowfun(postProcess,estimationResult,'NumOutputs',0);
            IdentifierInformationStructs=cell2mat(values(IdentifierInformation));
            if(isempty(IdentifierInformationStructs))
                CostTable=table;
                TotalMemoryConsumption=0;
                return;
            end
            CostTable=struct2table(IdentifierInformationStructs);
            TotalMemoryConsumption=sum(CostTable.Size);
        end


        function setInformationOnEstimate(obj,estimationResult)
            [TotalMemoryConsumption,CostTable]=obj.postProcess(estimationResult);
            obj.CostEstimate.setCostInformation(TotalMemoryConsumption,CostTable);
            Diagnostics=struct('RawTable',estimationResult);
            obj.CostEstimate.setDiagnostics(Diagnostics);
        end

        function estimationResult=getDataFromDatabase(obj)
            DBservice=designcostestimation.internal.services.DatabaseInterface(obj.Design);
            DBservice.Query='select VariableName,Field,GlobalVisibility,StaticLifetime,Size,ifnull(SourceLocation,''''),IsAStruct from FullVariableReport order by VariableName, Field';
            DBservice.runService();
            if isempty(DBservice.Result)
                estimationResult=table;
                return;
            end
            result=designcostestimation.internal.util.processVarsFromDB(DBservice.Result);
            estimationResult=cell2table(result,'VariableNames',{'Variable Name','Field','Static Lifetime','Global Visibility','Size','Source Location','Is A Struct'});
        end

        function buildDesign(obj)
            Buildservice=designcostestimation.internal.services.Build(obj.Design);
            Buildservice.runService();
        end
    end

end


