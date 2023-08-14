function registerCodegenRelationships(obj)





    import Simulink.ModelReference.common.*;







    if obj.supportsSimTargetMex
        obj.relationshipClasses{end+1}=RelationshipMexForCodegen(obj);
    end


    obj.relationshipClasses{end+1}=RelationshipInfoForCodegen(obj);


    if obj.supportsAccel()

        obj.relationshipClasses{end+1}=RelationshipAccelForCodegen(obj);
        obj.relationshipClasses{end+1}=RelationshipAccelSharedUtilsForCodegen(obj);
    end


    obj.relationshipClasses{end+1}=RelationshipConfigSetCodegen(obj);
    obj.relationshipClasses{end+1}=RelationshipTarget(obj);
    obj.relationshipClasses{end+1}=RelationshipTargetSharedUtils(obj);


    if obj.hasCallbackForFunctionality('CODEGEN')&&obj.addCodegenCallback()
        obj.relationshipClasses{end+1}=RelationshipCodegenCallback(obj);
    end



    if obj.Report
        obj.relationshipClasses{end+1}=RelationshipReportCodegen(obj);
        obj.deferredPopulationRelationshipIndex(end+1)=length(obj.relationshipClasses);

        obj.relationshipClasses{end+1}=RelationshipReportCodegenSummary(obj);
        obj.deferredPopulationRelationshipIndex(end+1)=length(obj.relationshipClasses);

        if~obj.ReportV2


            obj.relationshipClasses{end+1}=RelationshipReportSharedUtils(obj);
            obj.deferredPopulationRelationshipIndex(end+1)=length(obj.relationshipClasses);
        end
    end
end
