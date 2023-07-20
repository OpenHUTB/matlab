classdef RenameVariableDialog<handle





    properties(Access=private)

        Model;


        Source;




        DDScope;


        OldName;


        SearchReferencedModels;


        Update;


        IsVarInGlobalWS;


        GlobalSources;


        sourcesFound;
    end

    methods
        function obj=RenameVariableDialog(model,source,ddScope,...
            oldName,...
            searchRefMdls,...
            update,...
            isVarInGlobalWS)
            assert(ischar(source)&&strcmp(source(1),'^')&&strcmp(source(end),'$'));
            assert(islogical(searchRefMdls));
            assert(islogical(update));
            assert(islogical(isVarInGlobalWS));

            obj.Model=model;
            obj.Source=source;
            obj.DDScope=ddScope;
            obj.OldName=oldName;
            obj.SearchReferencedModels=searchRefMdls;
            obj.Update=update;
            obj.IsVarInGlobalWS=isVarInGlobalWS;
            obj.GlobalSources={};
            obj.sourcesFound=0;

            assert(searchRefMdls==isVarInGlobalWS);
            if~isVarInGlobalWS
                assert(ischar(model)==1);



                assert(startsWith(['^',model],extractBetween(source,1,strlength(source)-1)));
            end
        end

        function dlgStruct=getDialogSchema(obj)
            if obj.Update
                searchMethod='compiled';
            else
                searchMethod='cached';
            end

            [sources,varUsage]=Simulink.data.internal.renameAllAnalyze(obj.Model,...
            obj.IsVarInGlobalWS,...
            obj.DDScope,...
            obj.OldName,...
            'SearchReferencedModels',false,...
            'SearchMethod',searchMethod);



            rowIdx=1;

            srcNum=numel(sources);
            obj.sourcesFound=srcNum;
            sources=join(sources,'|');

            if numel(varUsage)==1&&isempty(varUsage.Users)
                srcNum=0;
            end

            if srcNum==1
                descTxtContent=DAStudio.message('Simulink:studio:UpdateAllBlocksVariable');
            elseif srcNum>1
                assert(obj.IsVarInGlobalWS);
                descTxtContent=DAStudio.message('Simulink:studio:FindMultiGlobalVars',...
                num2str(srcNum),obj.OldName);
                obj.GlobalSources=sources{1};
            else
                descTxtContent=DAStudio.message('Simulink:studio:NotFoundContinue');
            end

            descTxt.Name=descTxtContent;
            descTxt.Type='text';
            descTxt.WordWrap=true;
            descTxt.RowSpan=[rowIdx,rowIdx];
            descTxt.ColSpan=[1,2];

            rowIdx=rowIdx+1;

            if srcNum>0
                source=obj.Source(2:end-1);
                if strcmp(source,'base workspace')
                    source=DAStudio.message('SLDD:sldd:BaseWorkspace');
                end

                allVars=DAStudio.message('Simulink:studio:AllVariables');
                oneVar=DAStudio.message('Simulink:studio:OneVariable',source);

                varList.Name='renameOneOrAll';
                varList.HideName=true;
                varList.Type='combobox';
                varList.Tag='globalSrcs';
                varList.Entries={allVars,oneVar};
                varList.RowSpan=[rowIdx,rowIdx];
                varList.ColSpan=[1,2];
                varList.Editable=false;

                rowIdx=rowIdx+1;
            end

            oldNameTitle.Name=DAStudio.message('Simulink:studio:OldName');
            oldNameTitle.Type='text';
            oldNameTitle.RowSpan=[rowIdx,rowIdx];
            oldNameTitle.ColSpan=[1,1];

            oldName.Name=obj.OldName;
            oldName.Type='text';
            oldName.Tag='oldName';
            oldName.RowSpan=[rowIdx,rowIdx];
            oldName.ColSpan=[2,2];

            rowIdx=rowIdx+1;

            newNameTitle.Name=DAStudio.message('Simulink:studio:NewName');
            newNameTitle.Type='text';
            newNameTitle.RowSpan=[rowIdx,rowIdx];
            newNameTitle.ColSpan=[1,1];

            newName.Type='edit';
            newName.Value=obj.OldName;
            newName.Tag='newName';
            newName.RowSpan=[rowIdx,rowIdx];
            newName.ColSpan=[2,2];

            rowIdx=rowIdx+1;

            referencesTable.Type='textbrowser';
            if srcNum>0
                referencesTable.Text=obj.getReferencesHTML(varUsage);
            else
                referencesTable.Text="No referenced variables in corresponding blocks";
            end
            referencesTable.RowSpan=[rowIdx,rowIdx];
            referencesTable.ColSpan=[1,2];
            referencesTable.Tag='references';

            rowIdx=rowIdx+1;

            if srcNum>1
                dlgStruct.Items={descTxt,varList,oldNameTitle,oldName,...
                newNameTitle,newName,referencesTable};
            elseif srcNum>0
                dlgStruct.Items={descTxt,oldNameTitle,oldName,...
                newNameTitle,newName,referencesTable};
            else
                dlgStruct.Items={descTxt,oldNameTitle,oldName,...
                newNameTitle,newName};
            end
            dlgStruct.StandaloneButtonSet={'OK','Cancel'};
            dlgStruct.DialogTitle=DAStudio.message('Simulink:studio:RenameAllTitle');
            dlgStruct.DialogTag=['RenameAll:',obj.OldName];
            dlgStruct.LayoutGrid=[rowIdx,2];
            dlgStruct.ColStretch=[0,1];
            dlgStruct.AlwaysOnTop=true;
            dlgStruct.OpenCallback=@SLStudio.RenameVariableDialog.openCB;
            dlgStruct.PreApplyCallback='preApplyCB';
            dlgStruct.PreApplyArgs={'%source','%dialog'};
            dlgStruct.PreApplyArgsDT={'handle','handle'};
        end

        function[success,errMsg]=preApplyCB(obj,dialog)

            errMsg=[];
            try
                newName=dialog.getWidgetValue('newName');
                if~isvarname(newName)
                    success=false;
                    m=message('Simulink:Data:RenameAllInvalidName',newName);
                    errMsg=m.getString;
                    return;
                end

                sources=obj.Source;
                val=dialog.getWidgetValue('globalSrcs');
                if~isempty(val)&&val==0
                    assert(obj.IsVarInGlobalWS);
                    assert(numel(obj.GlobalSources)>1);
                    sources=obj.GlobalSources;
                end

                if obj.sourcesFound>0



                    Simulink.data.internal.renameAllApply(obj.Model,'Variable',...
                    obj.OldName,newName,...
                    'Regexp','on',...
                    'Source',sources,...
                    'Scope',obj.DDScope,...
                    'SearchReferencedModels',obj.SearchReferencedModels,...
                    'SearchMethod','cached');


                elseif~obj.IsVarInGlobalWS

                    modelName=extractBetween(sources,2,strlength(sources)-1);
                    mws=get_param(modelName{1},'ModelWorkspace');
                    renameVariable(mws,obj.OldName,newName);
                elseif isempty(obj.DDScope)

                    copyCmd=[newName,' = ',obj.OldName,';'];
                    evalin('base',copyCmd);

                    clearCmd=['clear ',obj.OldName,';'];
                    evalin('base',clearCmd);
                else

                    ddNames=split(sources,'|');
                    for i=1:length(ddNames)
                        ddName=extractBetween(ddNames{i},2,strlength(ddNames{i})-1);
                        dd=Simulink.data.dictionary.open(ddName{1});
                        if strcmp(obj.DDScope,'Design')
                            ddSection=getSection(dd,'Design Data');
                        else
                            ddSection=getSection(dd,'Configurations');
                        end
                        if ddSection.exist(obj.OldName)
                            entry=ddSection.getEntry(obj.OldName);
                            assert(numel(entry)==1,DAStudio.message('Simulink:studio:MultipleDictionariesFound',obj.OldName));
                            entry.Name=newName;
                        end
                    end
                end

                success=true;

            catch e
                success=false;
                Simulink.output.error(e);
            end

        end
    end

    methods(Access=private)


        function html=getReferencesHTML(obj,varUsage)



            blocks=containers.Map;





            configSets=containers.Map;
            variantConfigurations=containers.Map;







            getReferencesHTML_addVariableUsage(...
            obj,varUsage,blocks,configSets,variantConfigurations);



            html=[...
'<html><body padding="0" spacing="0">'...
            ,'<table width="100%" cellpadding="0" cellspacing="0">'];

            blockKeys=blocks.keys;
            if~isempty(blockKeys)
                correspondingBlocks=...
                DAStudio.message('Simulink:dialog:RenameAllCorrespondingBlocks');
                html=[html...
                ,'<tr><td align="left"><b>',correspondingBlocks,'</b></td>'...
                ,'</tr>'];
                for i=1:length(blockKeys)
                    blk=blockKeys{i};
                    bHdlStr=sprintf('%15.14f',get_param(blk,'Handle'));
                    blkHtmlEscape=rtwprivate('rtwhtmlescape',blk);
                    html=[html,'<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'...
                    ,'<a href="matlab:eval(''view(get_param(str2num('''''...
                    ,bHdlStr,'''''),''''Object''''));'')">',blkHtmlEscape,'</a>'...
                    ,'</td><td></td></tr>'];%#ok
                end
            end

            configKeys=configSets.keys;
            if~isempty(configKeys)
                correspondingConfigSets=...
                DAStudio.message('Simulink:dialog:RenameAllCorrespondingConfigSets');
                activeMsg=DAStudio.message('RTW:configSet:titleStrActive');
                html=[html...
                ,'<tr><td align="left"><b>',correspondingConfigSets,'</b></td>'...
                ,'</tr>'];
                for i=1:length(configKeys)
                    model=configKeys{i};
                    modelHtmlEscape=rtwprivate('rtwhtmlescape',model);
                    cs=getActiveConfigSet(model);
                    csNameHtmlEscape=rtwprivate('rtwhtmlescape',cs.Name);
                    html=[html,'<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'...
                    ,'<a href="matlab:eval(''view(getActiveConfigSet('''''...
                    ,modelHtmlEscape,'''''));'')">'...
                    ,modelHtmlEscape,'/',csNameHtmlEscape,' ',activeMsg...
                    ,'</a>'...
                    ,'</td><td></td></tr>'];%#ok
                end
            end

            variantConfigurationsKeys=variantConfigurations.keys;
            if~isempty(variantConfigurationsKeys)
                correspondingVariantConfigurations=getString(message('Simulink:dialog:RenameAllCorrespondingVariantConfigurations'));
                html=[html...
                ,'<tr><td align="left"><b>',correspondingVariantConfigurations,'</b></td>'...
                ,'</tr>'];


                for i=1:length(variantConfigurationsKeys)
                    model=variantConfigurationsKeys{i};
                    modelHtmlEscape=rtwprivate('rtwhtmlescape',model);
                    vcoName=get_param(model,'VariantConfigurationObject');
                    if slfeature('VMGRV2UI')>0
                        command=['slvariants.internal.manager.ui.openStandAloneForModel(''''',modelHtmlEscape,''''')'];
                    else
                        command=['variantmanager(''''OpenStandAloneForModel'''', ''''',modelHtmlEscape,''''')'];
                    end
                    vcoNameHtmlEscape=rtwprivate('rtwhtmlescape',vcoName);
                    html=[html,'<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'...
                    ,'<a href="matlab:eval(''',command,''')">'...
                    ,modelHtmlEscape,'/',vcoNameHtmlEscape,' '...
                    ,'</a>'...
                    ,'</td><td></td></tr>'];%#ok
                end
            end

            html=[html,'</table></body></html>'];
        end

        function getReferencesHTML_addVariableUsage(...
            obj,varUsage,...
            blocks,configSets,variantConfigurations)
            protectedModels={};
            for i=1:length(varUsage)
                var=varUsage(i);
                usageDetails=var.DirectUsageDetails;
                for j=1:length(usageDetails)
                    detail=usageDetails(j);
                    props=detail.Properties;
                    if any(strcmp(props,'Protected property'))



                        model=detail.Identifier;
                        protectedModels{end+1}=model;%#ok
                    else
                        switch(detail.UsageType)
                        case 'Block'

                            blocks(detail.Identifier)=[];

                        case 'Port'


                            for m=1:length(var.Users)
                                blocks(var.Users{m})=[];
                            end

                        case 'Variable'











                            getReferencesHTML_addVariableUsage(...
                            obj,detail.Identifier,blocks,configSets,variantConfigurations);



                        case 'Configuration'
                            configSets(detail.Identifier)=[];
                        case 'VariantConfiguration'
                            variantConfigurations(detail.Identifier)=[];
                        otherwise
                            assert(false,['Unsupported usage type: ',detail.UsageType]);
                        end
                    end
                end
            end

            if~isempty(protectedModels)
                e=MException(message('Simulink:Data:RenameAllProtectedModel'));
                names=unique(protectedModels);
                for i=1:length(names)
                    cause=MException(message('Simulink:SLMsgViewer:GENERIC_MSG',names{i}));
                    e=e.addCause(cause);
                end
                throw(e);
            end
        end
    end

    methods(Static,Access=private)
        function openCB(dastudioDlg)
            dastudioDlg.setFocus('newName');
        end
    end

    methods(Static,Hidden)



        function[success,errMsg]=launch(models,source,ddScope,...
            oldName,searchRefMdls,update,isVarInGlobalWS)
            success=true;
            errMsg='';

            try
                dlg=SLStudio.RenameVariableDialog(models,...
                source,ddScope,oldName,searchRefMdls,update,...
                isVarInGlobalWS);
                DAStudio.Dialog(dlg,'','DLG_STANDALONE');
            catch e



                Simulink.output.error(e);
            end
        end
    end
end


