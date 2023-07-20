function resultJSON=importBlkTypeCallback(allInputParameters,originalNodeID,index)

    ipList=allInputParameters;
    blkTypeTableIndex=-1;
    for i=1:numel(ipList)
        if strcmp(ipList(i).type,'BlockType')
            index=index-1;
            if(index<0)
                blkTypeTableIndex=i;
                break;
            end
        end
    end
    BlkListInterpretionMode=[];
    for i=1:numel(ipList)
        if strcmp(ipList(i).name,'Treat blocktype list as')
            BlkListInterpretionMode=strcmp('Prohibited',ipList(i).value);
            break;
        end
    end

    tempCopy=ModelAdvisorWebUI.interface.createConfigUIObj(allInputParameters,originalNodeID);
    if~isempty(tempCopy)
        foundBlkListInterpretionModeParam=false;

        dlgObj=ModelAdvisor.ImportBlkTypeDialog.getInstance();
        if foundBlkListInterpretionModeParam
            if BlkListInterpretionMode==dlgObj.BlkListInterpretionMode
                needUpdateDialog=false;
            else
                needUpdateDialog=true;
            end
        else
            needUpdateDialog=false;
        end
        if needUpdateDialog
            dlgObj.BlkListInterpretionMode=BlkListInterpretionMode;
            dlgObj.BlkTypeSource=DAStudio.message('ModelAdvisor:engine:Library');
            dlgObj.syncInternalValues('write');
        end
        dlgs=DAStudio.ToolRoot.getOpenDialogs(dlgObj);
        if isa(dlgs,'DAStudio.Dialog')
            dlgs.show;
        else
            dlgObj.TaskNode=tempCopy;
            dlgObj.InputParameter=tempCopy.InputParameters{blkTypeTableIndex};

            DAStudio.Dialog(dlgObj);
            dlgs=DAStudio.ToolRoot.getOpenDialogs(dlgObj);
        end
    end

    waitfor(dlgs);

    checkObjJSON=Advisor.Utils.exportJSON(tempCopy,'MACE');
    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','','value',checkObjJSON);
    resultJSON=jsonencode(result);
end
