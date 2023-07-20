function[CheckResult,CheckDetails]=check(harnessOwner,harnessName)

    if~license('checkout','Simulink_Test')
        DAStudio.error('Simulink:Harness:LicenseNotAvailable');
    end

    tracer=Simulink.harness.internal.HarnessPerfTracer('','Test Harness Check','Test Harness Check');%#ok

    argTracer=Simulink.harness.internal.HarnessPerfTracer('','Test Harness Check','Checking arguments');%#ok

    wantDetails=nargout>=2;

    narginchk(2,inf);

    try
        [systemModel,harnessStruct]=Simulink.harness.internal.findHarnessStruct(harnessOwner,harnessName);
    catch ME
        throwAsCaller(ME);
    end

    sysH=get_param(systemModel,'Handle');

    if harnessStruct.isOpen

        if Simulink.harness.internal.isBDBusy(sysH)
            DAStudio.error('Simulink:Harness:CannotExecuteHarnessOperationAsBDIsBusy',harnessStruct.name)
        end
    end

    if~harnessStruct.canBeOpened&&~harnessStruct.isOpen
        otherHarnessStruct=Simulink.harness.internal.getActiveHarness(systemModel);
        if isequal(harnessStruct,otherHarnessStruct)



            DAStudio.error('Simulink:Harness:CannotExecuteHarnessOperationAsBDIsBusy',harnessStruct.name)
        else

            DAStudio.error('Simulink:Harness:CannotCheckHarnessWhenAnotherHarnessIsActive',...
            harnessStruct.name,harnessStruct.ownerFullPath,otherHarnessStruct.name,otherHarnessStruct.ownerFullPath);
        end
    end


    Simulink.harness.internal.atomicActionCheck(sysH);



    try
        Simulink.harness.internal.checkHarnessOwner(sysH,harnessStruct.name,harnessStruct.ownerHandle);
    catch ME
        throwAsCaller(ME);
    end

    clear argTracer;

    if(harnessStruct.verificationMode==1||harnessStruct.verificationMode==2)&&strcmp(harnessStruct.ownerType,'Simulink.SubSystem')

        if harnessStruct.isOpen
            if strcmp(get_param(systemModel,'Lock'),'on')
                Simulink.harness.internal.setBDLock(systemModel,false);
                cleanupBDLock=onCleanup(@()Simulink.harness.internal.setBDLock(systemModel,true));
            end
        end
        systemChecksum=Simulink.SubSystem.getChecksum(harnessStruct.ownerHandle);

        if~harnessStruct.isOpen
            activate(systemModel,harnessStruct);
            cleanupActivate=onCleanup(@()deactivate(systemModel,harnessStruct));
        end

        harnessChecksum.structural=Simulink.harness.internal.getStoredOwnerCheckSumForSILPIL(sysH,harnessStruct.ownerHandle,harnessStruct.name);
        harnessChecksum.structural=harnessChecksum.structural';




        if wantDetails
            [CheckResult,CheckDetails]=compareSSCheckSum(systemChecksum.Value,harnessChecksum.structural,harnessStruct);
        else
            [CheckResult,~]=compareSSCheckSum(systemChecksum.Value,harnessChecksum.structural,harnessStruct);
        end
    else


        if~harnessStruct.isOpen
            activate(systemModel,harnessStruct);
            cleanupActivate=onCleanup(@()deactivate(systemModel,harnessStruct));
        end
        harnessComponent=Simulink.harness.internal.getActiveHarnessCUT(systemModel);
        if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')

            if strcmp(get_param(harnessComponent,'BlockType'),'ModelReference')
                simMode=get_param(harnessComponent,'SimulationMode');
            end
        end
        cs2=Simulink.harness.internal.getBlockChecksum(get_param(harnessComponent,'Handle'));


        cs1=zeros(1:8);%#ok
        if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
            try
                tmpMdl=new_system([],'model');
                cleanupNewMdl=onCleanup(@()close_system(tmpMdl,0));
                tmpMdlName=get_param(tmpMdl,'Name');
                if strcmpi(get_param(harnessStruct.ownerHandle,'BlockDiagramType'),'subsystem')
                    hOwner=add_block('built-in/Subsystem',[tmpMdlName,'/Subsystem'],'ReferencedSubsystem',systemModel);
                else
                    hOwner=add_block('built-in/ModelReference',[tmpMdlName,'/ModelReference'],'ModelName',systemModel);
                    if strcmp(get_param(harnessComponent,'BlockType'),'ModelReference')
                        set_param(hOwner,'SimulationMode',simMode);
                    end
                end
                cs1=Simulink.harness.internal.getBlockChecksum(get_param(hOwner,'Handle'));
            catch ME
                throwAsCaller(ME);
            end
        else



            ownerBlkHandle=get_param(harnessStruct.ownerFullPath,'Handle');
            if strcmp(get_param(ownerBlkHandle,'BlockType'),'FMU')
                loadFMUForBlock(ownerBlkHandle);
            end

            cs1=Simulink.harness.internal.getBlockChecksum(get_param(harnessStruct.ownerFullPath,'Handle'));
        end




        if wantDetails
            [CheckResult,CheckDetails]=compareStructuralCheckSum(cs1,cs2,harnessStruct);
        else
            [CheckResult,~]=compareStructuralCheckSum(cs1,cs2,harnessStruct);
        end
    end

    clear tracer;





    function activate(systemModel,harnessStruct)
        if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
            Simulink.harness.internal.loadBDHarness(systemModel,harnessStruct.name,true);
        else
            Simulink.harness.internal.loadHarness(systemModel,harnessStruct.name,harnessStruct.ownerHandle,true);




            hComponent=Simulink.harness.internal.getActiveHarnessCUT(systemModel);
            if strcmp(get_param(hComponent,'BlockType'),'FMU')
                loadFMUForBlock(hComponent);
            end
        end
    end

    function deactivate(systemModel,harnessStruct)
        if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
            Simulink.harness.internal.closeBDHarness(systemModel,harnessStruct.name,false);
        else
            Simulink.harness.internal.closeHarness(systemModel,harnessStruct.name,harnessStruct.ownerHandle,false);
        end
    end

    function loadFMUForBlock(blockHandle)
        model=bdroot(blockHandle);


        origDirty=get_param(model,'Dirty');
        oc1=onCleanup(@()set_param(model,'Dirty',origDirty));


        if strcmp(get_param(model,'Lock'),'on')
            Simulink.harness.internal.setBDLock(systemModel,false);
            oc2=onCleanup(@()Simulink.harness.internal.setBDLock(systemModel,true));
        end



        if~strcmp(get_param(blockHandle,'LinkStatus'),'resolved')
            tmpfmuname=get_param(blockHandle,'FMUName');
            set_param(blockHandle,'FMUName',tmpfmuname);
        end
    end

    function[result,details]=compareStructuralCheckSum(cs1,cs2,harnessStruct)
        try


            if(length(cs1)~=8)||(length(cs2)~=8)||...
                ~isa(cs1,'uint32')||~isa(cs1,'uint32')||...
                all(cs1(1:4)==zeros(1,4))||all(cs2(1:4)==zeros(1,4))
                result=false;
                details.overall=false;
                details.contents=false;
                details.reason=DAStudio.message('Simulink:Harness:CheckHarnessWrongChecksumFormat');


            elseif all(cs1==cs2)
                result=true;
                details.overall=true;
                details.contents=true;
                details.reason=DAStudio.message('Simulink:Harness:CheckHarnessChecksumMatch');



            elseif all(cs1(1:4)==cs2(1:4))
                result=false;
                details.overall=false;
                details.contents=true;
                details.reason=DAStudio.message('Simulink:Harness:CheckHarnessPartialChecksumMatch');



            elseif all(cs1(5:8)==cs2(5:8))&&all(cs1(5:8)~=zeros(1,4))
                result=false;
                details.overall=false;
                details.contents=false;
                details.reason=DAStudio.message('Simulink:Harness:CheckHarnessParametersChecksumMatch');


            else
                result=false;
                details.overall=false;
                details.contents=false;
                details.reason=DAStudio.message('Simulink:Harness:CheckHarnessChecksumMatchFailed');
            end
        catch causeME

            blockName=Simulink.harness.internal.getActiveHarnessCUT(harnessStruct.model);
            ownerName=get_param(harnessStruct.ownerHandle,'Name');
            ME=MException(errId,'%s',DAStudio.message('Simulink:Harness:CheckHarnessFailedHarnessChecksum',harnessStruct.Name,ownerName,blockName));
            ME=addCause(ME,causeME);
            throwAsCaller(ME);
        end
    end

    function[result,details]=compareSSCheckSum(cs1,cs2,harnessStruct)
        try
            if all(cs1==cs2)
                result=true;
                details.overall=true;
                details.contents=true;
                details.reason=DAStudio.message('Simulink:Harness:CheckHarnessChecksumMatch');
            else
                result=false;
                details.overall=false;
                details.contents=false;
                details.reason=DAStudio.message('Simulink:Harness:CheckHarnessChecksumMatchFailed');
            end
        catch causeME

            blockName=Simulink.harness.internal.getActiveHarnessCUT(harnessStruct.model);
            ownerName=get_param(harnessStruct.ownerHandle,'Name');
            ME=MException(errId,'%s',DAStudio.message('Simulink:Harness:CheckHarnessFailedHarnessChecksum',harnessStruct.Name,ownerName,blockName));
            ME=addCause(ME,causeME);
            throwAsCaller(ME);
        end
    end
end
