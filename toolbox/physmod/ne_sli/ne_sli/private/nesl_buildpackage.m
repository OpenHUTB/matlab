function nesl_buildpackage(pkg,mdlName,outputDir,depErrFlag)












    if nargin<4
        depErrFlag=false;
    end

    nesl_makelibrary_tool(pkg,mdlName,outputDir,depErrFlag);

end
