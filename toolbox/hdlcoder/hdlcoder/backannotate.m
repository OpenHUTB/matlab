




































function backannotate(varargin)
    import BA.New.BackAnnotator;
    import BA.New.CP.Report2CP;
    import BA.New.Optional;
    import BA.New.ReportParser.XilinxVivadoTvrParser;
    import BA.New.Util;



    persistent backAnnotator;


    [argparseResult,debugStrings]=parseUserParams(varargin{:});


    annotateGM=strcmp(argparseResult.annotateGM,'on');
    debug=argparseResult.debug;
    endsonly=argparseResult.endsonly;
    numCP=argparseResult.numCP;
    originalModel=argparseResult.model;
    pathToTimingFile=argparseResult.pathToTimingFile;
    showall=argparseResult.showall;
    showdelays=argparseResult.showdelays;
    targetPlatform=argparseResult.targetPlatform;
    unique=argparseResult.unique;
    clear argparseResult;

    ba_table={};


    if isempty(originalModel)
        [backAnnotator,ba_table,ds]=backAnnotator.annotate(numCP);
        debugStrings=horzcat(debugStrings,ds);


    else







        gmPrefix=hdlget_param(originalModel,'GeneratedModelNamePrefix');
        if isempty(gmPrefix)
            fprintf('\nERROR: gmPrefix cannot be empty; exiting...');
            return;
        end




        gmPrefixOpt=Util.ifElse(...
        annotateGM,...
        @()Optional.some(gmPrefix),...
        @()Optional.none()...
        );
        clear gmPrefix;


        rootPIR=cachePIR(pathToTimingFile);
        if rootPIR==-1
            fprintf('ERROR: the timing file `%s` does not exist...\n',pathToTimingFile);
            return;
        end
        [backAnnotator,ds]=BackAnnotator(originalModel,rootPIR,gmPrefixOpt,targetPlatform,pathToTimingFile);

        [backAnnotator,ba_table,ds1]=backAnnotator.annotate(numCP);
        debugStrings=horzcat(debugStrings,ds);
        debugStrings=horzcat(debugStrings,ds1);

        if~exist(fullfile(pwd,'hdl_prj','vivado_prj'),'dir')
            mkdir(fullfile(pwd,'hdl_prj','vivado_prj'));
        end
        save(fullfile(pwd,'hdl_prj','vivado_prj','ba_result.mat'),'ba_table');

    end

    debugStrings=Util.filter(@(s)~isempty(s),debugStrings);
    debugString=strjoin(debugStrings,'\n');
    if strcmp(debug,'stdout')
        fprintf('%s\n',debugString);
    elseif~isempty(debug)
        fileID=fopen(debug,'w');
        fprintf(fileID,'%s\n',debugString);
        fclose(fileID);
    end
end













function rootPIR=cachePIR(pathToTimingFile)
    import BA.New.Util;
    if~isfile(pathToTimingFile)
        rootPIR=-1;
        return;
    end










    rootPIR=pir;
end














function[argparseResult,debugStrings]=parseUserParams(varargin)
    import BA.New.Util;

    debugStrings={};
    params={varargin{:}};

    isOnOrOff=@(v)strcmp(v,'on')||strcmp(v,'off');

    p=inputParser();
    addParameter(p,'annotateGM','on',isOnOrOff);
    addParameter(p,'debug','stdout',@(v)true);
    addParameter(p,'endsonly','off',isOnOrOff);
    addParameter(p,'model',@(v)true);
    addParameter(p,'numCP',1,@(v)isnumeric(v));
    addParameter(p,'pathToTimingFile',@(v)isfile(v));
    addParameter(p,'showall','off',isOnOrOff);
    addParameter(p,'showdelays','off',isOnOrOff);
    addParameter(p,'targetPlatform','Xilinx Vivado',@(v)strcmp(v,'Xilinx Vivado'));
    addParameter(p,'unique','off',isOnOrOff);

    parse(p,varargin{:});
    argparseResult=p.Results;
end
