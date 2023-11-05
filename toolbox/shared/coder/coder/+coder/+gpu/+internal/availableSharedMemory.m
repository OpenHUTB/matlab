function[limit]=availableSharedMemory
%#codegen

    if coder.const(~coder.target('MATLAB'))
        coder.allowpcode('plain')
        limit=coder.const(feval('coder.gpu.getGpuSharedMemory',eml_option('CodegenBuildContext')));
    end
end

