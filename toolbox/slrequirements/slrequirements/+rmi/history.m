function result=history(method,varargin)











    persistent histData;
    persistent tagData;
    persistent filtersData;
    persistent loaded
    if isempty(loaded)||~loaded
        [histData,tagData,filtersData]=getHist();
        loaded=true;
    end

    method=convertStringsToChars(method);
    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    nvarargin=length(varargin);

    switch lower(method)
    case 'add'
        switch nvarargin
        case 2
            if(~isempty(varargin{1})&&~strcmp(varargin{1},' '))
                histData=addHist(histData,varargin{1},varargin{2});
            end
            result=histData;
        otherwise
            error(message('Slvnv:reqmgt:history:InvalidArgumentNumber'));
        end

    case 'tag'
        switch nvarargin
        case 1
            [result,tagData]=updateTags(tagData,varargin{1});
        otherwise
            error(message('Slvnv:reqmgt:history:InvalidArgumentNumber'));
        end
    case 'filter'
        switch nvarargin
        case 1
            [result,filtersData]=updateFilters(filtersData,varargin{1});
        otherwise
            error(message('Slvnv:reqmgt:history:InvalidArgumentNumber'));
        end
    case '-tag'
        [result,tagData]=removeTag(tagData,varargin{1});

    case 'get'
        result=histData;

    case 'tags'
        if nvarargin==1&&iscell(varargin{1})
            [~,tagData]=updateTags(tagData,varargin{1});
        end
        result=tagData;

    case 'filters'
        if nvarargin==1&&iscell(varargin{1})
            [~,filtersData]=updateFilters(filtersData,varargin{1});
        end
        result=filtersData;

    otherwise
        error(message('Slvnv:reqmgt:history:UnknownMethod'));
    end
end


function[isNew,tagData]=updateTags(tagData,thisTag)

    if iscell(thisTag)

        tagData=thisTag(:);
        isNew=true;
    else

        if isempty(tagData)
            tagData={thisTag};
            isNew=true;
        else
            loc=strcmp(tagData(:,1),thisTag);
            loc=find(loc);

            if isempty(loc)
                tagData=[{thisTag};tagData];
                maxLength=10;
                if length(tagData)>maxLength
                    tagData(maxLength+1)=[];
                end
                isNew=true;
            else
                tagData(loc)=[];
                tagData=[{thisTag};tagData];
                isNew=false;
            end
        end
    end

    commitHistory(tagData,'tagData');
end

function[isNew,filtersData]=updateFilters(filtersData,thisFilter)

    if iscell(thisFilter)

        filtersData=thisFilter(:);
        isNew=true;
    else

        if any(strcmp(filtersData,thisFilter))
            isNew=false;
        else
            filtersData=sort([filtersData;thisFilter]);
            isNew=true;
        end
    end
    if isNew
        commitHistory(filtersData,'filtersData');
    end
end

function[isRemoved,tagData]=removeTag(tagData,thisTag)
    match=strcmpi(tagData,thisTag);
    if any(match)
        tagData(match)=[];
        isRemoved=true;
        commitHistory(tagData,'tagData');
    else
        isRemoved=false;
    end
end

function histData=addHist(histData,filename,docType)


    if(strcmp(docType,'other'))
        [~,~,fileExt]=fileparts(filename);
        reqTarget=rmi.linktype_mgr('resolve','other',fileExt);
    else
        reqTarget=rmi.linktype_mgr('resolve',docType,'');
        if(~isempty(reqTarget)&&isBuiltinType(reqTarget))
            if(reqTarget.isFile)
                [~,~,fileExt]=fileparts(filename);
                reqTarget_file=rmi.linktype_mgr('resolve','other',fileExt);
                if(~isempty(reqTarget_file))
                    reqTarget=reqTarget_file;
                end
            end
        end
    end

    if(isempty(reqTarget))
        return
    end
    docType=reqTarget.Registration;


    if isempty(histData)
        histData={filename,docType};


    else
        loc=strcmp(histData(:,1),filename);
        loc=find(loc);


        if~isempty(loc)
            histData(loc,:)=[];
            histData=[{filename,docType};histData];
        else

            histData=[{filename,docType};histData];

            maxLength=12;
            if length(histData(:,1))>maxLength
                histData(maxLength+1,:)=[];
            end
        end
    end


    commitHistory(histData,'histData');
end


function commitHistory(data,dataname)%#ok
    eval([dataname,' = data;'])
    histFileName=getHistFileName();
    try
        if exist(histFileName,'file')
            save(histFileName,dataname,'-mat','-append');
        else
            save(histFileName,dataname,'-mat');
        end
    catch Mex
        warning(message('Slvnv:reqmgt:history:CommitFailed',Mex.message));
    end
end

function[histData,tagData,filtersData]=getHist()

    histData={};
    tagData={};
    filtersData={};


    histFileName=getHistFileName();
    if exist(histFileName,'file')
        histFileStruct=load(histFileName);
        if isfield(histFileStruct,'histData')
            histData=histFileStruct.histData;
        end
        if isfield(histFileStruct,'tagData')
            tagData=histFileStruct.tagData;
        end
        if isfield(histFileStruct,'filtersData')
            filtersData=histFileStruct.filtersData;
        end

    else
        oldHistFileName=getOldHistFileName();
        if exist(oldHistFileName,'file')
            histFileStruct=load(oldHistFileName);
            if isfield(histFileStruct,'histData')
                histData=histFileStruct.histData(1,:)';
                for i=1:length(histData)
                    histData{i,2}='other';
                end
            end
        end
    end
end

function result=getOldHistFileName()
    result=fullfile(prefdir,'RMIHistData.mat');
end

function result=getHistFileName()
    result=fullfile(prefdir,'RMIHist.mat');
end

function result=isBuiltinType(linkType)
    result=false;
    regTargets=rmi.settings_mgr('get','regTargets');

    regCnt=length(regTargets);
    if(regCnt>0)&&regTargets{1}(1)=='%'
        regCnt=regCnt-1;
    end
    docSystems=rmi.linktype_mgr('all');
    builtInCnt=length(docSystems)-regCnt;
    for docSystem=docSystems(1:builtInCnt)
        if docSystem==linkType
            result=true;
            return;
        end
    end
end
