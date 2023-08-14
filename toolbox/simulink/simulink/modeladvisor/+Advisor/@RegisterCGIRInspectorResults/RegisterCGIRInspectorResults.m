classdef(Sealed=true)RegisterCGIRInspectorResults<Advisor.BaseRegisterCGIRInspectorResults
















    properties(Access='protected')
        accelMdlrefs=[];
    end

    methods(Access='public')
        function clearResults(obj)
            clearResults@Advisor.BaseRegisterCGIRInspectorResults(obj);
            obj.accelMdlrefs=[];
        end
    end


    methods(Static=true)








        function singleObj=getInstance()
            persistent localStaticObj;
            if isempty(localStaticObj)||~isvalid(localStaticObj)
                localStaticObj=Advisor.RegisterCGIRInspectorResults;
            end
            singleObj=localStaticObj;
        end


        function accelMdlrefs=modelReferenceInfo(sys)
            obj=Advisor.RegisterCGIRInspectorResults.getInstance;


            if iscell(obj.accelMdlrefs)
                accelMdlrefs=obj.accelMdlrefs;
            else
                if Simulink.internal.useFindSystemVariantsMatchFilter()
                    [~,~,aGraph]=find_mdlrefs(sys,...
                    'AllLevels',true,...
                    'LookUnderMasks','all',...
                    'FollowLinks','on',...
                    'IncludeProtectedModels',true,...
                    'MatchFilter',@Simulink.match.codeCompileVariants,...
                    'IncludeCommented','off');
                else
                    [~,~,aGraph]=find_mdlrefs(sys,...
                    'AllLevels',true,...
                    'LookUnderMasks','all',...
                    'FollowLinks','on',...
                    'IncludeProtectedModels',true,...
                    'Variants','ActivePlusCodeVariants',...
                    'IncludeCommented','off');
                end
                analyzer=Simulink.ModelReference.internal.GraphAnalysis.ModelRefGraphAnalyzer;
                result=analyzer.analyze(aGraph,'OnlyAccel','IncludeTopModel',false);
                accelMdlrefs={};
                if~isempty(result)
                    accelMdlrefs=result.RefModel;
                end
                obj.accelMdlrefs=accelMdlrefs;
            end
        end

    end

end
