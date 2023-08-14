function install(fileName)

    cssFilePath=which([fileName,'.css']);

    if isempty(cssFilePath)
        error(['Cannot find profile''s stylesheet ''',fileName,'.css'' on the MATLAB path.']);
    end

    [success,msg]=copyfile(cssFilePath,fullfile(matlabroot,'toolbox','sysarch','editor','web','sysarch','plugins'));

    if~success
        error('Could not install profile. Error: %s\n',msg);
    else
        fprintf('Successfully installed profile: %s\n',fileName);
    end

end

