function sarray=hdlgetsignalarray(this,sigpointer)






    hN=sigpointer.Owner;
    hT=sigpointer.Type;
    num=hT.Dimensions;
    hBT=hT.getLeafType;
    name=sigpointer.Name;


    for ii=1:num
        newSignal=hN.addSignal;
        newSignal.Type=hBT;
        newSignal.Name=[name,'(',num2str(ii),')'];

        sarray(ii)=newSignal;%#ok<AGROW>
    end
