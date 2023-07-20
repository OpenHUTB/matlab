function v=validateBlock(~,hC)




    v=hdlvalidatestruct;


    bfp=hC.SimulinkHandle;


    func=get_param(bfp,'Function');

    if~strcmpi(func,'transpose')
        obj=get_param(bfp,'Object');
        objpath=[obj.path,'/',obj.name];
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:TransposeUnsupported',objpath,func));
    end
