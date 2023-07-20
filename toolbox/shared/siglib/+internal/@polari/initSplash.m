function s=initSplash(p)


    s=internal.SplashWithTimeout(...
    p.SplashDelay,'Polar Measurement',...
    'Initializing display...');
    start(s);
