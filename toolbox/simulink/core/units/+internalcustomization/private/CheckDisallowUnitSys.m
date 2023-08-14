function CheckDisallowUnitSys



    mdladvroot=ModelAdvisor.Root;



    disallowUnitSysCheck=ModelAdvisor.Check('mathworks.design.DisallowedUnitSystems');
    disallowUnitSysCheck.Title=DAStudio.message('Simulink:tools:MATitleIdentDisallowUnitSys');
    disallowUnitSysCheck.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentDisallowUnitSys');
    disallowUnitSysCheck.setCallbackFcn(@ExecCheckDisallowUnitSys,'PostCompile','StyleOne');
    disallowUnitSysCheck.CSHParameters.MapKey='ma.simulink';
    disallowUnitSysCheck.CSHParameters.TopicID='MATitleIdentDisallowUnitSys';
    disallowUnitSysCheck.Visible=true;
    disallowUnitSysCheck.Value=false;
    mdladvroot.publish(disallowUnitSysCheck,'Simulink');




    function result=ExecCheckDisallowUnitSys(system)
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        result={};
        modelname=bdroot(system);
        DisallowedUnitSystemStruct=cell2mat(Simulink.UnitUtils.getDisallowedUnitSystemsList(modelname));
        DisallowedUnitSystemInParamObjsStruct=cell2mat(Simulink.UnitUtils.getDisallowedUnitSystemsInParameterObjectsList(modelname));
        DisallowedUnitSystemInSignalObjsStruct=cell2mat(Simulink.UnitUtils.getDisallowedUnitSystemsInSignalObjectsList(modelname));

        if(strcmp(modelname,system))
            DisallowedUnit_Blks=DisallowedUnitSystemStruct;
            DisallowedUnit_PrmObjs_Blks=DisallowedUnitSystemInParamObjsStruct;
            DisallowedUnit_SigObjs_Blks=DisallowedUnitSystemInSignalObjsStruct;
        else


            subsyspath=[system,'/'];
            if(~isempty(DisallowedUnitSystemStruct))
                srcblkpaths={DisallowedUnitSystemStruct(:).SrcBlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                SubStructIdx=find(~cellfun(@isempty,srcinsubsys));
                DisallowedUnit_Blks=DisallowedUnitSystemStruct(SubStructIdx,1);
            else
                DisallowedUnit_Blks=DisallowedUnitSystemStruct;
            end

            if(~isempty(DisallowedUnitSystemInParamObjsStruct))
                srcblkpaths={DisallowedUnitSystemInParamObjsStruct(:).SrcBlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                SubStructIdx=find(~cellfun(@isempty,srcinsubsys));
                DisallowedUnit_PrmObjs_Blks=DisallowedUnitSystemInParamObjsStruct(SubStructIdx,1);
            else
                DisallowedUnit_PrmObjs_Blks=DisallowedUnitSystemInParamObjsStruct;
            end

            if(~isempty(DisallowedUnitSystemInSignalObjsStruct))
                srcblkpaths={DisallowedUnitSystemInSignalObjsStruct(:).SrcBlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                SubStructIdx=find(~cellfun(@isempty,srcinsubsys));
                DisallowedUnit_SigObjs_Blks=DisallowedUnitSystemInSignalObjsStruct(SubStructIdx,1);
            else
                DisallowedUnit_SigObjs_Blks=DisallowedUnitSystemInSignalObjsStruct;
            end
        end

        ft3=ModelAdvisor.FormatTemplate('ListTemplate');
        ft3.setInformation(DAStudio.message('Simulink:tools:MAInfoIdentDisallowUnitSys'));
        ft3.setSubBar(0);

        if(~isempty(DisallowedUnit_Blks)||~isempty(DisallowedUnit_PrmObjs_Blks)||~isempty(DisallowedUnit_SigObjs_Blks))

            mdladvObj.setCheckResultStatus(false);


            setSubResultStatus(ft3,'Warn');
            numDisallowUnitSys=length(DisallowedUnit_Blks)+length(DisallowedUnit_PrmObjs_Blks)+length(DisallowedUnit_SigObjs_Blks);
            if(numDisallowUnitSys==1)
                setSubResultStatusText(ft3,DAStudio.message('Simulink:tools:MAWarnIdentDisallowUnitSysSingular'));
            else
                setSubResultStatusText(ft3,DAStudio.message('Simulink:tools:MAWarnIdentDisallowUnitSys',numDisallowUnitSys));
            end
            result{end+1}=ft3;

            if(~isempty(DisallowedUnit_Blks))

                table3=ModelAdvisor.FormatTemplate('TableTemplate');
                table3.setSubBar(0);
                table3.setTableTitle(DAStudio.message('Simulink:tools:MADetailDisallowUnitSysInBlocks'));
                table3.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MACol1DisallowUnitSys'),...
                DAStudio.message('Simulink:tools:MACol2DisallowUnitSys'),...
                DAStudio.message('Simulink:tools:MACol3DisallowUnitSys')});
                tableInfo3={};

                for r=1:length(DisallowedUnit_Blks)

                    srcport=DisallowedUnit_Blks(r,1).SrcPortIdx;
                    srcblkpath=DisallowedUnit_Blks(r,1).SrcBlockPath;
                    srcporttype=DisallowedUnit_Blks(r,1).SrcPortType;
                    msg1=ModelAdvisor.Text([srcporttype,' ',num2str(srcport),' ']);
                    msg2=ModelAdvisor.Text(srcblkpath);
                    srclink=[msg1,msg2];

                    blkunits=DisallowedUnit_Blks(r,1).SrcUnitInfo;

                    allowunitsystem=DisallowedUnit_Blks(r,1).AllowedUnitSystems;

                    tableInfo3=[tableInfo3;{num2str(r),srclink,blkunits,allowunitsystem}];%#ok
                end

                table3.setTableInfo(tableInfo3);
                result{end+1}=table3;

            end

            if(~isempty(DisallowedUnit_PrmObjs_Blks))

                table4=ModelAdvisor.FormatTemplate('TableTemplate');
                table4.setSubBar(0);
                table4.setTableTitle(DAStudio.message('Simulink:tools:MADetailDisallowUnitSysInParamObjs'));
                table4.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MACol1DisallowUnitSysParamObj'),...
                DAStudio.message('Simulink:tools:MACol2DisallowUnitSysParamObj'),...
                DAStudio.message('Simulink:tools:MACol4DisallowUnitSysParamObj'),...
                DAStudio.message('Simulink:tools:MACol5DisallowUnitSysParamObj'),...
                DAStudio.message('Simulink:tools:MACol6DisallowUnitSysParamObj'),...
                DAStudio.message('Simulink:tools:MACol3DisallowUnitSysParamObj')});
                tableInfo4={};


                for r=1:length(DisallowedUnit_PrmObjs_Blks)

                    srcblkpath=DisallowedUnit_PrmObjs_Blks(r,1).SrcBlockPath;

                    blkunits=DisallowedUnit_PrmObjs_Blks(r,1).SrcUnitInfo;

                    blkprm=DisallowedUnit_PrmObjs_Blks(r,1).SrcParamName;

                    classname=DisallowedUnit_PrmObjs_Blks(r,1).SrcClassName;
                    prmobj=DisallowedUnit_PrmObjs_Blks(r,1).SrcParamObjName;
                    prmobjlink=sprintf('<a href="matlab:Simulink.UnitUtils.openObjectEditor(''%s'', ''%s'');">%s</a>',modelname,prmobj,prmobj);

                    allowunitsystem=DisallowedUnit_PrmObjs_Blks(r,1).AllowedUnitSystems;

                    tableInfo4=[tableInfo4;{num2str(r),srcblkpath,blkunits,blkprm,classname,prmobjlink,allowunitsystem}];%#ok
                end

                table4.setTableInfo(tableInfo4);
                result{end+1}=table4;

            end

            if(~isempty(DisallowedUnit_SigObjs_Blks))

                table5=ModelAdvisor.FormatTemplate('TableTemplate');
                table5.setSubBar(0);
                table5.setTableTitle(DAStudio.message('Simulink:tools:MADetailDisallowUnitSysInSignalObjs'));
                table5.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MACol1DisallowUnitSysSignalObj'),...
                DAStudio.message('Simulink:tools:MACol2DisallowUnitSysSignalObj'),...
                DAStudio.message('Simulink:tools:MACol4DisallowUnitSysSignalObj'),...
                DAStudio.message('Simulink:tools:MACol3DisallowUnitSysSignalObj')});
                tableInfo5={};


                for r=1:length(DisallowedUnit_SigObjs_Blks)

                    srcblkpath=DisallowedUnit_SigObjs_Blks(r,1).SrcBlockPath;
                    srcportidx=DisallowedUnit_SigObjs_Blks(r,1).SrcPortIdx;
                    msg1=ModelAdvisor.Text([DAStudio.message('Simulink:Unit:OutputPortStrUC'),' ',num2str(srcportidx),' ']);
                    msg2=ModelAdvisor.Text(srcblkpath);
                    srclink=[msg1,msg2];

                    blkunits=DisallowedUnit_SigObjs_Blks(r,1).SrcUnitInfo;

                    sigobj=DisallowedUnit_SigObjs_Blks(r,1).SrcSignalObjName;
                    sigobjlink=sprintf('<a href="matlab:Simulink.UnitUtils.openObjectEditor(''%s'', ''%s'');">%s</a>',modelname,sigobj,sigobj);

                    allowunitsystem=DisallowedUnit_SigObjs_Blks(r,1).AllowedUnitSystems;

                    tableInfo5=[tableInfo5;{num2str(r),srclink,blkunits,sigobjlink,allowunitsystem}];%#ok

                end

                table5.setTableInfo(tableInfo5);
                result{end+1}=table5;

            end

        else

            setSubResultStatus(ft3,'Pass');
            setSubResultStatusText(ft3,DAStudio.message('Simulink:tools:MAPassIdentDisallowUnitSys'))
            mdladvObj.setCheckResultStatus(true);
            ft3.setSubBar(0);
            result{end+1}=ft3;

        end
