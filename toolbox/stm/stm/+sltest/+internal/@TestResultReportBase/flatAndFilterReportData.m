function flatAndFilterReportData(obj)





    nInputResultObjs=length(obj.content);
    if(nInputResultObjs>1)
        for resultIdx=1:nInputResultObjs
            if(strcmp(class(obj.content{resultIdx}),'sltest.testmanager.Resultset'))
                error(message('stm:reportOptionDialogText:OnlySupportMultipleResultSet'));
            end
        end
    end
    obj.ResultObjList={};
    for resultIdx=1:nInputResultObjs
        [resultObjectList,parentIndexList,depthList]=...
        sltest.testmanager.ReportUtility.flatResultObject(obj.content{resultIdx});

        nNode=length(resultObjectList);
        tmpList=repmat(struct('data',[],...
        'depth',0,...
        'parentIndex',-1,...
        'UID',''),nNode,1);

        for k=1:length(resultObjectList)
            node=resultObjectList{k};
            tmpList(k).data=node;
            tmpList(k).depth=depthList(k);
            tmpList(k).parentIndex=parentIndexList(k);
            tmpList(k).UID=sprintf('Node%d_%d',resultIdx,k);
        end
        resultNodeList=obj.filterResultSet(tmpList,obj.IncludeTestResults);
        if(isempty(resultNodeList))
            obj.ResultObjList{end+1}=[];
            continue;
        end

        nNode=length(resultNodeList);

        reportData=sltest.testmanager.ReportUtility.ReportResultData;
        tmpList=repmat(reportData,nNode,1);
        for k=1:length(resultNodeList)
            tmpList(k).Data=resultNodeList(k).data;
            tmpList(k).IndentLevel=resultNodeList(k).depth;
            tmpList(k).UID=resultNodeList(k).UID;
            tmpList(k).ParentResultName='';
            tmpList(k).ParentResultUID='';
            if(resultNodeList(k).parentIndex>0)
                parentIdx=resultNodeList(k).parentIndex;
                tmpList(k).ParentResultName=resultNodeList(parentIdx).data.Name;
                tmpList(k).ParentResultUID=resultNodeList(parentIdx).UID;
            end
        end
        obj.ResultObjList{end+1}=tmpList;
    end

    hasNoData=true;
    for k=1:length(obj.ResultObjList)
        if(~isempty(obj.ResultObjList{k}))
            hasNoData=false;
            break;
        end
    end
    if(hasNoData)
        if(obj.IncludeTestResults==0)
            error(message('stm:reportOptionDialogText:EmptyDataForReport'));
        elseif(obj.IncludeTestResults==1)
            error(message('stm:reportOptionDialogText:EmptyDataForReportPassed'));
        elseif(obj.IncludeTestResults==2)
            error(message('stm:reportOptionDialogText:EmptyDataForReportFailed'));
        end
    end
end
