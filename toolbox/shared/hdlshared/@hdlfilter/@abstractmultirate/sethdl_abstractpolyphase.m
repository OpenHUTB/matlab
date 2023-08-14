function sethdl_abstractpolyphase(this,Hd)




    this.sethdl_abstractfilter(Hd);

    if~strcmpi(this.InputSLtype,'double')
        [Hd.RoundMode,Hd.OverflowMode]=getDFiltRoundOverflow(this);
    end
    polycoeffs=this.PolyphaseCoefficients;

    Hd.Numerator=polycoeffs(:)';

    setFixptSettingtoDfilt(this,Hd,'CoeffSLType','CoeffWordLength','NumFracLength');
    setFixptSettingtoDfilt(this,Hd,'ProductSLType','ProductWordLength','ProductFracLength');
    setFixptSettingtoDfilt(this,Hd,'AccumSLType','AccumWordLength','AccumFracLength');



