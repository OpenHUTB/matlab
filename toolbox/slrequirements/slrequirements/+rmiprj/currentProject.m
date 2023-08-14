function result=currentProject(option)



    persistent proj doneTraceables

    if nargin==0
        proj=[];
        result=[];
        RptgenRMI.mllinkMgr('clear');
        return;
    end

    if isempty(proj)
        try
            proj=simulinkproject;
            doneTraceables=false;
        catch ME %#ok<NASGU> Silent catch.
            result=[];
            return;
        end


    elseif~proj.isLoaded
        proj=[];
        result=[];
        RptgenRMI.mllinkMgr('clear');
        return;
    end

    switch option
    case 'info'
        result=projectInfoTable(proj);
    case 'name'
        result=proj.Name;
    case 'folder'
        result=proj.RootFolder;
    case{'matlab','simulink','data','test'}
        result=fileList(proj,option);
        doneTraceables=false;
    case 'sources'
        result=sourceList(proj);
    case 'traceable'
        result=fileList(proj,option);
        doneTraceables=true;
    case 'other'
        result=fileList(proj,option,doneTraceables);
    otherwise
        result=[];
    end

end

function list=sourceList(proj)
    list=cell(0,2);
    totalFiles=length(proj.Files);
    for i=1:totalFiles
        fPath=proj.Files(i).Path;
        if any(exist(fPath,'file')==[2,4])
            [sourceable,~,isMl,isSl,isData,isTest]=classify(fPath);
            if~sourceable
                continue;
            end
            if isMl
                list=[list;{fPath,'matlab'}];%#ok<AGROW>
            elseif isSl
                list=[list;{fPath,'simulink'}];%#ok<AGROW>
            elseif isData
                list=[list;{fPath,'data'}];%#ok<AGROW>
            elseif isTest
                list=[list;{fPath,'test'}];%#ok<AGROW>
            end
        end
    end
end

function list=fileList(proj,option,doneTraceables)
    totalFiles=length(proj.Files);
    rptLabelFilePath=getString(message('Slvnv:rmiml:RptLabelFilePath'));
    rptLabelCategory=getString(message('Slvnv:rmiml:RptLabelCategory'));
    rptLabelSubReport=getString(message('Slvnv:rmiml:RptLabelSubReport'));
    if any(strcmp(option,{'sources','matlab','simulink','data','test'}))
        list={'#',rptLabelFilePath,rptLabelCategory,rptLabelSubReport};
    elseif strcmp(option,'traceable')
        list={'#',rptLabelFilePath,rptLabelCategory,rptLabelSubReport};
    else
        list={'#',rptLabelFilePath,rptLabelCategory};
    end
    count=0;
    for i=1:totalFiles
        fPath=proj.Files(i).Path;
        if any(exist(fPath,'file')==[2,4])
            [sourceable,traceable,isMl,isSl,isData,isTest]=classify(fPath);
            switch option
            case 'sources'
                if sourceable
                    count=count+1;
                    category=proj.Files(i).Labels(1).Name;
                    list=[list;{count,fPath,category,fPath}];%#ok<AGROW>
                end
            case 'matlab'
                if isMl
                    count=count+1;
                    category=proj.Files(i).Labels(1).Name;
                    list=[list;{count,fPath,category,fPath}];%#ok<AGROW>
                end
            case 'simulink'
                if isSl
                    count=count+1;
                    category=proj.Files(i).Labels(1).Name;
                    list=[list;{count,fPath,category,fPath}];%#ok<AGROW>
                end
            case 'data'
                if isData
                    count=count+1;
                    category=proj.Files(i).Labels(1).Name;
                    list=[list;{count,fPath,category,fPath}];%#ok<AGROW>
                end
            case 'test'
                if isTest
                    count=count+1;
                    category=proj.Files(i).Labels(1).Name;
                    list=[list;{count,fPath,category,fPath}];%#ok<AGROW>
                end
            case 'traceable'
                if traceable&&~sourceable
                    count=count+1;
                    category=proj.Files(i).Labels(1).Name;
                    list=[list;{count,fPath,fPath,category}];%#ok<AGROW>
                end
            case 'other'
                if~traceable||(~doneTraceables&&~sourceable)
                    count=count+1;
                    if~isempty(proj.Files(i).Labels)
                        category=proj.Files(i).Labels(1).Name;
                    else
                        category='N/A';
                    end
                    list=[list;{count,fPath,category}];%#ok<AGROW>
                end
            otherwise
                continue;
            end
        end
    end
end

function[sourceable,traceable,isMl,isSl,isData,isTest]=classify(fPath)
    sourceable=false;
    traceable=false;
    isMl=false;
    isSl=false;
    isData=false;
    isTest=false;
    [~,~,ext]=fileparts(fPath);
    switch ext
    case '.m'
        sourceable=true;
        traceable=true;
        isMl=true;
    case '.sldd'
        sourceable=true;
        traceable=true;
        isData=true;
    case '.mldatx'
        sourceable=true;
        traceable=true;
        isTest=true;
    case{'.mdl','.slx'}
        sourceable=true;
        traceable=true;
        isSl=true;
    case{'.doc','.docx','.rtf'...
        ,'.xls','.xlsx'...
        ,'.html','.htm'...
        ,'.pdf','.txt'...
        ,'.mn'}
        traceable=true;
    otherwise
    end
end

function table=projectInfoTable(proj)
    table={...
    getString(message('Slvnv:rmiml:ProjectName')),proj.Name;...
    getString(message('Slvnv:rmiml:ProjectFolder')),proj.RootFolder;...
    getString(message('Slvnv:rmiml:ProjectTotalFiles')),num2str(countFiles(proj));...
    getString(message('Slvnv:rmiml:ProjectContentsChangeDate')),getMostRecentDate(proj)};
end

function count=countFiles(proj)
    items=proj.Files;
    count=0;
    for i=1:length(items)
        if exist(items(i).Path)==7
            continue;
        else
            count=count+1;
        end
    end
end

function latestDate=getMostRecentDate(proj)
    totalFiles=length(proj.Files);
    latest=0;
    latestDate='';
    for i=1:totalFiles
        fPath=proj.Files(i).Path;
        fileInfo=dir(fPath);
        myDateNum=fileInfo.datenum;
        if myDateNum>latest
            latestDate=fileInfo.date;
            latest=myDateNum;
        end
    end
end




