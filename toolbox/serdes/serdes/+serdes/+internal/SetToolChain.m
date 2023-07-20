function[noCodegen,noCompiler]=SetToolChain(systemHandle)






    noCodegen=false;
    noCompiler=false;
    if ismac
        set_param(systemHandle,'Toolchain','Automatically locate an installed toolchain');
        noCodegen=true;
    else
        mexCompilerInfo=mex.getCompilerConfigurations('C++');
        if isempty(mexCompilerInfo)
            compiler='NoCompiler';
        else
            compiler=mexCompilerInfo(1).ShortName;
        end
        switch compiler
        case 'MSVCPP160'
            set_param(systemHandle,'Toolchain','IBIS-AMI Microsoft Visual C++ 2019 v16.0 | nmake (64-bit Windows)');
        case 'MSVCPP150'
            set_param(systemHandle,'Toolchain','IBIS-AMI Microsoft Visual C++ 2017 v15.0 | nmake (64-bit Windows)');
        case 'MSVCPP140'
            set_param(systemHandle,'Toolchain','IBIS-AMI Microsoft Visual C++ 2015 v14.0 | nmake (64-bit Windows)');
        case 'mingw64-g++'
            set_param(systemHandle,'Toolchain','IBIS-AMI MinGW64 | gmake (64-bit Windows)');
        case 'g++'
            set_param(systemHandle,'Toolchain','IBIS-AMI GNU gcc/g++ | gmake (64-bit Linux)');
        otherwise
            set_param(systemHandle,'Toolchain','Automatically locate an installed toolchain');
            noCompiler=true;
        end
    end
end