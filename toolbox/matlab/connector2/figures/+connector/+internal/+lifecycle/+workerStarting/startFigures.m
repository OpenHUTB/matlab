function startFigures()

    set(0,'DefaultFigureColor',[1,1,1]);


    f=figure;
    peaks;

    matlab.graphics.internal.drawnow.startUpdate;

    close(f);

end
