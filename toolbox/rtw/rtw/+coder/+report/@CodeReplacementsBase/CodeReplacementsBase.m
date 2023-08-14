classdef CodeReplacementsBase<coder.report.ReportPageBase





    properties(Access=protected,Transient)
        TargetRegistry={}
    end

    properties(Access=protected)
        LibName=''
        InstructionSetExtensions={}
        TableNames={}
        HitCache={}
        TableInfo={}
    end

    methods
        function obj=CodeReplacementsBase(aTfl)
            obj=obj@coder.report.ReportPageBase;
            if~isempty(aTfl)
                obj.LibName=aTfl.LoadedLibrary;
                aHitCache=aTfl.HitCache;
                obj.InstructionSetExtensions=aTfl.InstructionSets;
                for idx=1:length(aHitCache)
                    if isprop(aHitCache(idx),'Implementation')&&~isempty(aHitCache(idx).Implementation)
                        aEntry.Key=aHitCache(idx).Key;
                        aEntry.ImplementationName=aHitCache(idx).Implementation.Name;
                        aEntry.HitSourceLocations=aHitCache(idx).TraceManager.HitSourceLocations;
                        obj.HitCache{end+1}=aEntry;
                    elseif isprop(aHitCache(idx),'ImplementationVector')&&~isempty(aHitCache(idx).ImplementationVector)
                        aEntry.Key=aHitCache(idx).Key;
                        nameList={aHitCache(idx).ImplementationVector{end}.Name};
                        nameList=[strcat(nameList(1:end-1),'<br>'),nameList(end)];
                        aName=cell2mat(nameList);
                        aEntry.ImplementationName=aName;
                        aEntry.HitSourceLocations=aHitCache(idx).TraceManager.HitSourceLocations;
                        obj.HitCache{end+1}=aEntry;
                    end
                end
                for idx=1:length(aTfl.TflTables)
                    obj.TableInfo(idx).Name=aTfl.TflTables(idx).Name;
                    obj.TableInfo(idx).Inhouse=aTfl.TflTables(idx).Inhouse;
                end
            end
        end
    end

    methods(Access=protected)
        addCodeReplacementSection(obj)
        addRptgenCodeReplacementSection(obj,chapter)
        addedContent=addFunctionReplacementSection(obj)
        sectionId=addRptgenFunctionReplacementSection(obj,chapter,sectionId)
        addedContent=addOperatorReplacementSection(obj,op,titleMsgId,introMsg)
        sectionId=addRptgenOperatorReplacementSection(obj,op,titleMsgId,introMsg,chapter,sectionId)
        addedContent=addSimdReplacementSection(obj)
        sectionId=addRptgenSimdReplacementSection(obj,chapter,sectionId)
        [usedFcns,mergeIdxs]=getUsedFunctions(obj,op)
        htmlStr=getSourcelocationFromSID(obj,sid)
        [tflList,tflName]=getLibraryContents(obj)
        [tflList,tflName]=getRpggenLibraryContents(obj)
        tflList=addLibraryContentsToList(obj,aLibrary,tflList)
        tflList=addRptgenLibraryContentsToList(obj,aLibrary,tflList)
        instructionSetString=getInstructionSetString(obj)
        contents=createRepTable(obj,usedFcns,mergeIdxs)
        table=createRptgenRepTable(obj,usedFcns,mergeIdxs)
    end

    methods(Static)
        isDesired=isDesiredOp(key,desiredOp)
    end
end


