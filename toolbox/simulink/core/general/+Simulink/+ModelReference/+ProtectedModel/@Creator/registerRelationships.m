function registerRelationships(obj)






    import Simulink.ModelReference.common.*;

    if~obj.webviewOnly()


        if obj.supportsSimTargetMex()
            obj.relationshipClasses{end+1}=RelationshipMex(obj);
        end



        obj.relationshipClasses{end+1}=RelationshipConfigSet(obj);


        obj.relationshipClasses{end+1}=RelationshipVariableChecksum(obj);



        if obj.supportsAccel()

            obj.relationshipClasses{end+1}=RelationshipAccel(obj);
            obj.relationshipClasses{end+1}=RelationshipAccelSharedUtils(obj);
        end


        if obj.Report
            obj.relationshipClasses{end+1}=RelationshipReport(obj);
            obj.relationshipClasses{end+1}=RelationshipReportSummary(obj);
        end


        if obj.hasCallbackForFunctionality('SIM')
            obj.relationshipClasses{end+1}=RelationshipSimCallback(obj);
        end


        if obj.supportsCodeGen()&&obj.getSupportsC()
            obj.registerCodegenRelationships();
        end


        if obj.supportsCodeGen()&&obj.getSupportsHDL()
            obj.relationshipClasses{end+1}=RelationshipHDL(obj);
        end
    end
    if Simulink.ModelReference.ProtectedModel.isWebviewFeatureEnabled(obj.ReportGenLicense)
        if obj.Webview
            obj.relationshipClasses{end+1}=RelationshipProtectedModelWebview(obj);
            if obj.isThumbnailEnabled
                obj.relationshipClasses{end+1}=RelationshipProtectedModelThumbnail(obj);
            end

            if obj.hasCallbackForFunctionality('VIEW')
                obj.relationshipClasses{end+1}=RelationshipViewCallback(obj);
            end
        end



        if obj.webviewOnly()&&obj.Report
            obj.throwWarning('Simulink:protectedModel:ProtectedModelDisableReportForViewOnly',obj.ModelName,obj.ModelName);
            obj.Report=false;
        end
    end


    if obj.HasSystemComposerInfo
        obj.relationshipClasses{end+1}=RelationshipSystemComposerArchitecture(obj);
    end


    if obj.isModifyEncrypted()
        obj.relationshipClasses{end+1}=RelationshipModifyPermission(obj);
    end





    obj.relationshipClasses{end+1}=RelationshipInformation(obj);

end


