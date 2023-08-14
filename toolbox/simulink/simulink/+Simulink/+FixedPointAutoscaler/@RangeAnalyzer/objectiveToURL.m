function[url,isSFRecord,instanceHdl]=objectiveToURL(obj,objective)





    modelObject=obj.rangeData.ModelObjects(objective.modelObjectIdx);

    isSFRecord=false;
    instanceHdl=[];


    if strcmp(modelObject.descr,'DefaultBlockDiagram')
        url=[];
        return;
    end

    if~isempty(objective.emlVarId)
        id=obj.rangeData.EmlIdInfo(objective.emlVarId);
        url=Simulink.URL.Base.constructURL(id.MATLABFunctionIdentifier.SID);
        isSFRecord=false;
        instanceHdl=getInstanceHdl(modelObject);
        return;
    end




    portNumber=objective.outcomeValue;

    elementHandle=Simulink.ID.getHandle(modelObject.designSid);

    if isa(elementHandle,'Stateflow.State')||...
        isa(elementHandle,'Stateflow.Message')

        url=[];
        return;
    end

    if isa(elementHandle,'Stateflow.Data')
        url=int2str(elementHandle.Id);
        isSFRecord=true;
        instanceHdl=getInstanceHdl(modelObject);
        return;
    end

    blkObj=get_param(elementHandle,'Object');
    if isa(blkObj,'Simulink.BlockDiagram')
        url=[];
        return;
    end

    elementHandle=doPotentialElementHandleRecalculation(blkObj,modelObject,elementHandle);

    if elementHandle==-1





        url=[];
        return
    end

    if strcmpi(objective.type,'Design Range')


        portNumber=1;
    else



        if portNumber<1
            url=[];
            return
        end
    end

    instanceHdl=getInstanceHdl(modelObject);


    url=getBlockOutportURL(elementHandle,portNumber);


    function instanceHdl=getInstanceHdl(modelObject)

        if isfield(modelObject,'replacementSid')&&~isempty(modelObject.replacementSid)
            instanceHdl=Simulink.ID.getHandle(modelObject.replacementSid);
        else
            instanceHdl=[];
        end

        function elementHandle=doPotentialElementHandleRecalculation(blkObj,modelObject,elementHandle)



            if isa(blkObj,'Simulink.SubSystem')&&~slprivate('is_stateflow_based_block',blkObj.Handle)


                if strcmpi(modelObject.typeDesc,'Inport')||strcmpi(modelObject.typeDesc,'Outport')

















                    subsystemName=blkObj.getFullName;
                    portBlkRawDescr=modelObject.descr;


                    matchExpr=sprintf('\\<(%s/){1}',blkObj.Name);
                    portBlkCleanedUp=regexprep(portBlkRawDescr,matchExpr,'','once');
                    blkName=[subsystemName,'/',portBlkCleanedUp];
                    elementHandle=getSimulinkBlockHandle(blkName);
                end








                if strcmpi(modelObject.typeDesc,'S-Function')
                    blkName=fileparts(modelObject.slPath);
                    elementHandle=get_param(blkName,'handle');
                end
            end
