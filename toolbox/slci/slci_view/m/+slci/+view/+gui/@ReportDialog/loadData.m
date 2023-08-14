


function msg=loadData(obj,modelName)

    try

        conf=slci.toolstrip.util.getConfiguration(obj.getStudio);

        file=fullfile(conf.getReportFolder(),[modelName,'_report.html']);
    catch
        file='';
    end


    msg.data=readFile(file,modelName);

    msg.models=getAllModels(conf);

    msg.type='InspectionReport';
    msg.modelName=modelName;

end


function models=getAllModels(conf)
    models={};
    if conf.getFollowModelLinks()
        models=conf.getRefMdls();
        if isempty(models)
            conf.SetupRefMdls();
            models=conf.getRefMdls();
        end
        assert(iscell(models),'models must be cell array');
    end

    models{end+1}=conf.getModelName;
end


function result=readFile(file,modelName)

    result=DAStudio.message('Slci:ui:InspectionReportNotFound');

    isReportExists=~isempty(file)&&exist(file,'file');
    if isReportExists

        try
            rfile=fileread(file);
        catch
        end

        rfile=replaceFileHref(rfile,modelName);


        epos=regexp(rfile,'</head>');


        result=rfile(epos+7:end);


        result=strsplit(result,'<body');
        if numel(result)==2
            result=result{2};
        end


        pos=regexp(result,'>','once');
        result=result(pos+1:end);


        result=split(result,'</body>');
        if numel(result)==2
            result=result{1};
        end
    end
end


function out=replaceFileHref(rfile,modelName)
    out=rfile;
    spos=regexp(rfile,'<a href ="file:///');
    for i=1:numel(spos)
        sp=spos(i);
        epos=regexp(rfile(sp+1:end),'">');
        ep=epos(1)+sp-1;

        fullFileName=rfile(sp+18:ep);

        fileName=strsplit(fullFileName,'/');
        fileName=fileName{end};
        oldlink=rfile(sp:ep+2);
        newlink=['<a href = "matlab:slci.view.internal.hiliteCodeFile(''',fileName,''', ''',modelName,''')">'];
        out=strrep(out,oldlink,newlink);
    end

end