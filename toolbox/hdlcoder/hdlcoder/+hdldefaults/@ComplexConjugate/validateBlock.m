function v=validateBlock(~,hC)




    v=hdlvalidatestruct;


    bfp=hC.SimulinkHandle;
    func=get_param(bfp,'Function');

    if~strcmpi(func,'conj')
        obj=get_param(bfp,'Object');
        objpath=[obj.path,'/',obj.name];
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ComplexConjugateUnsupported',objpath,func));
    end

    inport=hC.SLInputPorts;
    insig=inport.Signal;
    insig_size=hdlsignalsizes(insig);
    if(insig_size(3)&&insig_size(1)==0&&insig_size(2)==0)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ComplexConjugateFloat'));
    end

