


function sendData(obj)

    src=slci.view.internal.getSource(obj.getStudio);

    rtwNames=keys(obj.fBlockData);
    blockData={};
    for i=1:numel(rtwNames)
        data={};
        data.rtwName=rtwNames{i};
        values=obj.fBlockData(rtwNames{i});
        data.codeLines=values.codelines;
        data.parent=values.parent;
        data.status=values.status;
        data.sid=values.sid;
        blockData{end+1}=data;%#ok
    end


    if slcifeature('SLCIJustification')==1
        conf=slci.toolstrip.util.getConfiguration(obj.getStudio);


        fname=fullfile(conf.getReportFolder(),[conf.getModelName(),'_justification.json']);
        if~isfile(fname)

            mfmodel=mf.zero.Model;

            manager=advisor.filter.SlciFilterManager(mfmodel);


            serializer=mf.zero.io.JSONSerializer;
            serializer.serializeToFile(mfmodel,fname);
        end
        fid=fopen(fname);
        raw=fread(fid,inf);
        fclose(fid);
        str=char(raw');
        msg.msgID='sendJSON';
        name=obj.getUsername();
        msg.data=struct('user',name,'jsonText',str);

        message.publish(obj.getChannel,msg);
    end


    msg.model=src.modelName;
    msg.msgID='reloadData';
    msg.status=obj.fStatus;
    msg.type='OverallStatus';
    message.publish(obj.getChannel,msg);


    msg.type='InspectionSummary';
    msg.data=obj.fInspectionSummaryData;
    message.publish(obj.getChannel,msg);

    msg.type='Block';
    msg.data=blockData;
    msg.aggrStatus=obj.fBlockStatus;
    message.publish(obj.getChannel,msg);

    msg.data=obj.fCodeSliceData;
    msg.aggrStatus=obj.fCodeStatus;
    msg.type='CodeSlice';
    message.publish(obj.getChannel,msg);

    msg.data=obj.fInterfaceData;
    msg.aggrStatus=obj.fInterfaceStatus;
    msg.type='Interface';
    message.publish(obj.getChannel,msg);

    msg.data=obj.fTempVarData;
    msg.aggrStatus=obj.fTempVarStatus;
    msg.type='TempVar';
    message.publish(obj.getChannel,msg);

    msg.data=obj.fUtilFuncData;
    msg.aggrStatus=obj.fUtilFuncStatus;
    msg.type='UtilFunc';
    message.publish(obj.getChannel,msg);

    if slcifeature('SLCIJustification')==1&&isequal(obj.getDeleteStatusFlag,true)
        msg.data=obj.fJsonDataAfterDelete;
        msg.type='DeleteStatus';
        message.publish(obj.getChannel,msg);
    end

