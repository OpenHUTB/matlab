function[hporch]=getVideoPorchTiming(h)



    switch h
    case 1920
        hporch=280;
    case 1440
        hporch=276;
    case 1280
        hporch=370;
    case 720
        hporch=138;
    case 640
        hporch=160;
    otherwise
        hporch=0;
    end

