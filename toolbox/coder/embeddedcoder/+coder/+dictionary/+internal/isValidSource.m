function out=isValidSource(sourceName)




    slRoot=slroot;
    sourceName=coder.dictionary.internal.convertFileNameToModelName(sourceName);
    if slRoot.isValidSlObject(sourceName)
        out=true;
    else
        if isa(sourceName,'Simulink.data.Dictionary')
            sourceName=sourceName.filepath;
        end
        if~(ischar(sourceName)||(isstring(sourceName)&&isscalar(sourceName)))||...
            isempty(sourceName)
            DAStudio.error('coderdictionary:api:InvalidPropertyValueType');
        end
        resolvedSrc=which(sourceName);

        if~isempty(resolvedSrc)
            [~,~,fileext]=fileparts(resolvedSrc);
            if strcmp(fileext,'.sldd')
                if sl.interface.dict.api.isInterfaceDictionary(resolvedSrc)
                    DAStudio.error('interface_dictionary:workflows:coderDictionaryNotSupported',sourceName);
                else
                    out=true;
                end
            else
                DAStudio.error('SimulinkCoderApp:data:InvalidSourceName',sourceName);
            end
        else

            try
                dd=Simulink.data.dictionary.open(sourceName);
                if~isempty(dd)&&isa(dd,'Simulink.data.Dictionary')
                    if sl.interface.dict.api.isInterfaceDictionary(dd.filepath)
                        DAStudio.error('interface_dictionary:workflows:coderDictionaryNotSupported',sourceName);
                    else
                        out=true;
                    end
                end
            catch
                DAStudio.error('SimulinkCoderApp:data:InvalidSourceName',sourceName);
            end
        end
    end
end


