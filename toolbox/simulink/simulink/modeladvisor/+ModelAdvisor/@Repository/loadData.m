


function[value,ObjectIndex]=loadData(obj,tablename,varargin)
    PerfTools.Tracer.logMATLABData('MAGroup','Database LoadData',true);

    obj.reconnect;
    value=[];
    origtablename=tablename;
    PerfTools.Tracer.logMATLABData('MAGroup','sdi.Repository getProperty',true);
    switch lower(tablename)
    case{'allrptinfo','geninfo'}
        tempObjIndex=[];
        tablename='mdladv.ReportsInfo';
        if~isempty(obj.SID)
            ObjectIndex=obj.DatabaseHandle.findObjects(tablename,'SID',obj.SID,varargin{:});
        else
            ObjectIndex=obj.DatabaseHandle.findObjects(tablename,varargin{:});
        end
        for i=1:length(ObjectIndex)



            if strcmp(origtablename,'geninfo')
                if strcmp(obj.DatabaseHandle.getProperty(ObjectIndex(i),'reportName'),'report.html')
                    addthisone=true;
                else
                    addthisone=false;
                end
            else
                if strcmp(obj.DatabaseHandle.getProperty(ObjectIndex(i),'reportName'),'report.html')
                    addthisone=false;
                else
                    addthisone=true;
                end
            end
            if addthisone
                value(end+1).allCt=obj.DatabaseHandle.getProperty(ObjectIndex(i),'allCt');%#ok<AGROW>
                value(end).passCt=obj.DatabaseHandle.getProperty(ObjectIndex(i),'passCt');
                value(end).warnCt=obj.DatabaseHandle.getProperty(ObjectIndex(i),'warnCt');
                value(end).failCt=obj.DatabaseHandle.getProperty(ObjectIndex(i),'failCt');
                value(end).nrunCt=obj.DatabaseHandle.getProperty(ObjectIndex(i),'nrunCt');
                value(end).generateTime=obj.DatabaseHandle.getProperty(ObjectIndex(i),'generateTime');
                value(end).reportName=obj.DatabaseHandle.getProperty(ObjectIndex(i),'reportName');
                value(end).fromTaskAdvisorNode=obj.DatabaseHandle.getProperty(ObjectIndex(i),'fromTaskAdvisorNode');
                value(end).Index=obj.DatabaseHandle.getProperty(ObjectIndex(i),'Index');
                tempObjIndex(end+1)=ObjectIndex(i);%#ok<AGROW>                          
            end
        end
        ObjectIndex=tempObjIndex;
    case 'mdladvinfo'
        tablename='mdladv.MdladvInfo';
        if~isempty(obj.SID)
            ObjectIndex=obj.DatabaseHandle.findObjects(tablename,'SID',obj.SID,varargin{:});
        else
            ObjectIndex=obj.DatabaseHandle.findObjects(tablename,varargin{:});
        end
        for i=1:length(ObjectIndex)
            value(end+1).cacheResetData=obj.DatabaseHandle.getProperty(ObjectIndex(i),'cacheResetData');%#ok<AGROW>
            value(end).callbackFuncInfoStruct=obj.DatabaseHandle.getProperty(ObjectIndex(i),'callbackFuncInfoStruct');
            value(end).StartInTaskPage=obj.DatabaseHandle.getProperty(ObjectIndex(i),'StartInTaskPage');
            value(end).CustomTARootID=obj.DatabaseHandle.getProperty(ObjectIndex(i),'CustomTARootID');
            value(end).R2FInfo=obj.DatabaseHandle.getProperty(ObjectIndex(i),'R2FInfo');
            value(end).path=obj.DatabaseHandle.getProperty(ObjectIndex(i),'path');
            value(end).ConfigFilePathInfo=obj.DatabaseHandle.getProperty(ObjectIndex(i),'ConfigFilePathInfo');
            value(end).TaskAdvisorCellArray=obj.DatabaseHandle.getProperty(ObjectIndex(i),'TaskAdvisorCellArray');
            value(end).MAExplorerPosition=obj.DatabaseHandle.getProperty(ObjectIndex(i),'MAExplorerPosition');
            value(end).recordCellArray=obj.DatabaseHandle.getProperty(ObjectIndex(i),'recordCellArray');
            value(end).taskCellArray=obj.DatabaseHandle.getProperty(ObjectIndex(i),'taskCellArray');



            if~isempty(obj.MAObj)&&obj.MAObj.runInBackground
                value(end).ResultMap=obj.DatabaseHandle.getProperty(ObjectIndex(i),'ResultMap');
            end
        end
    case 'parallelinfo'
        tablename='mdladv.ParallelInfo';
        if isempty(obj.DatabaseHandle)
            return;
        end
        if~isempty(obj.SID)
            ObjectIndex=obj.DatabaseHandle.findObjects(tablename,'SID',obj.SID,varargin{:});
        else
            ObjectIndex=obj.DatabaseHandle.findObjects(tablename,varargin{:});
        end
        for i=1:length(ObjectIndex)
            value(end+1).system=obj.DatabaseHandle.getProperty(ObjectIndex(i),'system');%#ok<AGROW>
            value(end).sysPath=obj.DatabaseHandle.getProperty(ObjectIndex(i),'sysPath');
            value(end).lastModified=obj.DatabaseHandle.getProperty(ObjectIndex(i),'lastModified');
            value(end).systemName=obj.DatabaseHandle.getProperty(ObjectIndex(i),'systemName');
            value(end).snapshotPath=obj.DatabaseHandle.getProperty(ObjectIndex(i),'snapshotPath');
            value(end).workspaceMat=obj.DatabaseHandle.getProperty(ObjectIndex(i),'workspaceMat');
            value(end).TaskID=obj.DatabaseHandle.getProperty(ObjectIndex(i),'TaskID');
            value(end).pwd=obj.DatabaseHandle.getProperty(ObjectIndex(i),'pwd');
            value(end).orderedTaskIndex=obj.DatabaseHandle.getProperty(ObjectIndex(i),'orderedTaskIndex');
            value(end).index=obj.DatabaseHandle.getProperty(ObjectIndex(i),'index');
            value(end).cancel=obj.DatabaseHandle.getProperty(ObjectIndex(i),'cancel');
            value(end).status=obj.DatabaseHandle.getProperty(ObjectIndex(i),'status');



            value(end).sysPath=value(end).sysPath{1};
            value(end).system=value(end).system{1};
            value(end).systemName=value(end).systemName{1};
            value(end).snapshotPath=value(end).snapshotPath{1};
            value(end).workspaceMat=value(end).workspaceMat{1};
            value(end).pwd=value(end).pwd{1};
            if~isempty(value(end).status)
                value(end).status=value(end).status{1};
            end


        end
    case 'resultdetails'
        tablename='mdladv.ResultDetails';
        if isempty(obj.DatabaseHandle)
            return;
        end
        ObjectIndex=obj.DatabaseHandle.findObjects(tablename,varargin{:},'-unicode');
        if numel(ObjectIndex)>0
            clear value;
        end

        for i=1:numel(ObjectIndex)











            rdObj=ModelAdvisor.ResultDetail;
            rdObj.ID=obj.DatabaseHandle.getProperty(ObjectIndex(i),'ID');
            rdObj.Data=obj.DatabaseHandle.getProperty(ObjectIndex(i),'Data');
            rdObj.setType(ModelAdvisor.ResultDetailType(obj.DatabaseHandle.getProperty(ObjectIndex(i),'Type')));
            rdObj.IsInformer=obj.DatabaseHandle.getProperty(ObjectIndex(i),'IsInformer');
            rdObj.IsViolation=obj.DatabaseHandle.getProperty(ObjectIndex(i),'IsViolation');
            rdObj.Description=loc_convertEmptyToStr(obj.DatabaseHandle.getProperty(ObjectIndex(i),'Description',true));
            rdObj.Title=loc_convertEmptyToStr(obj.DatabaseHandle.getProperty(ObjectIndex(i),'Title',true));
            rdObj.Information=loc_convertEmptyToStr(obj.DatabaseHandle.getProperty(ObjectIndex(i),'Information',true));
            rdObj.Status=loc_convertEmptyToStr(obj.DatabaseHandle.getProperty(ObjectIndex(i),'Status',true));
            rdObj.RecAction=loc_convertEmptyToStr(obj.DatabaseHandle.getProperty(ObjectIndex(i),'RecAction',true));
            rdObj.Tags=loc_convertEmptyToStr(obj.DatabaseHandle.getProperty(ObjectIndex(i),'Tags',true));
            rdObj.Severity=loc_convertEmptyToStr(obj.DatabaseHandle.getProperty(ObjectIndex(i),'Severity'));
            rdObj.TaskID=loc_convertEmptyToStr(obj.DatabaseHandle.getProperty(ObjectIndex(i),'TaskID',true));
            rdObj.CheckID=loc_convertEmptyToStr(obj.DatabaseHandle.getProperty(ObjectIndex(i),'CheckID'));
            rdObj=loadDetailedInfo(rdObj,obj,ObjectIndex(i));
            rdObj.CustomData=obj.DatabaseHandle.getProperty(ObjectIndex(i),'CustomData');
            value(i)=rdObj;
            if value(i).Type==ModelAdvisor.ResultDetailType.Constraint
                ModelAdvisor.ResultDetail.setData(value(i),'Constraint',value(i).CustomData);
                value(i).CustomData=[];%#ok<AGROW>
            end
            if value(i).Type==ModelAdvisor.ResultDetailType.Group
                ModelAdvisor.ResultDetail.setData(value(i),'Group',value(i).CustomData);
                value(i).CustomData=[];%#ok<AGROW>
            end
        end
    otherwise
        obj.disconnect;
        DAStudio.error('ModelAdvisor:engine:UnkownTableSpecified',tablename);
    end
    PerfTools.Tracer.logMATLABData('MAGroup','sdi.Repository getProperty',false);
    obj.disconnect;
    PerfTools.Tracer.logMATLABData('MAGroup','Database LoadData',false);
end

function inObj=loadDetailedInfo(inObj,obj,ObjectIndex)
    persistent model;
    if isempty(model)
        model=mf.zero.Model;
    end
    resultFactory=ModelAdvisor.ResultDetailFactory(model);
    switch(inObj.Type)
    case ModelAdvisor.ResultDetailType.SID
        Expression=obj.DatabaseHandle.getProperty(ObjectIndex,'Expression');
        Line=obj.DatabaseHandle.getProperty(ObjectIndex,'Line');
        Column=obj.DatabaseHandle.getProperty(ObjectIndex,'Column');
        if~isempty(Expression)||~isempty(Line)||~isempty(Column)
            dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.Mfile);
            dataObj.Expression=Expression;
            dataObj.Line=Line;
            dataObj.Column=Column;
            inObj.DetailedInfo=dataObj;
        end
    case ModelAdvisor.ResultDetailType.ConfigurationParameter
        dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.ConfigurationParameter);
        dataObj.ModelName=obj.DatabaseHandle.getProperty(ObjectIndex,'ModelName');
        dataObj.Parameter=obj.DatabaseHandle.getProperty(ObjectIndex,'Parameter');
        inObj.DetailedInfo=dataObj;
    case ModelAdvisor.ResultDetailType.BlockParameter
        dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.BlockParameter);
        dataObj.Block=obj.DatabaseHandle.getProperty(ObjectIndex,'Block');
        dataObj.Parameter=obj.DatabaseHandle.getProperty(ObjectIndex,'Parameter');
        inObj.DetailedInfo=dataObj;
    case ModelAdvisor.ResultDetailType.Mfile
        dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.Mfile);
        dataObj.FileName=obj.DatabaseHandle.getProperty(ObjectIndex,'FileName');
        dataObj.Expression=obj.DatabaseHandle.getProperty(ObjectIndex,'Expression');
        dataObj.Line=obj.DatabaseHandle.getProperty(ObjectIndex,'Line');
        dataObj.Column=obj.DatabaseHandle.getProperty(ObjectIndex,'Column');
        inObj.DetailedInfo=dataObj;
    end
end

function output=loc_convertEmptyToStr(input)
    output=input;
    if isempty(output)
        output='';
    end
end
