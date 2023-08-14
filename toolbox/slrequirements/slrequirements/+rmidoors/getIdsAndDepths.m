function[allIDs,depths]=getIdsAndDepths(moduleIdStr,filter)












    if nargin<2
        filter={};
    end

    hDoors=rmidoors.comApp();
    if isempty(hDoors)
        error(message('Slvnv:rmiref:DocCheckDoors:DoorsNotRunning'));
    end

    exportedFile=getTempFileName(0);
    workFile=exportedFile;
    cmdStr=['exportIdsAndParents_("',moduleIdStr,'","',escapeForDoors(exportedFile),'")'];
    rmidoors.invoke(hDoors,cmdStr);

    doFilter=~isempty(filter);
    isUI=rmiut.progressBarFcn('exists');
    if doFilter
        totalFilters=size(filter,1);
        for i=1:totalFilters
            attrName=filter{i,1};
            attrValue=filter{i,2};
            if isUI
                rmiut.progressBarFcn('set',0.8*i/totalFilters,...
                getString(message('Slvnv:slreq_import:CheckingForAttribute',attrName)));
            end
            filteredFile=getTempFileName(i);
            cmdStr=['filterIdsAndParents_("',moduleIdStr,'","'...
            ,escapeForDoors(workFile),'","',escapeForDoors(filteredFile),'","'...
            ,attrName,'","',attrValue,'")'];
            rmidoors.invoke(hDoors,cmdStr);
            workFile=filteredFile;
        end
    end

    fid=fopen(workFile);
    fromDOORS=fscanf(fid,'%d\n',[3,inf])';
    fclose(fid);

    allIDs=fromDOORS(:,1);
    depths=zeros(size(allIDs));
    included=sum(fromDOORS(:,3));

    if isUI
        rmiut.progressBarFcn('set',0.9,...
        getString(message('Slvnv:slreq_import:CheckingForParents')));
    end


    parentMap=containers.Map('KeyType','double','ValueType','double');
    indexMap=containers.Map('KeyType','double','ValueType','double');
    depthsMap=containers.Map('KeyType','double','ValueType','double');

    totalItems=length(allIDs);
    tableParent=0;
    for i=1:totalItems

        id=fromDOORS(i,1);
        indexMap(id)=i;


        parent=fromDOORS(i,2);




        if parent>0&&~any(fromDOORS(1:i-1,1)==parent)




            if tableParent==0
                parent=fromDOORS(i-1,1);
                tableParent=parent;
            else
                parent=tableParent;
            end
        else
            tableParent=0;
        end
        parentMap(id)=parent;
        if parent==0
            depthsMap(id)=0;
        else
            depth=depthsMap(parent)+1;
            depthsMap(id)=depth;
            depths(i)=depth;
        end

        if included<totalItems

            if fromDOORS(i,3)
                while parent>0
                    parentIdx=indexMap(parent);
                    if fromDOORS(parentIdx,3)
                        break;
                    else
                        fromDOORS(parentIdx,3)=1;
                        included=included+1;
                        parent=parentMap(parent);
                    end
                end
            end
        end
    end


    filteredIdx=(fromDOORS(:,3)==0);
    if any(filteredIdx)
        allIDs(filteredIdx)=[];
        depths(filteredIdx)=[];
    end
end

function fPathName=getTempFileName(step)
    fName=sprintf('doors_import_%d.tmp',step);
    rmiTempDir=fullfile(tempdir,'RMI');
    if~step&&~isfolder(rmiTempDir)
        mkdir(rmiTempDir);
    end
    fPathName=fullfile(rmiTempDir,fName);
end

function escaped=escapeForDoors(filepath)

    escaped=strrep(filepath,'\','\\');
end

