function ps=getExeProfileReport(h)




    narginchk(1,1);
    linkfoundation.util.errorIfArray(h);

    profInfo=accessPersistentProfileInfo;
    if isempty(profInfo)
        DAStudio.error('ERRORHANDLER:autointerface:MissingProfileInfo');
    end

    if length(fields(profInfo))>1



        option='subsystem';
    else
        option='nowarning';
    end

    ps=profile_execution(h,option);
