
function dpigenerator_getFlattenedSignalsMap(genSV,MapToBeInitialized,portInfo,DataFileNameMapTobeInitialized,Direction,IsMATLABBased)

    persistent data_file_num;
    if isempty(data_file_num)
        data_file_num=1;
    end

    if~isempty(portInfo.StructInfo)&&~IsMATLABBased



        for idx=1:length(portInfo.StructInfo)
            dpigenerator_getFlattenedSignalsMap(genSV,MapToBeInitialized,portInfo.StructInfo(num2str(idx)),DataFileNameMapTobeInitialized,Direction,IsMATLABBased)
        end
    else



        if~strcmp(Direction,'TestPoint')
            uniqueVarName=genSV.getUniqueName(portInfo.FlatName);
        else
            uniqueVarName=portInfo.FlatName;
        end


        MapToBeInitialized(uniqueVarName)=portInfo;%#ok<NASGU>





        if strcmp(Direction,'Input')
            DataFileNameMapTobeInitialized(uniqueVarName)=['dpig_in',num2str(data_file_num),'.dat'];%#ok<NASGU>
        elseif strcmp(Direction,'Output')
            DataFileNameMapTobeInitialized(uniqueVarName)=['dpig_out',num2str(data_file_num),'.dat'];%#ok<NASGU>
        else
            DataFileNameMapTobeInitialized(uniqueVarName)=[uniqueVarName,'.dat'];%#ok<NASGU>
        end

        data_file_num=data_file_num+1;
    end
end