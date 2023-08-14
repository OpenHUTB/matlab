


function msg=loadData(obj,modelName)

    try

        conf=slci.toolstrip.util.getConfiguration(obj.getStudio);

        file=getReportFile(conf,modelName);
    catch
        file='';
        conf=[];
    end

    msg.data=readFile(file);
    if isempty(conf)
        msg.models={modelName};
    else
        msg.models=getAllModels(conf);
    end

    msg.type='CompatiblityReport';
    msg.modelName=modelName;

end


function models=getAllModels(conf)
    models={};
    if conf.getFollowModelLinks()
        models=conf.getRefMdls();
        if isempty(models)
            conf.SetupRefMdls();
            slci.Configuration.saveObjToFile(conf.getModelName(),conf);
            models=conf.getRefMdls();
        end
        assert(iscell(models),'models must be cell array');
    end

    models{end+1}=conf.getModelName;
end


function result=readFile(file)
    isReportExists=~isempty(file)&&exist(file,'file');




    result=DAStudio.message('Slci:ui:CompatibilityReportNotFound');

    if isReportExists

        try
            rfile=fileread(file);
        catch
        end


        epos=regexp(rfile,'</head>');


        result=rfile(epos+7:end);


        result=strsplit(result,'<body');
        if numel(result)==2
            result=result{2};
        elseif numel(result)==1
            result=result{1};
        end


        pos=regexp(result,'>','once');
        result=result(pos+1:end);


        result=split(result,'</body>');
        if numel(result)==2
            result=result{1};
        end


        spos=regexp(rfile,'<style type="text/css">');
        epos=regexp(rfile,'</style>');
        style=[];
        if(numel(epos)==numel(epos))
            for i=1:numel(spos)
                style=[style,rfile(spos(i):epos(i)+8)];%#ok
            end
        end

        result=[style,result];
    end

end


function file=getReportFile(conf,modelName)
    compReportDir=conf.getCompReportFolder;
    modelAdvReportDir=conf.getModelAdvisorReportFolder;
    if conf.getFollowModelLinks()

        compReportDir=getParentDir(compReportDir);
        compReportFile=fullfile(compReportDir,modelName,'report.html');
        modelAdvReportDir=getParentDir(modelAdvReportDir);
        modelAdvReportFile=fullfile(modelAdvReportDir,modelName,'report.html');
    else
        compReportFile=fullfile(compReportDir,'report.html');
        modelAdvReportFile=fullfile(modelAdvReportDir,'report.html');
    end

    if exist(compReportFile,'file')&&exist(modelAdvReportFile,'file')
        prop1=dir(compReportFile);
        prop2=dir(modelAdvReportFile);

        if prop1.datenum>prop2.datenum
            file=compReportFile;
        else
            file=modelAdvReportFile;
        end
    elseif exist(compReportFile,'file')
        file=compReportFile;
    else
        file=modelAdvReportFile;
    end
end


function out=getParentDir(path)
    pos=strfind(path,filesep);
    out=path(1:pos(end)-1);
end