function FileSelect(this,dialog)







    if(exist(this.inputFilename,'file'))
        theFile=which(this.inputFilename);
    else
        theFile=this.inputFilename;
    end

    audioOnly=strcmp(get(get(this,'Block'),'outputStreams'),...
    getString(message('dspshared:FromMMFile:AudioOnly')));

    if ispc
        audioFiles={'*.wav;*.wma;*.mp3;*.m4a;*.ogg;*.opus;*.flac;*.au;*.aiff',...
        'Audio Files (*.wav,*.wma,*.mp3,*.m4a,*.ogg,*.opus;*.flac ...)'};
        videoFiles={'*.avi;*.wmv;*.mpg;*.mpeg;*.qt;*.mov;*.mp2;*.mp4;*.m4v',...
        'Video Files (*.avi,*.wmv,*.mp4,*.m4v ...)'};
        if audioOnly
            selections=[audioFiles;videoFiles;{'*.*','All Files (*.*)'}];
        else
            selections=[videoFiles;audioFiles;{'*.*','All Files (*.*)'}];
        end
    else
        if isOpusSupported()
            audioFiles={'*.wav;*.mp3;*.m4a;*.ogg;*.opus;*.flac;*.au;*.aiff',...
            'Audio Files (*.wav,*.mp3,*.m4a,*.ogg,*.opus;*.flac ...)'};
        else
            audioFiles={'*.wav;*.mp3;*.m4a;*.ogg;*.flac;*.au;*.aiff',...
            'Audio Files (*.wav,*.mp3,*.m4a,*.ogg,*.flac ...)'};
        end
        videoFiles={'*.avi;*.mov;*.mp4;*.m4v;*.mpg;*.mpeg;*.m2v;*.mj2;*.dv',...
        'Video Files (*.avi,*.mov,*.mp4,*.m4v ...)'};
        if audioOnly
            selections=[audioFiles;videoFiles;{'*.*','All Files (*.*)'}];
        else
            selections=[videoFiles;audioFiles;{'*.*','All Files (*.*)'}];
        end
    end

    [filename,pathname]=uigetfile(selections,...
    getString(message('dspshared:FromMMFile:PickAnInputFile')),theFile);
    if~(isequal(filename,0)||isequal(pathname,0))
        this.inputFilename=[pathname,filename];
        dialog.setWidgetValue('inputFilename',[pathname,filename]);
    end

