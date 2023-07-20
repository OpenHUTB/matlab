function Hd=createDfilt(this)




    w=warning('off','dsp:mfilt:mfilt:Obsolete');
    Hd=mfilt.cascade;
    warning(w);
    for stgn=1:length(this.Stage)
        Hd.Stage(stgn)=createDfilt(this.Stage(stgn));
    end


