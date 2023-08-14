function sethdl_abstractfilter(this,Hd)







    if strcmpi(this.InputSLType,'double')
        Hd.Arithmetic='double';
    else
        Hd.Arithmetic='fixed';
        setFixptSettingtoDfilt(this,Hd,'InputSLType','InputWordLength','InputFracLength');
        Hd.FilterInternals='SpecifyPrecision';
        setFixptSettingtoDfilt(this,Hd,'OutputSLType','OutputWordLength','OutputFracLength');
    end














