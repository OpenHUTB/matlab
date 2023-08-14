function[recordCellArray,taskCellArray,TaskAdvisorCellArray,ResultDetailsCellArray]=prepareMAData(obj)




    recordCellArray=modeladvisorprivate('modeladvisorutil2','CopyObjToStruct',...
    obj.MAObj.CheckCellArray,{'ID','Title','Visible','Enable','Value','RunComplete','Selected','Success','status','ResultInHTML','InputParameters','ErrorSeverity','ActionResultInHTML','ProjectResultData','ReportStyle','CacheResultInHTMLForNewCheckStyle'});



    taskCellArray=modeladvisorprivate('modeladvisorutil2','CopyObjToStruct',...
    obj.MAObj.TaskCellArray,{'DisplayName','Visible','Enable','Value','Failed','State','Selected','InternalState'});

    TaskAdvisorCellArray=modeladvisorprivate('modeladvisorutil2','CopyObjToStruct',...
    obj.MAObj.TaskAdvisorCellArray,{'ID','Visible','Enable','Value','Failed','State','Selected','InternalState','StateIcon','InputParameters','Check','RunTime'});

    ResultDetailsCellArray={};
    fastReference=obj.MAObj.TaskAdvisorCellArray;
    for i=1:numel(fastReference)
        currentNode=fastReference{i};
        if isa(currentNode,'ModelAdvisor.Task')&&~isempty(currentNode.Check)
            for j=1:numel(currentNode.Check.ResultDetails)
                resultDetailObj=currentNode.Check.ResultDetails(j);
                ResultDetailsCellArray{end+1}=ModelAdvisor.ResultDetail.toStruct(resultDetailObj);%#ok<AGROW>
            end
        end
    end

end