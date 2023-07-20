function v=validateBlock(this,hC)

    v=hdlvalidatestruct;


    bfp=hC.SimulinkHandle;


    func=get_param(bfp,'Function');

    if~strcmpi(func,'magnitude^2')
        obj=get_param(bfp,'Object');
        objpath=[obj.path,'/',obj.name];
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:unsupportedMagnitudeSquared',objpath,func));
    end