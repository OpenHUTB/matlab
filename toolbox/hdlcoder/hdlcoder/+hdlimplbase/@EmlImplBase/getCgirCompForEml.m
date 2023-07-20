function cgirComp=getCgirCompForEml(this,hN,hInSignals,hOutSignals,name,ipf,bmp)



    slHandle=-1;

    cgirComp=hN.addComponent2(...
    'kind','cgireml',...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'Name',name,...
    'SimulinkHandle',slHandle);


    cgirComp.IpFileName=ipf;
    cgirComp.ParamInfo=bmp;

end

