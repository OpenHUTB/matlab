function s=initSplash(p)


    s=internal.SplashWithTimeout(...
    p.SplashDelay,'Smith Chart',...
    'Initializing display...');
    start(s);
