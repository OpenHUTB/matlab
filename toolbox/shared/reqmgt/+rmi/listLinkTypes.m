function list=listLinkTypes



    regLinkTypes=rmi.settings_mgr('get','regTargets');


    regCnt=length(regLinkTypes);
    if(regCnt>0)&&regLinkTypes{1}(1)=='%'
        regCnt=regCnt-1;
    end

    uddList=rmi.linktype_mgr('all');
    totalCnt=length(uddList);
    builtinCount=totalCnt-regCnt;

    typeVals={'Built-in','Custom'};
    typeColumn={'Type:'};
    mfileColumn={'Registration MATLAB-file:'};
    extColumn={'File extensions:'};

    for idx=1:totalCnt
        typeColumn(end+1)=typeVals(1+(idx<=(totalCnt-builtinCount)));

        validExts=uddList(idx).Extensions;
        if~isempty(validExts)
            extCnt=length(validExts);
            validExts(1:2:(2*extCnt-1))=validExts;
            validExts(2:2:end)={' '};
            extStr=[validExts{:}];
        else
            extStr='';
        end
        extColumn{end+1}=extStr;%#ok<*AGROW>

        mfileColumn{end+1}=which(uddList(idx).Registration);
        if isempty(mfileColumn{end})

            packages={'linktypes','oslc','rmism'};
            for i=1:numel(packages)
                regPkgMethod=[packages{i},'.',uddList(idx).Registration];
                whereFound=which(regPkgMethod);
                if~isempty(whereFound)
                    mfileColumn{end}=whereFound;
                    break;
                end
            end
        end
    end

    spaceCol=char(32*ones(length(typeColumn),2));
    info=[char(typeColumn(:)),spaceCol,char(mfileColumn(:)),spaceCol,char(extColumn(:))];
    if nargout<1
        disp(' ');
        disp(info);
        disp(' ');
    else
        list=info;
    end
