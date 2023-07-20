function dspbaComp=getDspbaComp(hN,name,inputSignals,outputSignals,...
    entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,busInputPortNames,busInputPortWidths,busReadEnablePortNames,...
    rates,baseRate,blackBoxAttributes,vhdlComponentLibrary,...
    slbh)




    assert(nargin>=15,'No enough arguments are given to create Dspba comp');

    if nargin<18
        slbh=-1;
    end

    if nargin<17
        vhdlComponentLibrary='';
    end

    if nargin<16
        blackBoxAttributes=false;
    end

    dspbaComp=pircore.getDspbaComp(hN,name,inputSignals,outputSignals,...
    entityName,inportNames,outportNames,clkNames,ceNames,ceclrNames,busInputPortNames,busInputPortWidths,busReadEnablePortNames,...
    rates,baseRate,blackBoxAttributes,vhdlComponentLibrary,...
    slbh);


