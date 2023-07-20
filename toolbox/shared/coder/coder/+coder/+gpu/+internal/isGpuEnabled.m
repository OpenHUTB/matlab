function flag=isGpuEnabled



%#codegen

    flag=false;

    if(coder.const(~coder.target('MATLAB')))
        coder.allowpcode('plain');
        if eml_option('EnableGPU')
            flag=true;
        end
    end

end
