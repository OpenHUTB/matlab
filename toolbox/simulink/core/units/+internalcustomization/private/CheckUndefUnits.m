function CheckUndefUnits



    mdladvroot=ModelAdvisor.Root;


    undefinedUnitCheck=ModelAdvisor.Check('mathworks.design.UndefinedUnits');
    undefinedUnitCheck.Title=DAStudio.message('Simulink:tools:MATitleIdentUndefinedUnits');
    undefinedUnitCheck.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentUndefinedUnits');
    undefinedUnitCheck.setCallbackFcn(@ExecCheckUndefUnits,'PostCompile','StyleOne');
    undefinedUnitCheck.CSHParameters.MapKey='ma.simulink';
    undefinedUnitCheck.CSHParameters.TopicID='MATitleIdentUndefinedUnits';
    undefinedUnitCheck.Visible=true;
    undefinedUnitCheck.Value=false;
    mdladvroot.publish(undefinedUnitCheck,'Simulink');




    function result=ExecCheckUndefUnits(system)
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        result={};
        modelname=bdroot(system);
        UndefinedUnitsStruct=cell2mat(Simulink.UnitUtils.getUndefinedUnitsList(modelname));
        UndefinedUnitsInObjsStruct=cell2mat(Simulink.UnitUtils.getUndefinedUnitsInObjectsList(modelname));
        IncompatibleSimscapeUnitsStruct=cell2mat(Simulink.UnitUtils.getIncompatibleSimscapeUnitsList(modelname));
        if(strcmp(modelname,system))
            Undefined_Units_Rep=UndefinedUnitsStruct;
            Undefined_Units_Objs_Rep=UndefinedUnitsInObjsStruct;
            Incompatible_Simscape_Units_Rep=IncompatibleSimscapeUnitsStruct;
        else


            subsyspath=[system,'/'];
            if(~isempty(UndefinedUnitsStruct))
                srcblkpaths={UndefinedUnitsStruct(:).BlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                SubStructIdx=find(~cellfun(@isempty,srcinsubsys));
                Undefined_Units_Rep=UndefinedUnitsStruct(SubStructIdx,1);
            else
                Undefined_Units_Rep=UndefinedUnitsStruct;
            end
            if(~isempty(UndefinedUnitsInObjsStruct))
                srcblkpaths={UndefinedUnitsInObjsStruct(:).BlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                SubStructIdx=find(~cellfun(@isempty,srcinsubsys));
                Undefined_Units_Objs_Rep=UndefinedUnitsInObjsStruct(SubStructIdx,1);
            else
                Undefined_Units_Objs_Rep=UndefinedUnitsInObjsStruct;
            end
            if(~isempty(IncompatibleSimscapeUnitsStruct))
                srcblkpaths={IncompatibleSimscapeUnitsStruct(:).BlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                SubStructIdx=find(~cellfun(@isempty,srcinsubsys));
                Incompatible_Simscape_Units_Rep=IncompatibleSimscapeUnitsStruct(SubStructIdx,1);
            else
                Incompatible_Simscape_Units_Rep=IncompatibleSimscapeUnitsStruct;
            end
        end
        ft4=ModelAdvisor.FormatTemplate('ListTemplate');
        ft4.setInformation(DAStudio.message('Simulink:tools:MAInfoIdentUndefinedUnits'));

        if(~isempty(Undefined_Units_Rep)||~isempty(Undefined_Units_Objs_Rep)||~isempty(Incompatible_Simscape_Units_Rep))

            mdladvObj.setCheckResultStatus(false);


            setSubResultStatus(ft4,'Warn');
            numUndefUnits=length(Undefined_Units_Rep)+length(Undefined_Units_Objs_Rep)+length(Incompatible_Simscape_Units_Rep);
            if(numUndefUnits==1)
                setSubResultStatusText(ft4,DAStudio.message('Simulink:tools:MAWarnIdentUndefinedUnitsSingular'));
            else
                setSubResultStatusText(ft4,DAStudio.message('Simulink:tools:MAWarnIdentUndefinedUnits',numUndefUnits));
            end

            ft4.setSubBar(0);
            result{end+1}=ft4;

            if(~isempty(Undefined_Units_Rep))


                table4=ModelAdvisor.FormatTemplate('TableTemplate');
                table4.setSubBar(0);
                table4.setTableTitle(DAStudio.message('Simulink:tools:MADetailUndefinedUnitsInBlocks'));
                table4.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MACol1UndefinedUnits'),...
                DAStudio.message('Simulink:tools:MASuggColUndefinedUnits'),...
                DAStudio.message('Simulink:tools:MACol2UndefinedUnits')});

                tableInfo4={};


                UndefinedUnitsCell=struct2cell(Undefined_Units_Rep);

                for r=1:length(Undefined_Units_Rep)
                    undefined_unit=cell2mat(UndefinedUnitsCell(1,r));

                    blkpath=cell2mat(UndefinedUnitsCell(2,r));

                    suggested_unit=formatSuggestedUnit(undefined_unit,cell2mat(UndefinedUnitsCell(3,r)));

                    tableInfo4=[tableInfo4;{num2str(r),undefined_unit,suggested_unit,blkpath}];%#ok
                end

                table4.setTableInfo(tableInfo4);
                result{end+1}=table4;

            end

            if(~isempty(Undefined_Units_Objs_Rep))

                table5=ModelAdvisor.FormatTemplate('TableTemplate');
                table5.setSubBar(0);
                table5.setTableTitle(DAStudio.message('Simulink:tools:MADetailUndefinedUnitsInObjs'));
                table5.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MACol1UndefinedUnitsInObjs'),...
                DAStudio.message('Simulink:tools:MASuggColUndefinedUnits'),...
                DAStudio.message('Simulink:tools:MACol2UndefinedUnitsInObjs'),...
                DAStudio.message('Simulink:tools:MACol3UndefinedUnitsInObjs'),...
                DAStudio.message('Simulink:tools:MACol4UndefinedUnitsInObjs')});

                tableInfo5={};

                UndefinedUnitsCell=struct2cell(Undefined_Units_Objs_Rep);

                for r=1:length(Undefined_Units_Objs_Rep)

                    undefined_unit=cell2mat(UndefinedUnitsCell(1,r));

                    blkpath=cell2mat(UndefinedUnitsCell(2,r));

                    className=cell2mat(UndefinedUnitsCell(3,r));

                    objName=cell2mat(UndefinedUnitsCell(4,r));
                    objNameLink=sprintf('<a href="matlab:Simulink.UnitUtils.openObjectEditor(''%s'', ''%s'');">%s</a>',modelname,objName,objName);

                    suggested_unit=formatSuggestedUnit(undefined_unit,cell2mat(UndefinedUnitsCell(5,r)));

                    tableInfo5=[tableInfo5;{num2str(r),undefined_unit,suggested_unit,blkpath,className,objNameLink}];%#ok
                end

                table5.setTableInfo(tableInfo5);
                result{end+1}=table5;

            end

            if(~isempty(Incompatible_Simscape_Units_Rep))

                table6=ModelAdvisor.FormatTemplate('TableTemplate');
                table6.setSubBar(0);
                table6.setTableTitle(DAStudio.message('Simulink:tools:MADetailIncompatibleSimscapeUnits'));
                table6.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MACol1IncompatibleSimscapeUnits'),...
                DAStudio.message('Simulink:tools:MACol2IncompatibleSimscapeUnits')});

                tableInfo6={};


                IncompatibleSimscapeUnitsCell=struct2cell(Incompatible_Simscape_Units_Rep);

                for r=1:length(Incompatible_Simscape_Units_Rep)

                    incompatible_unit=cell2mat(IncompatibleSimscapeUnitsCell(1,r));

                    blkpath=cell2mat(IncompatibleSimscapeUnitsCell(2,r));

                    tableInfo6=[tableInfo6;{num2str(r),incompatible_unit,blkpath}];%#ok

                end

                table6.setTableInfo(tableInfo6);
                result{end+1}=table6;

            end

        else

            setSubResultStatus(ft4,'Pass');
            setSubResultStatusText(ft4,DAStudio.message('Simulink:tools:MAPassIdentUndefinedUnits'))
            mdladvObj.setCheckResultStatus(true);
            ft4.setSubBar(0);
            result{end+1}=ft4;

        end

        function formattedUnit=formatSuggestedUnit(originalUnit,suggestion)

            if(strcmp(originalUnit,suggestion))
                formattedUnit='-';
            else
                formattedUnit=suggestion;
            end
