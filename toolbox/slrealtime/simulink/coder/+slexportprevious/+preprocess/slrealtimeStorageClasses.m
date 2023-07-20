function slrealtimeStorageClasses(obj)






    ver_obj=obj.ver;

    if isR2021aOrEarlier(ver_obj)


        h=get_param(obj.modelName,'handle');
        mappingObj=Simulink.CodeMapping.get(h,'SimulinkCoderCTarget');




        if~isempty(mappingObj)
            mapping=coder.mapping.api.get(h,'SimulinkCoderC');
            defaultStorageClassForExternalParameters=...
            mapping.getDataDefault('ExternalParameters','StorageClass');


            if strcmp(defaultStorageClassForExternalParameters,'PageSwitching (slrealtime)')
                mapping.setDataDefault('ExternalParameters',...
                'StorageClass','Default');
            end
        end
    end