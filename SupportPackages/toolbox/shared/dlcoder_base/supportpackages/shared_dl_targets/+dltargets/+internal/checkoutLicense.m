function checkoutLicense(targetlib)





    switch targetlib
    case{'cudnn','tensorrt','arm-compute-mali'}
        if(~builtin('license','checkout','GPU_Coder'))
            error(message('dlcoder_spkg:cnncodegen:ErrorLicenseCheckout','GPU Coder',targetlib));
        end

        if(~builtin('license','checkout','Distrib_Computing_Toolbox'))
            error(message('dlcoder_spkg:cnncodegen:ErrorLicenseCheckout','Parallel Computing Toolbox',targetlib));
        end

        if(~builtin('license','checkout','MATLAB_Coder'))
            error(message('dlcoder_spkg:cnncodegen:ErrorLicenseCheckout','MATLAB Coder',targetlib));
        end

    case{'mkldnn','onednn','arm-compute'}
        if(~builtin('license','checkout','MATLAB_Coder'))
            error(message('dlcoder_spkg:cnncodegen:ErrorLicenseCheckout','MATLAB Coder',targetlib));
        end
    end
end
