function createProjDir(varargin)


    narginchk(1,2);
    mode=validatestring(varargin{1},{'jit','cprj','cgxe','all'});

    genCGXE=false;
    genJIT=false;
    genC=false;

    switch mode
    case 'jit'
        genJIT=true;
    case 'cprj'
        genC=true;
    case 'cgxe'
        genCGXE=true;
        narginchk(2,2);
        modelName=varargin{2};
    case 'all'
        genCGXE=true;
        genJIT=true;
        genC=true;
        narginchk(2,2);
        modelName=varargin{2};
    end

    if genJIT
        [projectDirPath,projectDirArray]=CGXE.JIT.getProjDir;

        if~exist(projectDirPath,'dir')
            cgxeprivate('create_directory_path',projectDirArray{:});
        end
    end

    if genCGXE
        [projectDirPath,projectDirArray]=cgxeprivate('get_cgxe_proj',modelName,'');

        if~exist(projectDirPath,'dir')
            cgxeprivate('create_directory_path',projectDirArray{:});
        end
    end

    if genC
        [projectDirPath,projectDirArray]=CGXE.Coder.getProjDir;

        if~exist(projectDirPath,'dir')
            cgxeprivate('create_directory_path',projectDirArray{:});
        end
    end