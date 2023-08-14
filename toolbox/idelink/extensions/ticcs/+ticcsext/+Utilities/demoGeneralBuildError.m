function errmsg=demoGeneralBuildError(cc,demopjt,buildException)




    if~isempty(findstr(buildException.message,'Build complete:'))
        errmsg=ticcsext.Utilities.demoBuildError(cc,buildException.message,demopjt);
    end

