function modelOwnedDictionaryFile(obj)




    if~isR2013bOrEarlier(obj.ver)

        return;
    end

    MODDName=get_param(obj.modelName,'ModelOwnedDictionaryFile');
    if isempty(MODDName)

        return;
    end


    obj.reportWarning('Simulink:ExportPrevious:ModelOwnedDataDictionaryRemoved',...
    obj.modelName,MODDName,obj.ver.release);


    set_param(obj.modelName,'ModelOwnedDictionaryFile','');

end
