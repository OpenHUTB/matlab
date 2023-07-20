function[isMathWorksLib,isUnregistered,isFullySupported]=getInternalLibraryBlockInfo(slbh,impl)












    isMathWorksLib=false;
    isUnregistered=false;
    isFullySupported=true;



    libBlockPath=get_param(slbh,'ReferenceBlock');

    if(isempty(libBlockPath))
        libBlockPath=get_param(slbh,'AncestorBlock');
    end


    if(~isempty(libBlockPath))


        libName=strtok(libBlockPath,'/');

        libPath=which(libName);


        if(any(startsWith(libPath,fullfile(matlabroot,'toolbox'))))
            isMathWorksLib=true;
        end
    end

    if isMathWorksLib

        if nargin<2
























            impl=0;
        end



        isUnregistered=isempty(impl);



        supportedLibs=slhdlcoder.HDLImplDatabase.getFullySupportedLibraries();
        isFullySupported=any(strcmp(libName,supportedLibs));
    end
end

