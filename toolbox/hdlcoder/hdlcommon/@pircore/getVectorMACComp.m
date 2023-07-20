function macComp=getVectorMACComp(hN,hInSignals,hOutSignals,rndMode,ovMode,compName,desc,slbh,initialValue,elabMode)


    if nargin<10
        elabMode='Auto';
    end

    if nargin<9
        initialValue=0;
    end

    if nargin<8
        slbh=-1;
    end

    if nargin<7
        desc='';
    end

    isInitValZero=false;
    if(initialValue==0)
        isInitValZero=true;
    end

    if(~isa(initialValue,'numeric'))
        try
            initialValue=str2double(initialValue.Value);
        catch
            initialValue=str2double(initialValue);
        end
    end

    macComp=hN.addComponent2(...
    'kind','vectormac',...
    'SimulinkHandle',-1,...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'RoundingMode',rndMode,...
    'OverflowMode',ovMode,...
    'BlockComment',desc,...
    'InitialValue',initialValue,...
    'IsInitValZero',isInitValZero,...
    'ElabMode',elabMode);





end
