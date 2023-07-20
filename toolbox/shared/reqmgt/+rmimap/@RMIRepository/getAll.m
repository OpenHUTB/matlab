function data=getAll(this,varargin)




    data=cell(0,5);
    srcName=varargin{1};
    if exist(srcName,'file')~=2

        [isMatlabFunction,mdlName]=rmisl.isSidString(srcName,false);
        if isMatlabFunction
            try


                load_system(mdlName);
            catch
                error('Invalid srcName in call to RMIRepository:getAll(): %s',srcName);
            end
        else
            return;
        end
    end

    srcRoot=rmimap.RMIRepository.getRoot(this.graph,srcName);
    if~isempty(srcRoot)
        ids=srcRoot.getProperty('rangeLabels');
        if isempty(ids)
            return;
        end
        starts=srcRoot.getProperty('rangeStarts');
        ends=srcRoot.getProperty('rangeEnds');
        [startPositions,endPositions,idStrings]=rmiut.RangeUtils.convert(starts,ends,ids);
        if length(varargin)==1
            totalItems=length(idStrings);
            data=cell(totalItems,5);
            data(:,1)=idStrings';
            matchingStarts=startPositions;
            matchingEnds=endPositions;
        else
            isMatched=strcmp(idStrings,varargin{2});
            if any(isMatched)
                matchedId=idStrings(isMatched);
                matchingStarts=startPositions(isMatched);
                matchingEnds=endPositions(isMatched);
                if length(matchedId)==1
                    totalItems=1;
                    data=cell(1,5);
                    data(1,1)=matchedId;
                else
                    warning('ERROR: Duplicate ID matched in %s',srcName);
                    return;
                end
            else

                return;
            end
        end
        if totalItems>0
            filters=rmi.settings_mgr('get','filterSettings');
            isRemoved=false(totalItems,1);
            for i=1:totalItems
                data(i,2:3)={matchingStarts(i),matchingEnds(i)};
                if data{i,3}==0


                    isRemoved(i)=true;
                    continue;
                end

                allLabels='';
                allEnabled=true(1,0);
                elt=rmimap.RMIRepository.getNode(srcRoot,data{i,1});
                if~isempty(elt)
                    links=elt.dependeeLinks;
                    allEnabled=true(1,links.size);
                    if~isempty(links)&&links.size~=0


                        for j=1:links.size
                            link=links.at(j);
                            description=link.getProperty('description');
                            if isempty(description)
                                description=getString(message('Slvnv:reqmgt:NoDescriptionEntered'));
                            else



                                description(description==9)=' ';
                                description(description==10)=' ';
                            end
                            description=strtrim(description);
                            if filters.enabled&&~userTagMatch(link,filters.tagsRequire,filters.tagsExclude)
                                allEnabled(j)=false;

                                description=[' ',description];%#ok<AGROW>
                            end
                            allLabels=sprintf('%s\n%s',allLabels,description);
                        end
                    end
                end
                if isempty(allLabels)


                    data{i,4}=char(com.mathworks.toolbox.simulink.slvnv.RmiUtils.NO_LINKS_TAG);
                    data{i,5}=[];
                else
                    data{i,4}=allLabels(2:end);
                    data{i,5}=allEnabled;
                end
            end
            if any(isRemoved)
                data(isRemoved,:)=[];
            end
        end
    end
end

function result=userTagMatch(link,filter_in,filter_out)


    keywordsString=strtrim(link.getProperty('keywords'));
    if isempty(keywordsString)
        result=isempty(filter_in);
    else
        keywords=rmiut.strToCell(keywordsString);
        i=1;
        while i<=length(filter_out)
            if any(strcmp(keywords,filter_out{i}))
                result=false;
                return;
            else
                i=i+1;
            end
        end
        i=1;
        while i<=length(filter_in)
            if any(strcmp(keywords,filter_in{i}))
                i=i+1;
            else
                result=false;
                return;
            end
        end

        result=true;
    end
end



