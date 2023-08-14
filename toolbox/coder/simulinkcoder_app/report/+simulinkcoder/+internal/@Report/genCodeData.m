function data=genCodeData(model,file,ref,reportV2Gen)



    if nargin<4
        reportV2Gen=false;
    end
    if nargin<3
        ref=false;
    end
    if nargin<2
        [file,~,~,ref]=simulinkcoder.internal.Report.getCodeDataFile(model,ref);
    end

    data=[];


    data.arch=struct('ispc',ispc,'isunix',isunix,'ismac',ismac);

    [rptInfo,ref]=simulinkcoder.internal.util.getReportInfo(model,ref);
    sys=rptInfo.SourceSubsystem;
    if isempty(sys)
        data.build=model;
    else
        data.build=Simulink.ID.getFullName(sys);
    end


    data.ref=ref;


    data.files=loc_getSourceFiles(rptInfo);

    if strcmp(get_param(model,'IsERTTarget'),'on')
        traceOn=strcmp(get_param(model,'GenerateTraceInfo'),'on')||...
        strcmp(get_param(model,'IncludeHyperlinkInReport'),'on');
        if~reportV2Gen||traceOn

            data.trace=loc_getTraceData(rptInfo);


            data.blocks=loc_getBlocks(rptInfo,model);
        end
    end


    if~reportV2Gen
        folder=fileparts(file);
        if~isfolder(folder)
            mkdir(folder);
        end
        save(file,'data','-mat');
    end


    function out=loc_getSourceFiles(rptInfo)
        files=rptInfo.getSortedFileInfoList_Cached();
        srcFiles=files.FileName;
        if isempty(srcFiles)
            return;
        end

        fileList=simulinkcoder.internal.util.getCodeFileInfoList(rptInfo);
        for i=1:length(fileList)
            file=fileList{i};
            codeFileName=fullfile(file.path,file.name);
            fid=fopen(codeFileName);
            if fid~=-1
                code=fread(fid,'*char');
                fclose(fid);


                if length(code)>1E7
                    fileInfo=dir(codeFileName);
                    code=sprintf('File is too large to show: %d bytes.',fileInfo.bytes);
                end
                file.code=code;
                fileList{i}=file;
            end
        end
        out=fileList;

        function out=loc_getTraceData(rptInfo)
            out='';
            t=coder.trace.getTraceInfoByReportInfo(rptInfo);
            if isempty(t)
                return;
            end
            out=t.traceInfoJson;

            function out=loc_getBlocks(rptInfo,mdl)
                folders=Simulink.filegen.internal.FolderConfiguration(rptInfo.ModelName);
                mapDir=folders.CodeGeneration.ModelReferenceCode;
                mapPath=fullfile(rptInfo.BuildDirectory,'..',mapDir,'tmwinternal','BlockTraceInfo.mat');
                if isfile(mapPath)
                    out=load(mapPath,'RTWNames2SID');
                    out=out.RTWNames2SID;
                elseif strcmp(rptInfo.ModelName,mdl)
                    out=rtwprivate('rtwctags_registry','rtwname2sid',mdl);
                else
                    error('Cannot get blocks info for Subsystem Build!');
                end


