function fixModelWorkspace(obj,mdlRefItem)




    if isempty(mdlRefItem.Up)
        topModelH=get_param(mdlRefItem.ReplacementInfo.AfterReplacementH,'Handle');
        topModelWS=get_param(topModelH,'ModelWorkspace');

        dataSource=topModelWS.DataSource;
        if ismember(dataSource,{'MAT-File','MATLAB File','MATLAB Code'})

            topModelWS.reload;
            topModelWS.DataSource='Model File';
        end
    else
        inlineModelWS=get_param(obj.MdlInfo.ModelH,'ModelWorkspace');
        for idx=1:length(mdlRefItem.ReferencedModelWSVarsToMove)
            varToMove=mdlRefItem.ReferencedModelWSVarsToMove(idx);
            varvalue=varToMove.Value;
            inlineModelWS.assignin(varToMove.Name,varvalue);
        end

        if~isempty(mdlRefItem.BaseOrModelWSCarrSSMaskVars)
            varsToCarryStruct=mdlRefItem.BaseOrModelWSCarrSSMaskVars;
            newVarsToCarryStruct=[];

            varNames=fieldnames(varsToCarryStruct);
            for idx=1:length(varNames)
                inlinedWSVarName=sprintf('carriedVarFromRefMdlDV_%d_%s',obj.incAndGetMwsVarId,varNames{idx});
                varvalue=varsToCarryStruct.(varNames{idx}).Value;
                inlineModelWS.assignin(inlinedWSVarName,varvalue);
                newVarsToCarryStruct.(varNames{idx})=inlinedWSVarName;
            end

            mdlRefItem.BaseOrModelWSCarrSSMaskVars=newVarsToCarryStruct;
        end
    end
end
