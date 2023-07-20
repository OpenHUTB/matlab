function result=editReqs(obj,activeIndex,index,count)



    result=-1;


    if nargin<4
        count=-1;
    end
    if nargin<3
        index=-1;
    end
    if nargin<2
        activeIndex=-1;
    end


    if rmide.isDataEntry(obj)
        reqs=rmide.getReqs(obj,index,count);
        if ischar(obj)
            stringId=obj;
        else
            stringId=rmide.toString(obj);
        end
        result=ReqMgr.rmidlg_mgr('data',stringId,reqs,activeIndex,index,count);
        return;
    end


    if rmifa.isFaultInfoObj(obj)
        reqs=rmifa.getReqs(obj);
        faultInfoObj=rmifa.resolveObjInFaultInfo(obj);
        ReqMgr.rmidlg_mgr('fault',...
        [faultInfoObj.getTopModelName,'|',rmifa.itemIDPref,faultInfoObj.Uuid],...
        reqs,-1,-1,-1);
        return;
    end


    if rmism.isSafetyManagerObj(obj)
        reqs=rmism.getReqs(obj);
        ReqMgr.rmidlg_mgr('safetymanager',obj,...
        reqs,-1,-1,-1);
        return;
    end


    object=[];
    if ischar(obj)
        obj=get_param(obj,'Handle');
        isSf=false;
    elseif isa(obj,'Simulink.Object')
        object=obj;
        isSf=false;
    elseif isa(obj,'Stateflow.Object')
        object=obj;
        isSf=true;
        if isa(object,'Stateflow.Chart')

            chartBlock=sf('Private','chart2block',object.Id);
            result=rmi.editReqs(chartBlock,activeIndex,index,count);
            return;
        end
    else
        isSf=(floor(obj(1))==obj(1));
        if isSf&&(sf('get',obj(1),'.isa')==sf('get','default','chart.isa'))

            chartBlock=sf('Private','chart2block',obj);
            result=rmi.editReqs(chartBlock,activeIndex,index,count);
            return;
        end
    end
    multipleItems=(length(obj)>1);


    modelH=rmisl.getmodelh(obj(1));


    if rmisl.isComponentHarness(modelH)
        diagObj=get_param(modelH,'Object');
        cutObj=rmisl.harnessToModelRemap(diagObj);
        topMdl=bdroot(cutObj.Handle);
    else
        topMdl=modelH;
    end
    if isempty(get_param(topMdl,'FileName'))
        errordlg(...
        getString(message('Slvnv:rmi:editReqs:NeedToSave17b')),...
        getString(message('Slvnv:rmi:editReqs:RequirementsDefaultExternal17b')));
        return;
    end




    if~Simulink.harness.internal.hasActiveHarness(modelH)
        isLibrary=strcmpi(get_param(modelH,'BlockDiagramType'),'library');
        if isLibrary


            if slreq.utils.isUsingEmbeddedLinkSet(modelH)&&~rmisl.isUnlocked(modelH,1)
                return;
            end
        end
    end


    if~multipleItems&&rmisl.isComponentHarness(modelH)
        if isempty(object)
            object=rmisl.getObject(obj,isSf);
        end
        if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(object)
            obj=rmisl.harnessToModelRemap(object);
        end
    end




    isSigBuilder=false;



    [rmiInstalled,rmiLicenseAvailable]=rmi.isInstalled();

    for currentObj=obj(:)'

        [isSf,objH,~]=rmi.resolveobj(currentObj);
        if isSf
            slH=rmisf.sfinstance(objH);
        else
            slH=objH;
        end

        if rmiInstalled&&rmiLicenseAvailable&&isempty(rmi.canlink(slH,false))
            return;
        end

        if rmisl.is_signal_builder_block(slH)
            isSigBuilder=true;
            if index==-1
                errordlg(...
                getString(message('Slvnv:rmi:editReqs:CannotEditSigBuilder')),...
                getString(message('Slvnv:rmi:editReqs:RequirementsSigBuilder')));
                return;
            end
        end
    end



    if multipleItems
        reqs={};
        source='';

        result=ReqMgr.rmidlg_mgr(source,obj(:),reqs,-1,-1,-1);
    else
        [isSf,objH,~]=rmi.resolveobj(obj);

        if isSigBuilder&&count==-1
            reqs=rmi.getReqs(objH,index);
        else
            reqs=rmi.getReqs(objH,index,count);
        end

        if isSf
            source='stateflow';
        else
            source='simulink';
        end

        result=ReqMgr.rmidlg_mgr(source,objH,reqs,activeIndex,index,count);
    end
end


