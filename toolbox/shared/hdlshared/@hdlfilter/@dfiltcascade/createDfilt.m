function Hd=createDfilt(this)





    Hd=dfilt.cascade;
    for stgn=1:length(this.Stage)
        Hd.Stage(stgn)=createDfilt(this.Stage(stgn));
    end



