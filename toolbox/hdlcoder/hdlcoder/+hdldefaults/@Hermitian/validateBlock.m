function v=validateBlock(this,hC)




    v=hdlvalidatestruct;


    bfp=hC.SimulinkHandle;


    func=get_param(bfp,'Function');

    if~strcmpi(func,'hermitian')
        obj=get_param(bfp,'Object');
        objpath=[obj.path,'/',obj.name];
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:unsupportedHermitian',objpath,func));
    end

