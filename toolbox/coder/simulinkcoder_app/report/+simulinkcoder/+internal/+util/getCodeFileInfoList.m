function list=getCodeFileInfoList(input)










    if isa(input,'rtw.report.ReportInfo')
        rptInfo=input;
    else
        rptInfo=rtw.report.getReportInfo(input);
    end

    tmpGroupDispNames=rptInfo.getCodeFileCategoryDisplayNames();
    groupDispNames=tmpGroupDispNames{2};




    sorted=rptInfo.getSortedFileInfoList();
    fileInfo=rptInfo.getFileInfo();


    n=length(fileInfo);
    list={};


    groupNumList=[sorted.GroupNum{:}];


    id=0;
    for i=1:n
        file=[];

        fullName=sorted.FileName{i};
        [~,name,ext]=fileparts(fullName);
        file.name=[name,ext];

        for j=1:n
            info=fileInfo(j);
            if strcmp(info.FileName,file.name)
                id=id+1;

                file.type=info.Type;
                file.group=info.Group;
                file.path=info.Path;
                file.tag=info.Tag;

                file.groupDisplay=groupDispNames{groupNumList(id)};
                list{end+1}=file;%#ok<AGROW>
                break;
            end
        end
    end


