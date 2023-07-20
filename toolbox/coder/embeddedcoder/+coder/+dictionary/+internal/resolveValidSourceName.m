function sourceName=resolveValidSourceName(sourceName)



    slRoot=slroot;
    sourceName=convertStringsToChars(sourceName);
    sourceName=coder.dictionary.internal.convertFileNameToModelName(sourceName);

    if slRoot.isValidSlObject(sourceName)
        sourceName=get_param(sourceName,'Handle');
    end
    if ischar(sourceName)
        return;
    elseif isa(sourceName,'Simulink.data.Dictionary')
        [~,fname,fext]=fileparts(sourceName.filepath());
        sourceName=[fname,fext];
    end

end