function PILBlock(obj)





    if isR2010aOrEarlier(obj.ver)























        model=obj.modelName;

        csNames=getConfigSets(model);
        for nameIdx=1:length(csNames)
            csName=csNames{nameIdx};
            cs=getConfigSet(model,csName);

            taskingPIL=false;
            linkTSParam='TaskingBuildAction';
            if cs.isValidParam(linkTSParam)

                if strcmp(get_param(cs,'CreateSILPILBlock'),'PIL')
                    taskingPIL=true;
                end
            end

            linkSharedParam='buildAction';
            linkSharedParamVal='Create_Processor_In_the_Loop_project';
            sharedLinkPIL=false;
            if cs.isValidParam(linkSharedParam)
                if strcmp(get_param(cs,linkSharedParam),linkSharedParamVal)
                    sharedLinkPIL=true;
                end
            end
            if isR2008aOrEarlier(obj.ver)



                if taskingPIL





                    obj.reportWarning('Simulink:ExportPrevious:PILBlockNotCreated',csName);
                end
                if sharedLinkPIL









                    obj.reportWarning('Simulink:ExportPrevious:PILBlockCompatibility',csName);
                end
            else
                if taskingPIL||sharedLinkPIL

                    obj.reportWarning('Simulink:ExportPrevious:PILBlockNotCreated',csName);
                end
            end
        end
    end


