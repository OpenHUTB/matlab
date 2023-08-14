function upgrade(hObj)




    if hObj.versionCompare("21.1.0")<0




        enableParamTuning=hObj.get_param('DVParameters');
        enableParamTable=hObj.get_param('DVParametersUseConfig');
        if strcmp(enableParamTuning,'on')
            if strcmp(enableParamTable,'on')
                hObj.set_param('DVParameterConfiguration','UseParameterTable');
            else
                hObj.set_param('DVParameterConfiguration','UseParameterConfigFile');
            end
        end
    end
end
