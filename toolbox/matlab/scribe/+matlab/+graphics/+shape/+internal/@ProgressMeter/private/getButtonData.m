function fname=getButtonData(buttonState)




    switch buttonState
    case 'play'
        fname={'play.png','play_2x.png'};

    case 'pause'
        fname={'pause.png','pause_2x.png'};

    otherwise
        fname='';
    end

    if~isempty(fname)

        loc=fileparts(mfilename('fullpath'));
        fname=string(fullfile(loc,fname));
    end
end
