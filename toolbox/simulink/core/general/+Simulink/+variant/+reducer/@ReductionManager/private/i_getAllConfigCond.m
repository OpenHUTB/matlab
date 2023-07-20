

function allConfigCond=i_getAllConfigCond(topModelConfigInfo,ctrlVarsUsedInBlk)






























    allConfigCond='';

    try
        for ii=1:length(topModelConfigInfo)
            cvStruct=topModelConfigInfo(ii).AllCtrlVars;


            configCond='';
            for ij=1:length(cvStruct)
                if isempty(Simulink.variant.reducer.utils.searchNameInCell(cvStruct(ij).Name,ctrlVarsUsedInBlk))||...
                    Simulink.variant.utils.getIsSimulinkParamWithSlexprValue(cvStruct(ij).Value)




                    continue;
                end
                cvValue=Simulink.variant.reducer.utils.getCtrlVarValueBasedOnType(cvStruct(ij).Value);
                cvValue=Simulink.variant.reducer.utils.i_num2str(cvValue);
                if isempty(configCond)
                    configCond=['(',cvStruct(ij).Name,' == ',cvValue,')'];


                else
                    configCond=[configCond,' && ','(',cvStruct(ij).Name,' == ',cvValue,')'];%#ok<AGROW> % visited as part of MLINT cleanup
                end
            end

            if isempty(configCond)
                continue;
            end

            if isempty(allConfigCond)
                allConfigCond=['(',configCond,')'];

            else
                allConfigCond=[allConfigCond,' || ','(',configCond,')'];%#ok<AGROW> % visited as part of MLINT cleanup

            end
        end

    catch me %#ok<NASGU>
    end

    allConfigCond=slInternal('SimplifyVarCondExpr',allConfigCond);
end


