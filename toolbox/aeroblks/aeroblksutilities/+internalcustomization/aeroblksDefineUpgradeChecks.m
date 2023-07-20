function aeroblksDefineUpgradeChecks






    modelAdvisor=ModelAdvisor.Root;


    checkDOF=ModelAdvisor.Check('mathworks.design.Aeroblks.CheckDOF');
    checkDOF.Title=DAStudio.message('aeroblks:aeroupdate:upgradeDOFTitle');
    checkDOF.setCallbackFcn(@upgradeDOFBlocks,'None','StyleOne');
    checkDOF.CSHParameters.MapKey='ma.simulink';
    checkDOF.CSHParameters.TopicID='AeroblkDOFUpgrade';
    checkDOF.SupportLibrary=true;
    checkDOF.SupportExclusion=true;


    myActionDOF=ModelAdvisor.Action;
    setCallbackFcn(myActionDOF,@fixDOFBlocks);
    myActionDOF.Name=DAStudio.message('aeroblks:aeroupdate:upgradeDOFActionName');
    myActionDOF.Description=DAStudio.message('aeroblks:aeroupdate:upgradeDOFActionDesc');
    myActionDOF.Enable=false;
    checkDOF.setAction(myActionDOF);


    modelAdvisor.register(checkDOF);


    checkNAV=ModelAdvisor.Check('mathworks.design.Aeroblks.CheckNAV');
    checkNAV.Title=DAStudio.message('aeroblks:aeroupdate:upgradeNAVTitle');
    checkNAV.setCallbackFcn(@upgradeNAVBlocks,'None','StyleOne');
    checkNAV.CSHParameters.MapKey='ma.simulink';
    checkNAV.CSHParameters.TopicID='AeroblkNAVUpgrade';
    checkNAV.SupportLibrary=true;
    checkNAV.SupportExclusion=true;
    checkNAV.Value=true;
    checkNAV.Enable=true;
    checkNAV.Visible=true;


    modelAdvisor.register(checkNAV);

end

function results=upgradeDOFBlocks(system)




    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ResultStatus=false;
    mdladvObj.setCheckResultStatus(ResultStatus);


    ft=ModelAdvisor.FormatTemplate('ListTemplate');


    listFail=findUpgradeDOFBlocks(system);


    if isempty(listFail)

        ResultStatus=true;
        ft.setSubTitle(DAStudio.message('aeroblks:aeroupdate:upgradeDOFTitle'));
        ft.setSubResultStatusText(DAStudio.message('aeroblks:aeroupdate:upgradeNoDOFBlocks'));
    else

        ft.setSubTitle(DAStudio.message('aeroblks:aeroupdate:upgradeDOFTitle'));
        ft.setSubResultStatusText(DAStudio.message('aeroblks:aeroupdate:upgradeDOFInformation'));
        ft.setSubResultStatus('Warn');
        ft.setListObj(listFail);
        mdladvObj.setActionEnable(true);
    end
    results=ft;
    mdladvObj.setCheckResultStatus(ResultStatus);
end


function results=upgradeNAVBlocks(system)




    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ResultStatus=false;
    mdladvObj.setCheckResultStatus(ResultStatus);


    ft=ModelAdvisor.FormatTemplate('ListTemplate');


    runCheckFlag=false;
    try

        vers=get_param(system,'VersionLoaded');
        if vers<9.1
            runCheckFlag=true;
        end
    catch


        runCheckFlag=true;
    end


    if runCheckFlag

        listFail=findUpgradeNAVBlocks(system);
        if~isempty(listFail)

            ft.setSubTitle(DAStudio.message('aeroblks:aeroupdate:upgradeNAVTitle'));
            ft.setSubResultStatusText(DAStudio.message('aeroblks:aeroupdate:upgradeNAVInformation'));
            ft.setSubResultStatus('Warn');
            ft.setListObj(listFail);
        else

            ft.setSubTitle(DAStudio.message('aeroblks:aeroupdate:upgradeNAVTitle'));
            ft.setSubResultStatusText(DAStudio.message('aeroblks:aeroupdate:upgradeNoNAVBlocks'));
            ResultStatus=true;
        end
    else

        ft.setSubTitle(DAStudio.message('aeroblks:aeroupdate:upgradeNAVTitle'));
        ft.setSubResultStatusText(DAStudio.message('aeroblks:aeroupdate:upgradeNoNAVBlocks'));
        ResultStatus=true;
    end

    results=ft;
    mdladvObj.setCheckResultStatus(ResultStatus);
end



function results=fixDOFBlocks(taskobj)




    lbchk=builtin('license','checkout','Aerospace_Blockset');
    ltchk=builtin('license','checkout','Aerospace_Toolbox');


    if lbchk&&ltchk
        mdladvObj=taskobj.MAobj;
        system=bdroot(mdladvObj.System);


        listFail=findUpgradeDOFBlocks(system);


        root=slroot;


        ft=ModelAdvisor.FormatTemplate('TableTemplate');
        ft.setColTitles({'Block','Needs Remap'});


        brkSigFlag=false;

        for k=1:length(listFail)

            blk=char(listFail(k));


            [sysPath,blkPath]=fileparts(blk);
            root.set('CurrentSystem',sysPath);
            root.getCurrentSystem.set('CurrentBlock',blkPath);


            maskVals=get_param(blk,'MaskValues');
            maskParStr=cellstr(strsplit(get_param(blk,'MaskPropertyNamestring'),'|'));
            maskT=get_param(blk,'MaskType');


            switch maskT
            case '6DoF EoM (Body Axis)'
                Aero.internal.maskutilities.replaceblock(blk,'6DOF (Euler Angles)','aerolib6dof2');
            case '6DoF EoM (Wind Axis)'
                Aero.internal.maskutilities.replaceblock(blk,'6DOF Wind (Wind Angles)','aerolib6dof2');
            case '6DoF EoM (ECEF)'
                Aero.internal.maskutilities.replaceblock(blk,'6DOF ECEF (Quaternion)','aerolib6dof2');
            case '3DoF EoM'
                Aero.internal.maskutilities.replaceblock(blk,'3DOF (Body Axes)','aerolib3dof2');
            case '3DoF Wind EoM'
                Aero.internal.maskutilities.replaceblock(blk,'3DOF (Wind Axes)','aerolib3dof2');
            end

            for j=1:length(maskParStr)
                set_param(blk,maskParStr{j},maskVals{j});
            end
            massType=get_param(blk,'mtype');
            if strcmp(massType,'Custom Variable')&&brkSigFlag==false
                ft.addRow({listFail(k),'Yes'});
                brkSigFlag=true;
            else
                ft.addRow({listFail(k),'No'});
            end
        end

        if brkSigFlag
            ft.setInformation(DAStudio.message('aeroblks:aeroupdate:upgradeDOFFixInformationBrk'));
            ft.setInformation('');
        else
            ft.setInformation(DAStudio.message('aeroblks:aeroupdate:upgradeDOFFixInformation'));
            ft.setInformation('');
        end

        results=ft;
    else

        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubTitle(DAStudio.message('aeroblks:aeroupdate:upgradeNoLicenseAction'));
        ft.setSubResultStatusText(DAStudio.message('aeroblks:aeroupdate:upgradeNoLicenseActionInformation'))
        results=ft;
    end
end


function listFail=findUpgradeDOFBlocks(system)





    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);



    MaskTypesRegExp=[
'\<6DoF EoM \(Body Axis\)\>|'...
    ,'\<6DoF EoM \(Wind Axis\)\>|'...
    ,'\<6DoF EoM \(ECEF\)\>|'...
    ,'\<3DoF EoM\>|'...
    ,'\<3DoF Wind EoM\>'...
    ];

    listFail=find_system(system,...
    LookInsideSubsystemReference='off',...
    LookUnderMasks='all',...
    MatchFilter=@Simulink.match.allVariants,...
    RegExp='on',...
    MaskType=MaskTypesRegExp);

    listFail=mdladvObj.filterResultWithExclusion(listFail);

end


function listFail=findUpgradeNAVBlocks(system)





    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);



    MaskTypesRegExp=[
'\<Three-axis Accelerometer\>|'...
    ,'\<Three-axis Gyroscope\>|'...
    ,'\<Three-axis Inertial Measurement Unit\>'...
    ];

    listFail=find_system(system,...
    LookInsideSubsystemReference='off',...
    LookUnderMasks='all',...
    MatchFilter=@Simulink.match.allVariants,...
    RegExp='on',...
    MaskType=MaskTypesRegExp);

    listFail=mdladvObj.filterResultWithExclusion(listFail);

end

