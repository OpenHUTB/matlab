function setbuildopt(h,tool,opt)



















    narginchk(3,3);
    linkfoundation.util.errorIfArray(h);

    [dummy1,dummy2,ext]=fileparts(tool);
    if isempty(ext)
        h.mIdeModule.SetProjBuildOption(tool,opt);
    else
        h.mIdeModule.SetFileBuildOption(tool,opt);
    end


