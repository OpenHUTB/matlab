function dsmInfo=getDSMInfo(blockH)




    dsmInfo=struct('dsmBlks',[],'sigObjs',[]);


    mdl=bdroot(getfullname(blockH));


    if~contains(get_param(mdl,'SimulationStatus'),["paused","compiled"])
        if strcmpi(get_param(mdl,'SimulationMode'),'normal')
            compileCmd='compile';
        else
            compileCmd='compileForAccel';
        end
        feval(mdl,[],[],[],compileCmd);
        ocp=onCleanup(@()feval(mdl,[],[],[],'term'));
    end

    blkObj=get_param(blockH,'Object');
    if isa(blkObj,'Simulink.BlockDiagram')



        return;
    end

    dsmBlocks=coder.internal.DataStoreUtils.getNeededDSMInfo(blockH);
    if~isempty(dsmBlocks)
        dsmInfo.dsmBlks=getUsersFromBlock(dsmBlocks',get_param(blockH,'Name'));
    end


    context=getfullname(blockH);

    filterSignals=@(var)(isa(var,'Simulink.Signal')&&~isa(var,'Simulink.Bus'));
    sigsBaseWksp=Simulink.findVars(context,'SearchMethod','cached',...
    'WorkspaceType','base',...
    'ReturnResolvedVar',true,...
    'Value',filterSignals);

    sigsMdlWksp=Simulink.findVars(context,'SearchMethod','cached',...
    'WorkspaceType','model',...
    'ReturnResolvedVar',true,...
    'Value',filterSignals);
    sigVars=[sigsBaseWksp',sigsMdlWksp'];


    dsmInfo.sigObjs=getUsersFromVars(sigVars,get_param(blockH,'Name'));
end

function sigObjs=getUsersFromVars(vars,subsysName)
    sigObjs=[];
    for vbl=vars
        userType=getUserTypesFromBlockPath(vbl.Name,vbl.Users,subsysName);

        if~isempty(userType)
            sigStruct=struct('Name',vbl.Name,...
            'UserType',userType,...
            'SourceType',vbl.SourceType);
            sigObjs=[sigObjs,sigStruct];%#ok<AGROW> 
        end
    end
end

function dsmObjs=getUsersFromBlock(dsmBlocks,subsysName)
    dsmObjs=[];
    for dsmBlk=dsmBlocks
        dsName=get_param(dsmBlk.Handle,'DataStoreName');
        rwInfo=get_param(dsmBlk.Handle,'DSReadWriteBlocks');
        blkPaths={rwInfo.name};
        userType=getUserTypesFromBlockPath(dsName,blkPaths,subsysName);

        if~isempty(userType)
            dsmStruct=struct('Handle',dsmBlk.Handle,...
            'UserType',userType);
            dsmObjs=[dsmObjs,dsmStruct];%#ok<AGROW> 
        end
    end
end

function userType=getUserTypesFromBlockPath(dsName,blockPaths,subsysName)
    userType='';






    for blkPath=blockPaths
        elems=strsplit(blkPath{1},'/');
        parentElems=elems(1:end-1);


        isUnderCUT=any(strcmp(parentElems,subsysName));


        blkType=get_param(blkPath{1},'BlockType');
        if strcmp(blkType,'SubSystem')&&strcmp(get_param(blkPath{1},'SFBlockType'),'Chart')

            blkType=getUserTypeForStateFlowElements(blkPath{1},dsName);
        end
        isUsedAsDataStore=strcmp(blkType,'DataStoreWrite')||strcmp(blkType,'DataStoreRead');



        if isUnderCUT&&isUsedAsDataStore



            if~isempty(userType)&&~strcmp(blkType,userType)
                userType='';
                return
            end
            userType=blkType;
        end
    end
end

function userType=getUserTypeForStateFlowElements(path,dsName)
    if Simulink.harness.internal.doesChartReadDSMem(path,dsName)
        userType='DataStoreRead';
    else
        userType='DataStoreWrite';
    end
end


