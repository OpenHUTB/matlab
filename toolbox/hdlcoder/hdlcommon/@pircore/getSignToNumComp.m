function cgirComp=getSignToNumComp(hN,hInSignals,hOutSignals,compName)






    if(nargin<4)
        compName='signum';
    end

    cgirComp=hN.addComponent2(...
    'kind','signum_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals);

end


