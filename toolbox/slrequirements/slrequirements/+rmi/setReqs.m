function setReqs(varargin)




    obj=varargin{1};
    reqs=varargin{2};


    if rmide.isDataEntry(obj)
        rmide.setReqs(obj,reqs);
        return;
    end


    if~isempty(which('stm.view'))&&rmitm.isTest(obj)
        rmitm.setReqs(obj,reqs);
        return;
    end


    if rmifa.isFaultInfoObj(obj)
        rmifa.setReqs(obj,reqs);
        return;
    end


    if rmism.isSafetyManagerObj(obj)
        rmism.setReqs(obj,reqs);
        return;
    end





    [modelH,objH,isSf,isSigBuilder]=rmisl.resolveObj(obj);


    if rmisl.inLibrary(objH,isSf)||rmisl.inSubsystemReference(objH,isSf)
        error(message('Slvnv:reqmgt:setReqs:InLibrary'));
    end

    origH=[];
    if rmisl.isComponentHarness(modelH)
        systemBD=Simulink.harness.internal.getHarnessOwnerBD(modelH);
        if~Simulink.harness.internal.isReqLinkingSupportedForExtHarness(systemBD)
            error(message('Slvnv:reqmgt:SetReqNotSupportedForExternalHarnesses'));
        end

        theObj=rmisl.getObject(objH,isSf);
        if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(theObj)

            origH=objH;
            cutObj=rmisl.harnessToModelRemap(theObj);
            if isa(cutObj,'Simulink.Object')
                objH=cutObj.Handle;
            elseif isa(cutObj,'Stateflow.Object')
                objH=cutObj.Id;
            else
                error(message('Slvnv:reqmgt:rmi:InvalidObject',class(cutObj)));
            end
        end
    end


    if rmidata.isExternal(modelH)
        slreq.setReqs(objH,varargin{2:end});
        return;
    end

    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:setReqs:NoLicense'));
    end

    if~isempty(reqs)


        isSlLink=strcmp({reqs.reqsys},'linktype_rmi_simulink');
        if any(isSlLink)
            thisModelName=get_param(modelH,'Name');
            reqs(isSlLink)=rmisl.intraLinksTrim(reqs(isSlLink),thisModelName);
        end
    end


    if~isSf&&~isSigBuilder&&strcmp(get_param(objH,'Type'),'annotation')
        error(message('Slvnv:reqmgt:rmi:InvalidObject','Simulink.Annotation'));
    end


    if rmi.settings_mgr('get','storageSettings','external')&&isempty(get_param(modelH,'FileName'))
        error(message('Slvnv:reqmgt:setReqs:noFileName'));
    end


    isLibrary=strcmpi(get_param(modelH,'BlockDiagramType'),'library');
    isLocked=~rmisl.isUnlocked(modelH,0);



    if~Simulink.harness.internal.hasActiveHarness(modelH)
        if isLibrary&&isLocked
            error(message('Slvnv:reqmgt:setReqs:libraryLocked'));
        end
    end


    oldReqs=rmi.getReqs(obj);
    newReqCnt=length(reqs);



    if nargin==4
        offset=varargin{3};
        count=varargin{4};
        if isSigBuilder
            if offset>0

                [~,~,groupReqCnt]=rmisl.sigbuilder_group_reqs(objH,1);
                index=-1;
            else

                isSigBuilder=false;
            end
        end

    elseif nargin==3


        if isSigBuilder&&varargin{3}>0
            index=varargin{3};
            [offset,count,groupReqCnt]=rmisl.sigbuilder_group_reqs(objH,index);
        else
            error(message('Slvnv:reqmgt:setReqs:InvalidArgs'));
        end

    else
        if isSigBuilder

            [offset,count,groupReqCnt]=rmisl.sigbuilder_group_reqs(objH,1);
            index=1;
        else
            offset=-1;
            count=length(oldReqs);
        end
    end


    if offset>0

        reqFilter=offset:(offset+count-1);


        remainingReqs=rmi.deleteReqsPrim(oldReqs,reqFilter);


        newReqs=rmi.insertReqsPrim(remainingReqs,reqs,offset);
    else
        newReqs=reqs;
    end



    if isLocked
        Simulink.harness.internal.setBDLock(modelH,false);
    end
    if isSigBuilder

        if index>0
            groupReqCnt(index)=newReqCnt;
            sigbArgs={offset,newReqCnt,groupReqCnt};
        else



            if count==newReqCnt
                sigbArgs={-1,-1,groupReqCnt};
            else
                sigbArgs={-1,newReqCnt};
            end
        end
        setStructReqs(objH,false,modelH,newReqs,sigbArgs{:});

    else

        setStructReqs(objH,isSf,modelH,newReqs);
    end


    if~isempty(newReqs)
        set_param(modelH,'hasReqInfo','on');
    end






    if isLocked
        Simulink.harness.internal.setBDLock(modelH,true);
    end

    if~isempty(origH)


        if isSf
            sf('set',origH,'.requirementInfo',sf('get',objH,'.requirementInfo'));
        else
            set_param(origH,'RequirementInfo',get_param(objH,'RequirementInfo'));
        end
    end


    rmisl.postSetReqsUpdates(modelH,objH,isSf,oldReqs,newReqs);

end



function setStructReqs(objH,isSf,modelH,structArray,varargin)


    reqstr=rmi.reqs2str(structArray);


    GUID=rmi.guidGet(objH);


    if isempty(reqstr)
        reqstr='{} ';
    end
    reqstr=[reqstr,' %',GUID];


    rmi.setRawReqs(objH,isSf,reqstr,modelH);

    if~isempty(varargin)
        vnv_panel_mgr('sbUpdateReq',objH,varargin{:});
    end

end

