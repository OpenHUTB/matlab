function navigate(dictName,entry,opt)




    dictPath=rmide.getFilePath(dictName);

    rmide.meOpen(dictPath,entry);

    if nargin>2&&ispc&&strcmp(opt,'_suppress_browser')

        reqmgt('winClose','(?:localhost|127\.0\.0\.1):\d+\/matlab\/feval/rmiobjnavigate');
    end
end
