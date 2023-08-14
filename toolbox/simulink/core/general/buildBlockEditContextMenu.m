function actions=buildBlockEditContextMenu(dlgSrc,propertyName,textToParse)






    actions=[];
    classSuggestion='Default';
    tempDlgSource=dlgSrc;

    [parent,blockFullName,dlgSrc,searchLoc]=slprivate('getBlockInformationFromSource',dlgSrc,propertyName);
    if~isempty(parent)&&~isempty(blockFullName)
        root=parent;
        mdl_name='';
        ssref_block_with_dd=slprivate('getNearestSSRefBlockWithDDAttached',blockFullName);
        if~isempty(ssref_block_with_dd)
            mdl_name=get_param(ssref_block_with_dd,'ReferencedSubsystem');
        end
        if isempty(mdl_name)
            while~(isa(root,'Simulink.BlockDiagram')||isa(root,'Simulink.slobject.BlockDiagram'))
                root=root.getParent;
            end
            mdl_name=root.getFullName;
        end
        try




            classSuggestion=dlgSrc.getClassSuggestion(propertyName);
            [actionTunablePopup,associateAction]=getMaskTunablePopupAction(tempDlgSource,mdl_name,blockFullName,propertyName,textToParse);
            if(associateAction)
                actions=actionTunablePopup;
                return;
            end
            varList=parseExpression(textToParse);
        catch
            varList=[];
        end



        if isempty(varList)




            [resolution,isExists]=slResolve(textToParse,blockFullName);

            if~isempty(resolution)&&isExists




                textToParse=strrep(textToParse,'''','''''');



                varFromExprMenuItem=l_createLabelSetHandle(textToParse,mdl_name,dlgSrc,classSuggestion,blockFullName,propertyName);
                varFromExprMenuItem.label=DAStudio.message('Simulink:dialog:VariableContextMenu_Create_From_Expression');
                varFromExprMenuItem.enabled=true;
                varFromExprMenuItem.visible=true;

                actions=varFromExprMenuItem;
            end
        elseif~isempty(searchLoc)



            for varName=varList
                docActions=[];
                openFunctionActions=[];
                exploreactions=[];
                openactions=[];
                enabled=true;%#ok
                isVariable=true;%#ok
                isExplorable=true;%#ok
                fileName='';%#ok
                varName=varName{1};
                [location,isVariable]=slprivate('getVariableLocation',mdl_name,varName,blockFullName,searchLoc);

                if isVariable
                    [location,fullName,fileName,isExplorable,enabled]=slprivate('parseLocation',mdl_name,location,varName);
                    if isempty(location)
                        notFound=l_createLabelSetHandle(varName,mdl_name,dlgSrc,classSuggestion,blockFullName,'');
                        notFound.enabled=true;
                        notFound.visible=true;
                        actionsForVariable=notFound;
                        menuItem=buildMenuItem(actionsForVariable,varName);
                        actions=[actions,menuItem];
                    else
                        found.label=DAStudio.message('Simulink:dialog:VariableContextMenu_Open');
                        found.enabled=enabled;
                        found.visible=true;
                        found.command=['slprivate(''showWorkspaceVar'', ''',location,''', ''',varName,''', ''',fileName,''');'];
                        openactions=[openactions,found];
                        found.label=DAStudio.message('Simulink:dialog:VariableContextMenu_Explore');
                        found.enabled=isExplorable;
                        found.command=['slprivate(''exploreListNode'', ''',fileName,''', ''',location,''', ''',varName,''');'];
                        exploreactions=[exploreactions,found];
                        actionsForVariable=[openactions,exploreactions];
                        if isequal(fullName,DAStudio.message('Simulink:dialog:WorkspaceLocation_Dictionary'))
                            menuItem=buildMenuItem(actionsForVariable,[varName,' (',fileName,')']);
                        else
                            menuItem=buildMenuItem(actionsForVariable,[varName,' (',fullName,')']);
                        end
                        actions=[actions,menuItem];
                    end
                else
                    try
                        functionActions=l_createActionsForFunction(varName);
                        docActions=[docActions,functionActions.docactions];
                        if~(isempty(functionActions.openactions))
                            openFunctionActions=[openFunctionActions,functionActions.openactions];
                            actionsForVariable=[docActions,openFunctionActions];
                        else
                            actionsForVariable=[docActions];
                        end
                        menuItem=buildMenuItem(actionsForVariable,[varName,' (Function)']);
                        actions=[actions,menuItem];
                    catch
                    end
                end
            end
        end



...
...
...
...
...
...
...
...
...
    end

end

function[actions,associateAction]=getMaskTunablePopupAction(dlgSource,modelName,blockFullName,parameterName,parameterValue)
    actions=[];
    associateAction=false;

    maskObj=Simulink.Mask.get(blockFullName);
    if~isempty(maskObj)
        paramHandle=maskObj.getParameter(parameterName);
        if isempty(paramHandle)||isempty(paramHandle.TypeOptions)
            return;
        end

        typeOptionValue=paramHandle.TypeOptions;
        if strcmp(paramHandle.Type,'promote')
            typeOptionValue=getTypeOptionValueForPromotedParam(blockFullName,paramHandle);
        end

        if~isempty(typeOptionValue)&&isa(typeOptionValue,'Simulink.Mask.EnumerationTypeOptions')
            associateAction=true;
            enumClassFileName=typeOptionValue.ExternalEnumerationClass;
            if isempty(enumClassFileName)
                enumClassFileName=typeOptionValue.InternalEnumerationClass;
            end
            typeOptionElements=typeOptionValue.EnumerationMembers;
            if(isempty(typeOptionElements))
                return;
            end
            indexOfSelectedValue=strcmp({typeOptionElements.DescriptiveName},parameterValue);
            enumOptionName=[enumClassFileName,'.',typeOptionElements(indexOfSelectedValue).MemberName];

            dialogs=DAStudio.ToolRoot.getOpenDialogs(dlgSource);
            if(isempty(dialogs))
                return;
            end
            dialog=dialogs(1);
            associatedVarTag=[parameterName,'_Value'];
            widgetValue=dialog.getWidgetValue(associatedVarTag);
            actions.command=['obj = slprivate(''tunableParameterAssociateVarDDG.instatiateObject'', ''',dialog.dialogTag,''' , ''',parameterName,''', ''',widgetValue,''', ''',enumOptionName,''', ''',modelName,''' , ''',blockFullName,''');slprivate(''showDDG'',obj)'];
            actions.label=DAStudio.message('Simulink:dialog:AssociatedVariableGroup');
            actions.enabled=true;
            actions.visible=true;
        end
    end
end

function typeOptionValue=getTypeOptionValueForPromotedParam(blockFullName,paramHandle)
    typeOptionValue=paramHandle.TypeOptions;
    if isempty(typeOptionValue)
        return;
    end
    promotedFromParameter=typeOptionValue{1};
    lastDelimiterPos=find(promotedFromParameter=='/',1,'last');
    promotedFromBlock=promotedFromParameter(1:lastDelimiterPos-1);
    promotedParam=promotedFromParameter(lastDelimiterPos+1:end);
    blockFullName=[blockFullName,'/',promotedFromBlock];
    promotedFromBlockMask=Simulink.Mask.get(blockFullName);
    if~isempty(promotedFromBlockMask)
        handle=promotedFromBlockMask.getParameter(promotedParam);
        if~isempty(handle)
            if strcmp(handle.Type,'promote')
                typeOptionValue=getTypeOptionValueForPromotedParam(blockFullName,handle);
                if isa(typeOptionValue,'Simulink.Mask.EnumerationTypeOptions')
                    return;
                end
            end
            typeOptionValue=handle.TypeOptions;
        end
    end
end


function menuItem=buildMenuItem(actionList,label)
    menuItem=[];
    if length(actionList)>1
        menuItem.label=label;
        menuItem.command=actionList;
        menuItem.enabled=true;
        menuItem.visible=true;
    elseif length(actionList)==1
        actionList(1).label=[label,': ',actionList(1).label];
        menuItem=actionList(1);
    end
end

function varList=parseExpression(textToParse)
    tree=mtree(textToParse);
    ids=tree.mtfind('Kind','ID');
    vars=strings(ids);
    varList=unique(vars,'stable');

end

function tf=isFunction(fName)
    fName=[fName,'.m'];
    tree=mtree(fName,'-file');

    tf=strcmp(tree.root.kind,'FUNCTION');
end

function functionActions=l_createActionsForFunction(functionName)

    funcActionsList=[];
    functionActions.docactions=[];
    functionActions.openactions=[];

    functionType=exist(functionName);%#ok
    actionLabel=[];
    helpLabel=DAStudio.message('Simulink:dialog:VariableContextMenu_Help');

    if desktop('-inuse')
        helpCommand=['helpPopup(''',functionName,''')'];
    else

        helpCommand=['doc(''',functionName,''')'];
    end
    openLabel=DAStudio.message('Simulink:dialog:VariableContextMenu_Open');
    openCommand=['open(''',functionName,''')'];

    if(isequal(functionType,5)||isequal(functionType,6))
        actionLabel={helpLabel};
        actionCommand={helpCommand};
    elseif isFunction(functionName)
        actionLabel={helpLabel,openLabel};
        actionCommand={helpCommand,openCommand};
    end

    for i=1:length(actionLabel)

        funcFound.label=actionLabel{i};
        funcFound.command=[actionCommand{i}];
        funcFound.enabled=true;
        funcFound.visible=true;
        funcActionsList=[funcActionsList,funcFound];%#ok
    end
    functionActions.docactions=funcActionsList(1);
    if isequal(length(actionLabel),2)
        functionActions.openactions=funcActionsList(2);
    end
end

function notFound=l_createLabelSetHandle(varName,mdl_name,dlgSrc,classSuggestion,blockFullName,propertyName)



    notFound.label=DAStudio.message('Simulink:dialog:VariableContextMenu_Create');
    createDataDDG.getSetHandle('');
    if isequal(classSuggestion,'Signal')
        if((isa(dlgSrc,'Simulink.Line')||isa(dlgSrc,'Simulink.LinePropertiesDDGSource')))
            portObj=dlgSrc.getSourcePort;
            createDataDDG.getSetHandle(portObj.Handle);

            if~(dlgSrc.MustResolveToSignalObject)
                notFound.label=DAStudio.message('Simulink:dialog:VariableContextMenu_Create_Resolve');
            end
        else
            createDataDDG.getSetHandle(dlgSrc.Handle);
            if((isprop(dlgSrc,'MustResolveToSignalObject')&&isequal(dlgSrc.MustResolveToSignalObject,'off'))...
                ||(isprop(dlgSrc,'StateMustResolveToSignalObject')&&isequal(dlgSrc.StateMustResolveToSignalObject,'off')))
                notFound.label=DAStudio.message('Simulink:dialog:VariableContextMenu_Create_Resolve');
            end
        end
        blockFullName='';
    end




    blockFullName=regexprep(blockFullName,'\r?\n?',' ');

    if strcmp(classSuggestion,'Enum')&&isempty(get_param(mdl_name,'DataDictionary'))


        notFound.command=['slprivate(''createEnumClassDefinition'', '''...
        ,varName,''', ''',mdl_name,''', ''',classSuggestion,''', ''',blockFullName,''');'];
    else


        notFound.command=['slprivate(''createWorkspaceVar'', '''...
        ,varName,''', ''',mdl_name,''', ''',classSuggestion,''', ''',blockFullName,''', ''',propertyName,''');'];
    end
end
