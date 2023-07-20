function[result,supportedVer]=isLibraryVersionSupported(libraryName,major,minor)

    result=true;
    supportedVer=[];

    if strcmpi(libraryName,'cudnn')
        requiredMajor=8;
        requiredMinor=1;
        supportedVer=[num2str(requiredMajor),'.',num2str(requiredMinor)];
    elseif strcmpi(libraryName,'tensorrt')
        requiredMajor=7;
        requiredMinor=2;
        supportedVer=[num2str(requiredMajor),'.',num2str(requiredMinor)];
    end

    if major~=requiredMajor||(major==requiredMajor&&minor~=requiredMinor)
        result=false;
    end

end
