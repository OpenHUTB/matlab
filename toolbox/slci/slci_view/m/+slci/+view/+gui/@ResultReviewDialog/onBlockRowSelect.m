


function onBlockRowSelect(obj,data)


    src=slci.view.internal.getSource(obj.getStudio);


    if~isempty(data)
        sid=data.sid;


        if slcifeature('SLCIJustification')==1
            conf=slci.toolstrip.util.getConfiguration(obj.getStudio);
            fname=fullfile(conf.getReportFolder(),[conf.getModelName(),'_justification.json']);

            modelManager=slci.view.ModelManager(fname);
            justificationObj=modelManager.getJustificationManager(sid);

            tempCodeLinesForSid=justificationObj.getCodeLines();
            if~isempty(tempCodeLinesForSid)
                spiltCodeLines=split(tempCodeLinesForSid,"-");
                codeLinesForSid=spiltCodeLines(2);
                tempFileName=split(codeLinesForSid,':');
                fileName=tempFileName(1);
                codeLinesForSid=split(tempFileName(2),',');

            end


            if isempty(tempCodeLinesForSid)
                slci.view.internal.hiliteBlockAndCode(src.modelName,sid);
            else
                slci.view.internal.hiliteJustifiedBlockAndCode(src.modelName,...
                sid,codeLinesForSid,fileName);
            end







            obj.setMsgForJustificationDialog('');

            key=strcat('Slci:slcireview:JustificationModel',getStatusCategory(data.status));
            if~contains(sid,':')
                obj.setMsgForJustificationDialog(DAStudio.message(key));
            end

            if contains(sid,':')&&strcmpi(getStatusCategory(data.status),'PassedOrFailed')
                key=strcat('Slci:slcireview:JustificationBlock',getStatusCategory(data.status));
                obj.setMsgForJustificationDialog(DAStudio.message(key));
            end

            data.dataFor="blockGrid";
            vm=slci.view.Manager.getInstance;
            vw=vm.getView(obj.getStudio);
            ds=vw.getJustification();

            if(ds.hasDialog()&&ds.getStatus())
                obj.getJustificationForSid(data);
            end
        else

            slci.view.internal.hiliteBlockAndCode(src.modelName,sid);
        end

    end

end


function out=getStatusCategory(status)
    statusList={'VERIFIED','FAILED_TO_VERIFY','FAILED','UNEXPECTEDDEF','PASSED'};

    if any(contains(statusList,status))
        out='PassedOrFailed';
        return;
    end

    if strcmpi(status,'JUSTIFIED')
        out='Justified';
        return;
    end

    out='Warning';
end