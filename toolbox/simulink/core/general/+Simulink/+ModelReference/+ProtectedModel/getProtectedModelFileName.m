function protectedModelFileName=getProtectedModelFileName(protectedModelFileName)



    protectedExtension='.slxp';
    [~,~,ext]=fileparts(protectedModelFileName);
    if isempty(ext)
        protectedModelFileName=[protectedModelFileName,protectedExtension];
    end

end

