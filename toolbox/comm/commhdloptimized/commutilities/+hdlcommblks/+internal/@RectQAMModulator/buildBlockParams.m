function prm=buildBlockParams(this,hC,hN)





    prm=struct;

    bfp=hC.SimulinkHandle;
    rto=get_param(bfp,'RunTimeObject');

    prm.hC=hC;
    prm.hN=hN;


    rtop=struct;
    for ii=1:(rto.NumRuntimePrms)
        if~isempty(rto.RuntimePrm(ii))
            rtop.(rto.RuntimePrm(ii).Name)=rto.RuntimePrm(ii).Data;
        end
    end


    prm.M=this.hdlslResolve('M',bfp);
    prm.IntegerInput=strcmpi(get_param(bfp,'InType'),'Integer');

    realData=rtop.modmap(1:2:end);
    imagData=rtop.modmap(2:2:end);

    switch lower(get_param(bfp,'Enc'))
    case 'binary'
        idx=0:(prm.M-1);
    case 'gray'
        idx=comm.internal.utilities.bin2gray([0:(prm.M-1)],'qam',prm.M);
    otherwise
        idx=rtop.mapping;
    end
    prm.TableDataReal=realData(idx+1);
    prm.TableDataImag=imagData(idx+1);


