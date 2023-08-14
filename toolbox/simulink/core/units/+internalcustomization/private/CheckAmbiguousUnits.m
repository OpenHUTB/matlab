function CheckAmbiguousUnits



    mdladvroot=ModelAdvisor.Root;


    ambiguousUnitCheck=ModelAdvisor.Check('mathworks.design.AmbiguousUnits');
    ambiguousUnitCheck.Title=DAStudio.message('Simulink:tools:MATitleIdentAmbiguousUnits');
    ambiguousUnitCheck.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentAmbiguousUnits');
    ambiguousUnitCheck.setCallbackFcn(@ExecCheckAmbiguousUnits,'PostCompile','StyleOne');
    ambiguousUnitCheck.CSHParameters.MapKey='ma.simulink';
    ambiguousUnitCheck.CSHParameters.TopicID='MATitleIdentAmbiguousUnits';
    ambiguousUnitCheck.Visible=true;
    ambiguousUnitCheck.Value=false;
    mdladvroot.publish(ambiguousUnitCheck,'Simulink');




    function result=ExecCheckAmbiguousUnits(system)
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        result={};
        modelname=bdroot(system);
        AmbiguousUnitsStruct=cell2mat(Simulink.UnitUtils.getAmbiguousUnitsList(modelname));
        AmbiguousUnitsInObjsStruct=cell2mat(Simulink.UnitUtils.getAmbiguousUnitsInObjectsList(modelname));
        if(strcmp(modelname,system))
            Ambiguous_Units_Rep=AmbiguousUnitsStruct;
            Ambiguous_Units_Objs_Rep=AmbiguousUnitsInObjsStruct;
        else


            subsyspath=[system,'/'];
            if(~isempty(AmbiguousUnitsStruct))
                srcblkpaths={AmbiguousUnitsStruct(:).BlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                SubStructIdx=find(~cellfun(@isempty,srcinsubsys));
                Ambiguous_Units_Rep=AmbiguousUnitsStruct(SubStructIdx,1);
            else
                Ambiguous_Units_Rep=AmbiguousUnitsStruct;
            end
            if(~isempty(AmbiguousUnitsInObjsStruct))
                srcblkpaths={AmbiguousUnitsInObjsStruct(:).BlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                SubStructIdx=find(~cellfun(@isempty,srcinsubsys));
                Ambiguous_Units_Objs_Rep=AmbiguousUnitsInObjsStruct(SubStructIdx,1);
            else
                Ambiguous_Units_Objs_Rep=AmbiguousUnitsInObjsStruct;
            end
        end
        ft4=ModelAdvisor.FormatTemplate('ListTemplate');
        ft4.setInformation(DAStudio.message('Simulink:tools:MAInfoIdentAmbiguousUnits'));

        if(~isempty(Ambiguous_Units_Rep)||~isempty(Ambiguous_Units_Objs_Rep))

            mdladvObj.setCheckResultStatus(false);


            setSubResultStatus(ft4,'Warn');
            numAmbiguousUnits=length(Ambiguous_Units_Rep)+length(Ambiguous_Units_Objs_Rep);
            if(numAmbiguousUnits==1)
                setSubResultStatusText(ft4,DAStudio.message('Simulink:tools:MAWarnIdentAmbiguousUnitsSingular'));
            else
                setSubResultStatusText(ft4,DAStudio.message('Simulink:tools:MAWarnIdentAmbiguousUnits',numAmbiguousUnits));
            end

            ft4.setSubBar(0);
            result{end+1}=ft4;

            if(~isempty(Ambiguous_Units_Rep))


                table4=ModelAdvisor.FormatTemplate('TableTemplate');
                table4.setSubBar(0);
                table4.setTableTitle(DAStudio.message('Simulink:tools:MADetailAmbiguousUnitsInBlocks'));
                table4.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MACol1AmbiguousUnits'),...
                DAStudio.message('Simulink:tools:MASuggColAmbiguousUnits'),...
                DAStudio.message('Simulink:tools:MACol2AmbiguousUnits')});

                tableInfo4={};


                AmbiguousUnitsCell=struct2cell(Ambiguous_Units_Rep);

                for r=1:length(Ambiguous_Units_Rep)
                    ambiguous_unit=cell2mat(AmbiguousUnitsCell(1,r));

                    blkpath=cell2mat(AmbiguousUnitsCell(2,r));

                    suggested_unit=formatSuggestedUnit(cell2mat(AmbiguousUnitsCell(3,r)));

                    tableInfo4=[tableInfo4;{num2str(r),ambiguous_unit,suggested_unit,blkpath}];%#ok
                end

                table4.setTableInfo(tableInfo4);
                result{end+1}=table4;

            end

            if(~isempty(Ambiguous_Units_Objs_Rep))

                table5=ModelAdvisor.FormatTemplate('TableTemplate');
                table5.setSubBar(0);
                table5.setTableTitle(DAStudio.message('Simulink:tools:MADetailAmbiguousUnitsInObjs'));
                table5.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MACol1AmbiguousUnitsInObjs'),...
                DAStudio.message('Simulink:tools:MASuggColAmbiguousUnits'),...
                DAStudio.message('Simulink:tools:MACol2AmbiguousUnitsInObjs'),...
                DAStudio.message('Simulink:tools:MACol3AmbiguousUnitsInObjs'),...
                DAStudio.message('Simulink:tools:MACol4AmbiguousUnitsInObjs')});

                tableInfo5={};

                AmbiguousUnitsCell=struct2cell(Ambiguous_Units_Objs_Rep);

                for r=1:length(Ambiguous_Units_Objs_Rep)

                    ambiguous_unit=cell2mat(AmbiguousUnitsCell(1,r));

                    blkpath=cell2mat(AmbiguousUnitsCell(2,r));

                    className=cell2mat(AmbiguousUnitsCell(3,r));

                    objName=cell2mat(AmbiguousUnitsCell(4,r));
                    objNameLink=sprintf('<a href="matlab:Simulink.UnitUtils.openObjectEditor(''%s'', ''%s'');">%s</a>',modelname,objName,objName);

                    suggested_unit=formatSuggestedUnit(cell2mat(AmbiguousUnitsCell(5,r)));

                    tableInfo5=[tableInfo5;{num2str(r),ambiguous_unit,suggested_unit,blkpath,className,objNameLink}];%#ok
                end

                table5.setTableInfo(tableInfo5);
                result{end+1}=table5;

            end

        else

            setSubResultStatus(ft4,'Pass');
            setSubResultStatusText(ft4,DAStudio.message('Simulink:tools:MAPassIdentAmbiguousUnits'))
            mdladvObj.setCheckResultStatus(true);
            ft4.setSubBar(0);
            result{end+1}=ft4;

        end

        function formattedSuggestion=formatSuggestedUnit(suggestion)
            units=strsplit(suggestion,", ");
            formattedSuggestion="";
            for unit=units
                formattedSuggestion=formattedSuggestion+"<li>"+cell2mat(unit)+"</li>";
            end

            if(formattedSuggestion~="")
                formattedSuggestion="<ol>"+formattedSuggestion+"</ol>";
            else
                formattedSuggestion="-";
            end


