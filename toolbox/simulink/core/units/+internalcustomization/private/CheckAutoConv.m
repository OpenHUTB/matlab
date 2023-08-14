function CheckAutoConv



    mdladvroot=ModelAdvisor.Root;


    autoUnitConvCheck=ModelAdvisor.Check('mathworks.design.AutoUnitConversions');
    autoUnitConvCheck.Title=DAStudio.message('Simulink:tools:MATitleIdentUnitAutoConv');
    autoUnitConvCheck.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentUnitAutoConv');
    autoUnitConvCheck.setCallbackFcn(@ExecCheckAutoConv,'PostCompile','StyleOne');
    autoUnitConvCheck.CSHParameters.MapKey='ma.simulink';
    autoUnitConvCheck.CSHParameters.TopicID='MATitleIdentUnitAutoConv';
    autoUnitConvCheck.Visible=true;
    autoUnitConvCheck.Value=false;
    mdladvroot.publish(autoUnitConvCheck,'Simulink');






    function result=ExecCheckAutoConv(system)
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        result={};
        modelname=bdroot(system);

        ImplicitConversionsStruct=cell2mat(Simulink.UnitUtils.getAutomaticUnitConversionsList(modelname));
        if(strcmp(modelname,system))
            Impl_Conv_Report=ImplicitConversionsStruct;
        else


            if(~isempty(ImplicitConversionsStruct))
                subsyspath=[system,'/'];
                srcblkpaths={ImplicitConversionsStruct(:).InsertedAtBlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                StructIdx_src=find(~cellfun(@isempty,srcinsubsys));
                Impl_Conv_Report=ImplicitConversionsStruct(StructIdx_src,1);
            else
                Impl_Conv_Report=ImplicitConversionsStruct;
            end
        end

        ft2=ModelAdvisor.FormatTemplate('ListTemplate');
        ft2.setInformation(DAStudio.message('Simulink:tools:MAInfoIdentUnitAutoConv'));

        if(~isempty(Impl_Conv_Report))
            mdladvObj.setCheckResultStatus(false);
            setSubResultStatus(ft2,'Warn');

            if(length(Impl_Conv_Report)==1)
                setSubResultStatusText(ft2,DAStudio.message('Simulink:tools:MAWarnIdentUnitAutoConvSingular'));
            else
                setSubResultStatusText(ft2,DAStudio.message('Simulink:tools:MAWarnIdentUnitAutoConv',length(Impl_Conv_Report)));
            end

            ft2.setSubBar(0);
            result{end+1}=ft2;

            table2=ModelAdvisor.FormatTemplate('TableTemplate');
            table2.setSubBar(0);

            needExtraCol=~isempty(find(~cellfun(@isempty,{Impl_Conv_Report.AdditionalMsg}),1));
            if needExtraCol
                table2.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MACol1UnitAutoConv'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsSrcUnits'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsDstUnits'),...
                DAStudio.message('Simulink:tools:MACol4UnitAutoConv')});
            else
                table2.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MACol1UnitAutoConv'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsSrcUnits'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsDstUnits')});
            end

            tableInfo={};


            ImplConverCell=struct2cell(Impl_Conv_Report);

            for r=1:length(Impl_Conv_Report)

                srcport=cell2mat(ImplConverCell(1,r));
                srcblkpath=cell2mat(ImplConverCell(3,r));
                portstr=cell2mat(ImplConverCell(2,r));
                msg1=ModelAdvisor.Text([portstr,' ',srcport,' ']);
                msg2=ModelAdvisor.Text(srcblkpath);
                srclink=[msg1,msg2];

                srcunits=cell2mat(ImplConverCell(4,r));

                dstunits=cell2mat(ImplConverCell(5,r));

                if needExtraCol
                    msg=cell2mat(ImplConverCell(6,r));
                    tableInfo=[tableInfo;{num2str(r),srclink,srcunits,dstunits,msg}];%#ok
                else
                    tableInfo=[tableInfo;{num2str(r),srclink,srcunits,dstunits}];%#ok
                end

            end

            table2.setTableInfo(tableInfo);
            result{end+1}=table2;
        else

            setSubResultStatus(ft2,'Pass');
            setSubResultStatusText(ft2,DAStudio.message('Simulink:tools:MAPassIdentUnitAutoConv'));
            mdladvObj.setCheckResultStatus(true);
            ft2.setSubBar(0);
            result{end+1}=ft2;

        end
