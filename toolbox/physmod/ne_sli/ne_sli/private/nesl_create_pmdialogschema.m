function dlgSchema=nesl_create_pmdialogschema(componentSchema,hSlBlk)












    cmpInfo=componentSchema.info();
    descrText=cmpInfo.Description;
    blockTitle=cmpInfo.Descriptor;


    blockTitle=sprintf(blockTitle);










    if endsWith(cmpInfo.File,'.p')&&contains(cmpInfo.Description,cmpInfo.DotPath)
        descrText=get_param(hSlBlk,'MaskDescription');
    end

    descPnl=NetworkEngine.PmNeDescriptionPanel(...
    hSlBlk,descrText,blockTitle);

    myBlder=PMDialogs.PmDlgBuilder(hSlBlk);
    myBlder.Items=descPnl;
    moreDlgItems=[];
    paramsVec=cmpInfo.Members.Parameters;
    nParams=numel(paramsVec);



    hasIcTab=false;
    if(strcmpi('hydraulic_fluid',cmpInfo.Name))
        fluidPropPnl=HYDRO.PmHydroFluidPropPanel(hSlBlk);
        moreDlgItems=[moreDlgItems,fluidPropPnl];
    elseif(strcmpi('thermal_fluid',cmpInfo.Name))
        fluidPropPnl=STH.PmHydroFluidPropPanel(hSlBlk);
        moreDlgItems=[moreDlgItems,fluidPropPnl];
    else

        hasVisibleParams=~isempty(paramsVec);
        paramPanel={};
        if hasVisibleParams
            tabs=unique({paramsVec.Group},'stable');
            paramPanel=cell(1,numel(tabs));
            for ii=1:numel(tabs)
                paramPanel{ii}=PMDialogs.PmGroupPanel(hSlBlk,...
                tabs{ii},'Box','3ColLayout');
            end

            for idx=1:nParams
                item=paramsVec(idx);
                compiletimeOption=...
                'physmod:common:pi:sli:kernel:RuntimeCompiletimeOption';
                runtimeOption=...
                'physmod:common:pi:sli:kernel:RuntimeRuntimeOption';
                paramConfigLabel=...
                'physmod:ne_sli:dialog:ParameterConfLabel';
                paramUnitLabel=...
                'physmod:ne_sli:dialog:ParameterUnitLabel';

                paramName=item.ID;

                paramLabel=item.Label;

                unitName=[paramName,'_unit'];
                unitLabel={paramLabel,paramUnitLabel};

                confName=[paramName,'_conf'];
                confLabel={paramLabel,paramConfigLabel};
                confValues={'compiletime'};
                confValue=compiletimeOption;
                confChoiceVals={compiletimeOption};
                if item.Runtime
                    confValues{end+1}='runtime';%#ok<AGROW>
                    confChoiceVals{end+1}=runtimeOption;%#ok<AGROW>
                end

                if~isempty(item.Choices)
                    editUnitPnl=NetworkEngine.PmGuiDropDown(hSlBlk,paramName,...
                    paramLabel,1,{item.Choices.Description},...
                    double([item.Choices.Value]),{item.Choices.Expression});
                elseif strcmp(item.Default.Value,'true')||...
                    strcmp(item.Default.Value,'false')
                    editUnitPnl=NetworkEngine.PmGuiDropDown(hSlBlk,paramName,...
                    paramLabel,1,{'True','False'},[1,0],...
                    {'true','false'});
                elseif~isempty(pm.sli.getEnumData(item.Default.Value))
                    d=pm.sli.getEnumData(item.Default.Value);
                    editUnitPnl=NetworkEngine.PmGuiDropDown(hSlBlk,paramName,...
                    paramLabel,1,d.enumStrings,d.enumValues,d.enumValMap);
                elseif~isstruct(item.Default.Unit)&&strcmp(item.Default.Unit,'1')
                    editUnitPnl=PMDialogs.PmEditBox(hSlBlk,paramLabel,paramName,1,...
                    confLabel,confName,confChoiceVals,...
                    confValue,confValues);
                else
                    editUnitPnl=PMDialogs.PmEditUnit(hSlBlk,paramLabel,1,...
                    paramLabel,paramName,unitLabel,unitName,item.Default.Unit,true,...
                    confLabel,confName,confChoiceVals,...
                    confValue,confValues);
                end
                idxTab=strcmp(tabs,item.Group);
                paramPanel{idxTab}=laddItem(paramPanel{idxTab},editUnitPnl);
            end
        end
        moreDlgItems=[moreDlgItems,paramPanel{:}];
        variablesVec=cmpInfo.Members.Variables;


        variablesVec=variablesVec(arrayfun(@(v)~isempty(v.Group),variablesVec));

        hasIcTab=~isempty(variablesVec);
        if hasVisibleParams||hasIcTab
            settingsContainer=...
            'physmod:ne_sli:dialog:SettingssContainer';

            tabPanel=PMDialogs.PmGroupPanel(...
            hSlBlk,settingsContainer,'TabContainer');

            for idx=1:numel(moreDlgItems)
                tmpPage=PMDialogs.PmGroupPanel(...
                hSlBlk,moreDlgItems(idx).LabelText,'TabPage');
                moreDlgItems(idx).LabelText='';
                tmpPage.Items=moreDlgItems(idx);
                tabPanel=laddItem(tabPanel,tmpPage);
            end

            if(hasIcTab)


                variablesTabLabel=variablesVec(1).Group;
                icTab=PMDialogs.PmGroupPanel(hSlBlk,variablesTabLabel,'TabPage');
                icPanel=PMDialogs.PmGroupPanel(hSlBlk,...
                '','Box','Unset');
                icPanel.Items=NetworkEngine.PmNeVariableTargets(hSlBlk,...
                cmpInfo.Members.Variables);
                icTab.Items=icPanel;
                tabPanel=laddItem(tabPanel,icTab);
            end

            boxPanel=PMDialogs.PmGroupPanel(hSlBlk,settingsContainer,'Box');
            boxPanel.Items=tabPanel;

            moreDlgItems=boxPanel;
        end
    end

    if hasIcTab

        myBlder.Items=[myBlder.Items,moreDlgItems];
    else
        spacer=PMDialogs.PmGroupPanel(hSlBlk,' ','Spacer');
        myBlder.Items=[myBlder.Items,moreDlgItems,spacer];
    end

    dlgSchema=[];
    [status,dlgSchema]=myBlder.getPmSchema(dlgSchema);%#ok
end

function aPanel=laddItem(aPanel,aItem)

    if(isempty(aPanel.Items))
        aPanel.Items=aItem;
    else
        aPanel.Items(end+1)=aItem;
    end
end
