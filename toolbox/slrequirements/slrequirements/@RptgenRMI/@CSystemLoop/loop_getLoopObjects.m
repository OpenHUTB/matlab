function hList=loop_getLoopObjects(this,varargin)








    if builtin('_license_checkout','Simulink_Requirements','quiet')
        hList={};
        return;
    end

    hList=this.getLoopSystems(varargin{:});

    blkLoop=RptgenRMI.CBlockLoop;
    adSL=rptgen_sl.appdata_sl;


    oldCurrSys=adSL.CurrentSystem;
    oldCurrBlk=adSL.CurrentBlock;
    oldContext=adSL.Context;

    adSL.Context='System';


    filters=rmi.settings_mgr('get','filterSettings');



    followLibraryLinks=RptgenRMI.option('followLibraryLinks');

    take=false(length(hList),1);
    for idx=1:length(hList)
        sysPath=hList{idx};
        if any(sysPath=='/')&&rmisl.isComponentHarness(strtok(sysPath,'/'))

            sysPath=getOwnerObjectPath(sysPath);
            hList{idx}=sysPath;
        end

        if~followLibraryLinks||strcmp(sysPath,bdroot(sysPath))
            linkStatus='none';
        else
            linkStatus=get_param(sysPath,'StaticLinkStatus');
        end

        if any(strcmp(linkStatus,{'resolved','implicit'}))
            origPath=sysPath;
            sysPath=get_param(sysPath,'ReferenceBlock');
            load_system(strtok(sysPath,'/'));
            inLib=true;
        else
            inLib=false;
        end

        if rmi.objHasReqs(sysPath,filters)
            take(idx)=true;

        else

            set(adSL,'CurrentSystem',sysPath)
            childList=blkLoop.loop_getLoopObjects('include_signal_builders');
            if~isempty(childList)
                take(idx)=true;

            else

                matlabFunctionCodeSupported=~rmiml.enable();
                if rmidata.isExternal(oldCurrSys)&&matlabFunctionCodeSupported
                    if~isempty(findMatlabFunctions(sysPath))
                        take(idx)=true;
                    end
                end
            end
        end

        if take(idx)&&inLib

            hList{idx}=sysPath;


            matched=find(strcmp(adSL.ReportedSystemList,origPath));
            if length(matched)==1
                adSL.ReportedSystemList{matched}=sysPath;
            end
        end
    end


    hList=hList(take);


    adSL.CurrentSystem=oldCurrSys;
    adSL.CurrentBlock=oldCurrBlk;
    adSL.Context=oldContext;

end

function mFunctions=findMatlabFunctions(subSys)
    mFunctions={};
    subSysObj=get_param(subSys,'Object');
    mFunctionObjs=find(subSysObj,'-isa','Stateflow.EMFunction','-or','-isa','Stateflow.EMChart');
    for i=1:length(mFunctionObjs)
        if rmidata.emCodeHasLinks(mFunctionObjs(i))
            mFunctions{end+1}=mFunctionObjs;%#ok<AGROW>
        end
    end
end

function mdlPath=getOwnerObjectPath(harnessPath)
    harnessObj=get_param(harnessPath,'Object');
    if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(harnessObj)
        ownerObjSID=Simulink.harness.internal.sidmap.getHarnessObjectSID(harnessObj);
        sysObj=get_param(Simulink.ID.getHandle(ownerObjSID),'Object');
        mdlPath=sysObj.getFullName();
    else
        mdlPath=harnessPath;
    end
end

