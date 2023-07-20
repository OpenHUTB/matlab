function makehdl(this,params)
















    if nargin<2
        params={};
    end






    [gp,codegenParams]=compileModelAndCreatePIR(this,params);

    runPIRTransformAndCodegen(this,gp,codegenParams,params);

end
