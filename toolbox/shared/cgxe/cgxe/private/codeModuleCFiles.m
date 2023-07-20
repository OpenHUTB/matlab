function codeModuleCFiles(modelName,md5ChecksumStr,fallbackInfo,targetDirName,varargin)







    if nargin<5
        codingOpenMP=false;
    else
        codingOpenMP=varargin{1};
    end

    gencpp=get_cgxe_compiler_info(modelName);
    CGXE.Coder.code_module_header_file(targetDirName,md5ChecksumStr,modelName,codingOpenMP,gencpp);
    CGXE.Coder.code_module_source_file(targetDirName,md5ChecksumStr,modelName,fallbackInfo,gencpp);
