function constComp=getConstComp(hN,hOutSignals,constValue,compName,vectorParams1D,isConstZero,TunableParamStr,ConstBusName,ConstBusType)










    if nargin<9
        ConstBusType='';
    end

    if nargin<8
        ConstBusName='';
    end

    if nargin<7
        TunableParamStr='';
    end

    if nargin<6
        isConstZero=false;
    end

    if nargin<5
        vectorParams1D='on';
    end

    if nargin<4
        compName='const';
    end

    constComp=hN.addComponent2(...
    'kind','mconstant_comp',...
    'Name',compName,...
    'InputSignals',[],...
    'OutputSignals',hOutSignals,...
    'ConstantValue',constValue,...
    'VectorParams1D',vectorParams1D,...
    'IsConstZero',isConstZero,...
    'TunableParamStr',TunableParamStr,...
    'ConstBusName',ConstBusName,...
    'ConstBusType',ConstBusType);

end


