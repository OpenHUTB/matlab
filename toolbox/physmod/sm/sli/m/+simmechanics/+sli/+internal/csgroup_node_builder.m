function groupNode=csgroup_node_builder(fullfileName)













    groupNode=[];



    [fPath,fName,fExt]=fileparts(fullfileName);
    if isempty(fPath)
        fPath=pwd;
    end

    if((strcmp(fExt,'.m'))||(strcmp(fExt,'.p')))&&...
        (~strcmp(fName,'configset'))&&...
        (~strcmp(fName,'postprocess'))


        if strcmp(fullfileName,which(fullfile(fPath,fName)))
            setupFunctionH=pm.util.function_handle(fullfileName);
            groupNode=pm.util.SimpleNode(fullfileName);
            try
                groupNode.Info.SourceFile=fullfileName;



                [groupInfo,cpArray]=feval(setupFunctionH);
                groupNode.Info.Name=groupInfo.Name;
                groupNode.Info.Description=groupInfo.Description;
                groupNode.Info.Parameters=cpArray;
                if isfield(groupInfo,'Annotation')
                    groupNode.Info.Annotation=groupInfo.Annotation;
                end
            catch excp
                pm_error('mech2:local:cpgrpnodebuilder:InvalidGrpSpecFile',fullfileName,excp.message);
            end
        end
    end

end

