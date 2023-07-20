function[modeDlgStr,wlDlgStr,flDlgStr,skipThisSignal,unknownParam]=...
    getLMSFltMdWLFLDlgPrmInfo(h,pathItem,stepflag,blockAlgorithm)%#ok



    unknownParam=false;

    switch pathItem
    case{'Error Signal','Output Signal','Error','Output','1'}



        skipThisSignal=false;
        modeDlgStr='';
        wlDlgStr='';
        flDlgStr='';

    case 'StepSize'
        modeDlgStr='firstCoeffMode';
        wlDlgStr='firstCoeffWordLength';
        flDlgStr='firstCoeffFracLength';
        skipThisSignal=true;







    case 'Leakage'
        modeDlgStr='firstCoeffMode';
        wlDlgStr='firstCoeffWordLength';
        flDlgStr='secondCoeffFracLength';
        skipThisSignal=true;






    case 'Weights'
        modeDlgStr='memoryMode';
        wlDlgStr='memoryWordLength';
        flDlgStr='memoryFracLength';
        skipThisSignal=false;

    case 'Product output u''u'
        modeDlgStr='prodOutputMode';
        wlDlgStr='prodOutputWordLength';
        flDlgStr='prodOutputFracLength';
        skipThisSignal=...
        ~(strcmpi(blockAlgorithm,'Normalized LMS'));

    case 'Product output W''u'
        modeDlgStr='prodOutputMode';
        wlDlgStr='prodOutputWordLength';
        flDlgStr='prodOutput2FracLength';
        skipThisSignal=false;

    case 'Product output mu*e'
        modeDlgStr='prodOutputMode';
        wlDlgStr='prodOutputWordLength';
        flDlgStr='prodOutput3FracLength';
        skipThisSignal=~(...
        strcmpi(blockAlgorithm,'LMS')||...
        strcmpi(blockAlgorithm,'Normalized LMS')||...
        strcmpi(blockAlgorithm,'Sign-Data LMS'));

    case 'Product output Q*u'
        modeDlgStr='prodOutputMode';
        wlDlgStr='prodOutputWordLength';
        flDlgStr='prodOutput4FracLength';
        skipThisSignal=false;

    case 'Quotient'
        modeDlgStr='prodOutputMode';
        wlDlgStr='prodOutputWordLength';
        flDlgStr='quotientFracLength';
        skipThisSignal=...
        ~(strcmpi(blockAlgorithm,'Normalized LMS'));

    case 'Accumulator u''u'
        modeDlgStr='accumMode';
        wlDlgStr='accumWordLength';
        flDlgStr='accumFracLength';
        skipThisSignal=...
        ~(strcmpi(blockAlgorithm,'Normalized LMS'));

    case 'Accumulator W''u'
        modeDlgStr='accumMode';
        wlDlgStr='accumWordLength';
        flDlgStr='accum2FracLength';
        skipThisSignal=false;

    otherwise

        unknownParam=true;
        skipThisSignal=true;
        modeDlgStr='';
        wlDlgStr='';
        flDlgStr='';

    end

end
