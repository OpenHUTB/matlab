function hC=getFilterComp(hN,hInSignals,hOutSignals,hImpl,hFiltObj,compName,slbh)



    if nargin<7
        error(message('hdlcommon:hdlcommon:FilterElaboration'));
    end

    hC=pircore.getFilterComp(hN,hInSignals,hOutSignals,hImpl,hFiltObj,compName,slbh);
