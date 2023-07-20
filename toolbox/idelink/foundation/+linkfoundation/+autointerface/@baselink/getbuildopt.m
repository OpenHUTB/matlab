function opts=getbuildopt(h,file)



















    narginchk(1,2);
    linkfoundation.util.errorIfArray(h);


    if(nargin==2)&&~ischar(file),
        DAStudio.error('ERRORHANDLER:autointerface:InvalidNonCharFilename');
    end

    if nargin==2,
        validBuildOption=ide_getBuildOptionNames(h);
        if any(strcmpi(file,validBuildOption))

            buildtool=file;
            opts=h.mIdeModule.GetSpecificProjBuildOption(buildtool);
        else

            opts=h.mIdeModule.GetFileBuildOption(file);
        end
    else

        opts=h.mIdeModule.GetProjBuildOption;
    end


