function Hd=createDfilt(this)





    Hd=dfilt.scalar;
    Hd.Gain=this.Gain;
    if~strcmpi(this.InputSLType,'double')
        Hd.Arithmetic='fixed';
        [Hd.RoundMode,Hd.OverflowMode]=getDFiltRoundOverflow(this);
    end
    setFixptSettingtoDfilt(this,Hd,'InputSLType','InputWordLength','InputFracLength');
    Hd.specifyall;
    setFixptSettingtoDfilt(this,Hd,'OutputSLType','OutputWordLength','OutputFracLength');

    setFixptSettingtoDfilt(this,Hd,'CoeffSLType','CoeffWordLength',...
    'CoeffFracLength');


