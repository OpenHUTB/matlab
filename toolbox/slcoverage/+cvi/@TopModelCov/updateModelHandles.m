function[status,msg]=updateModelHandles(modelId,modelName,updateAllRoots)








    try
        if nargin<3
            updateAllRoots=true;
        end

        updateMasks(modelName);
        machine_update_list('clear');
        status=1;
        msg='';

        allRoots=cv('RootsIn',modelId);
        cv('set',modelId,'.handle',get_param(modelName,'handle'));
        SlCov.CoverageAPI.setModelcovName(modelId,modelName);
        activeRoot=cv('get',modelId,'.activeRoot');
        activePath='';
        if activeRoot~=0
            activePath=cv('GetRootPath',activeRoot);
        end
        oc=restoreLibraryLock(modelName);%#ok<NASGU>
        set_param(modelName,'CoverageId',modelId);
        simMode=cv('get',modelId,'.simMode');
        if SlCov.CovMode.isGeneratedCode(simMode)

            guardRootPrefix=sprintf('%d|',modelId);
        else
            guardRootPrefix='';
        end
        for rootId=allRoots(:)'
            rootPath=cv('GetRootPath',rootId);
            if SlCov.ContextGuard.isUpdatedRoot(modelName,[guardRootPrefix,rootPath])
                continue;
            end
            topCvId=cv('get',rootId,'root.topSlsf');
            path=cv('GetRootPath',rootId);


            if updateAllRoots||isempty(activePath)||strcmpi(activePath,path)

                tmpPath=modelName;
                if~isempty(path)
                    tmpPath=[modelName,'/',path];
                end

                [s,H,msg]=update_susbsys_handles(tmpPath,topCvId,msg);
                cv('set',rootId,'root.topSlHandle',H);
                if s==0
                    status=0;
                    continue;
                end
            end
            if status==1
                SlCov.ContextGuard.addUpdatedRoot(modelName,[guardRootPrefix,rootPath]);
            end
        end

    catch MEx
        rethrow(MEx);
    end
end

function oc=restoreLibraryLock(model)


    oc=onCleanup.empty;
    prevLock=get_param(model,'Lock');
    if strcmpi(prevLock,'on')
        if bdIsLibrary(model)
            set_param(model,'Lock','off');
            oc=onCleanup(@()set_param(model,'Lock',prevLock));
        else
            oc=cvprivate('unlockModel',model);
        end
    end
end

function[status,topH,msg]=update_susbsys_handles(fullPath,cvId,msg)
    status=1;


    topH=path2handle(fullPath);
    if topH==0
        msg=addMessage(msg,getString(message('Slvnv:simcoverage:private:InvalidBlockPath',fullPath)));
        return;
    end

    cv('set',cvId,'slsfobj.handle',topH);


    children=cv('ChildrenOf',cvId);


    grandChildren=cv('get',children,'slsfobj.treeNode.child');
    leafNodes=children(grandChildren==0);
    childSystems=children(grandChildren>0);


    for childId=leafNodes(:)'

        if cv('get',childId,'slsfobj.origin')==1
            name=sl_equiv_name(childId);
            childPath=[fullPath,'/',name];
            h=path2handle(childPath);
            if h==0
                msg=addMessage(msg,getString(message('Slvnv:simcoverage:private:InvalidBlockPath',childPath)));
                status=0;
                continue;
            end
            cv('set',childId,'slsfobj.handle',h);
        elseif cv('get',childId,'slsfobj.origin')==4

            return
        elseif cv('get',childId,'slsfobj.origin')==3&&strcmp(bdroot(fullPath),cv('get',childId,'slsfobj.name'))

            cv('set',childId,'slsfobj.handle',topH);
        else
            [s,msg]=update_sf_chart_handles(fullPath,childId,msg);
            if s==0
                status=0;
            end
        end

    end


    for childId=childSystems(:)'
        name=sl_equiv_name(childId);
        childPath=[fullPath,'/',name];
        if cv('get',childId,'slsfobj.origin')==1
            [s,~,msg]=update_susbsys_handles(childPath,childId,msg);
            if s==0
                status=0;
                return;
            end
        else
            [s,msg]=update_sf_chart_handles(fullPath,childId,msg);
            if s==0
                status=0;
                return;
            end
        end
    end

end

function updateMasks(modelName)



    if~(strcmpi(get_param(modelName,'shown'),'on'))


        find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','Mask','on');
    end
end


function msg=addMessage(msg,newMsg)
    msg=[{newMsg},msg];
end

function update_chart_origPath(cvChartId,sfChartId,slFullPath)
    cv('set',cvChartId,'slsfobj.handle',sfChartId);
    cv('set',cvChartId,'.origPath',Simulink.ID.getSID(slFullPath));
end

function[status,msg]=update_sf_chart_handles(slFullPath,cvChartId,msg)
    status=0;

    h=path2handle(slFullPath);
    [instanceId,~]=get_sf_block_instance_handle(h);
    modelH=bdroot(h);

    if isempty(instanceId)||~sf('ishandle',instanceId)
        return;
    end

    sfChartId=sf('get',instanceId,'instance.chart');
    if isempty(sfChartId)||~sf('ishandle',sfChartId)
        return;
    end

    machineId=sf('get',sfChartId,'chart.machine');
    if isempty(machineId)||~sf('ishandle',machineId)
        return;
    end


    if~machine_update_list('check',machineId)
        if machine_needs_update(machineId)
            if strcmp(get_param(modelH,'SimulationStatus'),'stopped')
                sf('Private','compute_session_independent_debugger_numbers',machineId);

                machine_update_list('add',machineId);
            end
        end
    end


    update_chart_origPath(cvChartId,sfChartId,slFullPath);

    if~sf('Private','is_sf_chart',sfChartId)&&...
        ~Stateflow.STT.StateEventTableMan.isStateEventTableChart(sfChartId)&&...
        ~sf('Private','is_requirement_chart',sfChartId)&&...
        ~sf('Private','is_truth_table_chart',sfChartId)&&...
        ~sf('Private','is_eml_chart',sfChartId)




        kernelState=sf('AllSubstatesOf',sfChartId,true,false);
        sfChild=cv('ChildrenOf',cvChartId);
        kernelCvState=cv('find',sfChild,'.refClass',sf('get','default','state.isa'));
        cv('set',kernelCvState,'.handle',kernelState);
        status=1;
    else
        [status,msg]=refresh_substate_trans_ids(sfChartId,cvChartId,msg);
    end
end

function out=machine_update_list(method,arg)

    persistent syncedList;

    switch(method)
    case 'check'
        if isempty(syncedList)
            out=0;
        else
            out=any(syncedList==arg);
        end

    case 'add'
        syncedList=unique([syncedList;arg]);
        out=1;

    case 'clear'
        syncedList=[];
        out=1;

    otherwise
        error(message('Slvnv:simcoverage:refresh_model_handles:BadInput'));
    end

end

function[status,msg]=refresh_substate_trans_ids(sfId,cvId,msg)
    status=0;

    sfSubstates=sf('AllSubstatesOf',sfId,true,false);
    sfSubstates=sf('find',sfSubstates,'~state.isNoteBox',1);
    sfTrans=sf('TransitionsOf',sfId,false);
    transParents=sf('get',sfTrans,'.parent');
    sfTrans(transParents~=sfId)=[];
    sfTrans=sf('find',sfTrans,'~transition.dst.id',0);
    sfTrans=filter_virtual_trans(sfTrans);

    if~isempty(sfTrans)
        transNums=sf('get',sfTrans,'.number');
        [sortNums,I]=sort(transNums);
        if any(sortNums(1:(end-1))==sortNums(2:end))
            msg=addMessage(msg,getString(message('Slvnv:simcoverage:private:RepeatedTransitionNumber')));
            return
        end
        sfTrans=sfTrans(I);
    end


    cvChildren=cv('ChildrenOf',cvId);
    if~isempty(cvChildren)
        childIsa=cv('get',cvChildren,'slsfobj.refClass');
        cvSubstates=cvChildren(childIsa==sf('get','default','state.isa'));
        cvSubtrans=cvChildren(childIsa==sf('get','default','transition.isa'));
    else
        cvSubstates=[];
        cvSubtrans=[];
    end

    if length(sfSubstates)~=length(cvSubstates)||length(sfTrans)~=length(cvSubtrans)
        return;
    end

    if~isempty(sfSubstates)

        for i=1:length(sfSubstates)
            if(sf('get',sfSubstates(i),'.type')==3)
                if~strcmp(sf('get',sfSubstates(i),'.labelString'),cv('GetSlsfName',cvSubstates(i)))
                    msg=addMessage(msg,getString(message('Slvnv:simcoverage:private:BoxNameChanged')));
                    return;
                end
            else






                if~sf('Private','is_eml_chart',sfId)&&~sf('Private','is_truth_table_chart',sfId)&&...
                    ~strcmp(sf('get',sfSubstates(i),'.name'),cv('GetSlsfName',cvSubstates(i)))
                    msg=addMessage(msg,(getString(message('Slvnv:simcoverage:private:StateNameChanged'))));
                    return;
                end
            end
            cv('set',cvSubstates(i),'slsfobj.handle',sfSubstates(i));

            childCvId=cv('get',cvSubstates(i),'.treeNode.child');


            if childCvId~=0

                isAtomicSubChart=cv('get',childCvId,'.refClass')==sf('get','default','chart.isa');
                isSLInSF=cv('get',childCvId,'slsfobj.origin')==1;





                if isAtomicSubChart||isSLInSF

                    parentCvId=cvSubstates(i);

                    instancePath=cv('get',parentCvId,'.origPath');
                    relBlockPath='';
                    while isempty(instancePath)
                        if~isempty(relBlockPath)
                            relBlockPath=['.',relBlockPath];%#ok<AGROW>
                        end
                        relBlockPath=[cv('GetSlsfName',parentCvId),relBlockPath];%#ok<AGROW>
                        parentCvId=cv('get',parentCvId,'.treeNode.parent');
                        instancePath=cv('get',parentCvId,'.origPath');
                    end



                    instancePath=Simulink.ID.getFullName(instancePath);
                    newBlockPath=[instancePath,'/',relBlockPath];

                    if isAtomicSubChart
                        [~,msg]=update_sf_chart_handles(newBlockPath,childCvId,msg);
                    else
                        subsysH=get_param(newBlockPath,'handle');
                        cv('set',childCvId,'slsfobj.handle',subsysH);
                        [~,~,msg]=update_susbsys_handles(newBlockPath,childCvId,msg);
                    end
                end
            end
        end
    end

    if~isempty(sfTrans)

        for i=1:length(sfTrans)
            if~strcmp(sf('get',sfTrans(i),'.labelString'),cv('GetSlsfName',cvSubtrans(i)))
                msg=addMessage(msg,getString(message('Slvnv:simcoverage:private:TransitionNameChanged')));
                return;
            end
            cv('set',cvSubtrans(i),'slsfobj.handle',sfTrans(i));
        end
    end


    for i=1:length(sfSubstates)
        [s,msg]=refresh_substate_trans_ids(sfSubstates(i),cvSubstates(i),msg);
        if s==0
            return;
        end
    end

    status=1;
end

function h=path2handle(str)

    try
        h=get_param(str,'Handle');
    catch Mex %#ok<NASGU>
        h=0;
    end
end

function name=sl_equiv_name(cvId)
    name=cv('GetSlsfName',cvId);
    name=strrep(name,'/','//');
end











function[instanceId,isLink]=get_sf_block_instance_handle(blockH)



    if~ishandle(blockH)
        error_msg(getString(message('Slvnv:simcoverage:private:InvalidBlockHandleSlsf')));
        instanceId=0;
        return;
    end

    if is_an_sflink(blockH)
        isLink=1;
        refBlock=get_param(blockH,'ReferenceBlock');
        ind=find('/'==refBlock);
        instanceName=refBlock((ind(1)+1):end);



        load_system(refBlock(1:(ind(1)-1)));




        ud=sf('GetSFBlockData',refBlock);
        if isempty(ud)||~isnumeric(ud)||~sf('ishandle',ud)||isempty(sf('find','all','instance.name',instanceName))
            modelName=get_root_name_from_block_path(refBlock);
            sf_load_model(modelName);




            if strcmpi(get_param(modelName,'lock'),'on')
                set_param(modelName,'lock','off');
                set_param(modelName,'lock','on');
            end
        end
        instanceId=sf('GetSFBlockData',refBlock);
    else
        instanceId=sf('GetSFBlockData',blockH);
        isLink=0;
    end

end


function isLink=is_an_sflink(blockH)



    if isempty(get_param(blockH,'ReferenceBlock'))
        isLink=0;
    else
        isLink=1;
    end
end


function rootName=get_root_name_from_block_path(blkpath)



    ind=find(blkpath=='/','first');
    rootName=blkpath(1:(ind(1)-1));

end




function sf_load_model(modelName)



    try
        load_system(modelName);
    catch Mex %#ok<NASGU>
    end
end





function out=machine_needs_update(machineId)
    out=true;

    charts=sf('get',machineId,'.charts');
    chartId=charts(1);

    data1=sf('find','all','data.machine',machineId,'data.number',1);
    if~isempty(data1)
        out=false;
        return;
    end

    event1=sf('find','all','event.machine',machineId,'event.number',1);
    if~isempty(event1)
        out=false;
        return;
    end

    trans1=sf('find','all','trans.chart',chartId,'trans.number',1);
    if~isempty(trans1)
        out=false;
        return;
    end

    state1=sf('find','all','state.chart',chartId,'state.number',1);
    if~isempty(state1)
        out=false;
        return;
    end
end
function transIds=filter_virtual_trans(ids)
    simtrans=sf('find',ids,'transition.type','SIMPLE');
    supertrans=sf('find',ids,'transition.type','SUPER');
    transIds=[simtrans,supertrans]';
end









