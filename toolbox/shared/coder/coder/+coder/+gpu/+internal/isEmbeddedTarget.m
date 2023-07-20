function flag=isEmbeddedTarget(ctx)




%#codegen

    flag=false;


    coder.allowpcode('plain');
    if nargin==0
        ctx=eml_option('CodegenBuildContext');
    end

    if(coder.const(contains(string(...
        coder.const(feval('coder.gpu.getGpuTarget',ctx))),'NVIDIA Drive')||contains(string(...
        coder.const(feval('coder.gpu.getGpuTarget',ctx))),'NVIDIA Jetson')))
        flag=true;
    end


end
