function bList=sortBlocks(c,bList,sortBy)






    if isempty(bList)
        bList={};
        return;
    end
    if nargin<3
        sortBy=c.SortBy;
    end

    switch sortBy
    case 'runtime'
        if iscell(bList)
            mdl=bdroot(bList{1});
        else
            mdl=bdroot(bList(1));
        end

        simList=locGetSystemSortedList(mdl,bList);
        if~isempty(simList)
            [sameBlocks,indexA]=intersect(simList,bList);
            bList=simList(sort(indexA));
        end

    case 'fullpathalpha'
        if iscell(bList)
            sysList=bList;
        else
            sysList=locHandlesToNames(bList);
        end
        [sysList,sysIndex]=sort(lower(sysList));
        bList=bList(sysIndex);

    case 'systemalpha'
        sysList=rptgen.safeGet(...
        rptgen.safeGet(bList,'Parent','get_param'),...
        'Name',...
        'get_param');
        [sysList,sysIndex]=sort(lower(sysList));
        bList=bList(sysIndex);

    case 'alphabetical'
        nameList=rptgen.safeGet(bList,'Name','get_param');
        [nameList,nameIndex]=sort(lower(nameList));
        bList=bList(nameIndex);

    case 'blocktype'
        typeList=rptgen.safeGet(bList,'BlockType','get_param');
        [sortedTypeList,sortIndex]=sort(typeList);
        bList=bList(sortIndex);

    case 'depth'
        depthList=getPropValue(...
        rptgen_sl.propsrc_sl_blk,...
        bList,'Depth');

        okEntries=find(cellfun('isclass',depthList,'double'));
        bList=bList(okEntries);

        [depthList,depthIndex]=sort([depthList{okEntries}]);
        bList=bList(depthIndex);

    case{'lefttoright','ltr','toptobottom','ttb'}

        bList=locSortByPosition(bList,sortBy);

    otherwise


    end

    bList=bList(:);


    function names=locHandlesToNames(handles)

        names=[];
        if~isempty(handles)
            handles=handles(ishandle(handles));
            names=strrep(getfullname(handles),sprintf('\n'),' ');
        end


        function bList=locGetSystemSortedList(sysName,originalList)


            slErr=sllasterror;
            try
                bList=rptgen_sl.getSystemBlockSortedList(sysName);
                bList=locHandlesToNames(bList);

                rptgen.displayMessage(getString(message('RptgenSL:rsl_csl_blk_loop:nonAtomicSubsystemsUnsortableLabel')),3);


                bList=locReintegrateSubsystems(bList,originalList);
            catch ME

                bList=[];
                rptgen.displayMessage(ME.message,2);


                sllasterror(slErr);
            end

            function bList=locReintegrateSubsystems(bList,subsysList)


                subsysList=subsysList(~ismember(subsysList,bList));

                for i=1:length(subsysList)

                    for j=1:length(bList)

                        curObj=get_param(bList{j},'object');

                        if(strcmp(subsysList{i},curObj.Path))
                            bList=[bList;subsysList{i}];%#ok - This is not growing at a 



                            break;
                        end;
                    end;
                end;


















                function bList=locSortByPosition(bList,type)


                    if(strcmpi(type,'lefttoright')||strcmpi(type,'ltr'))
                        majorValue=1;
                        minorValue=2;
                    else
                        majorValue=2;
                        minorValue=1;
                    end;

                    allPositions=rptgen.safeget(bList,'Position','get_param');





                    newPositions=zeros(length(allPositions),3);


                    for i=1:length(allPositions)
                        newPositions(i,1)=allPositions{i}(majorValue);
                    end;



                    newPositions(:,2)=locCreatePartition(allPositions,minorValue);




                    maxMajorVal=max(newPositions(:,1));
                    newPositions(:,3)=maxMajorVal*newPositions(:,2)+newPositions(:,1);


                    [dummy,I]=sort(newPositions(:,3));


                    bList=bList(I);













                    function newPositions=locCreatePartition(allPositions,partitionAxis)









                        partition=[];
                        positionMap=zeros(length(allPositions),1);
                        numPartitions=0;



                        avgSize=0;
                        for i=1:length(allPositions)
                            avgSize=avgSize...
                            +allPositions{i}(partitionAxis+2)...
                            -allPositions{i}(partitionAxis);
                        end;
                        avgSize=avgSize/length(allPositions);


                        for i=1:length(allPositions)


                            curPosMin=allPositions{i}(partitionAxis);
                            curPosMax=curPosMin+avgSize;


                            for j=1:numPartitions

                                partitionMin=partition(j,1);
                                partitionMax=partition(j,2);



                                if((curPosMin>=partitionMin&&curPosMin<=partitionMax)||...
                                    (curPosMax>=partitionMin&&curPosMax<=partitionMax)||...
                                    (partitionMin>=curPosMin&&partitionMin<=curPosMax)||...
                                    (partitionMax>=curPosMin&&partitionMax<=curPosMax))


                                    positionMap(i)=j;


                                    partition(j,1)=min(partitionMin,curPosMin);%#ok
                                    partition(j,2)=max(partitionMax,curPosMax);%#ok - These are erroneous warnings

                                    break;
                                end;
                            end;


                            if(positionMap(i)<=0)

                                numPartitions=numPartitions+1;
                                positionMap(i)=numPartitions;
                                partition(numPartitions,:)=[curPosMin,curPosMax];%#ok - This is not growing at a 


                            end;
                        end;

                        newPositions=partition(positionMap,1);
