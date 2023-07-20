function rmitmnavigate(fPath,locationId,opt)




    if nargin==3&&strcmp(opt,'_suppress_browser')
        suppress_browser=true;
    else
        suppress_browser=false;
    end

    rmitm.navigate(fPath,locationId);

    if suppress_browser&&ispc
        reqmgt('winClose','(?:localhost|127\.0\.0\.1):\d+\/matlab\/feval/rmitmnavigate');
    end
end
