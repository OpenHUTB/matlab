classdef DynDialogManager<matlab.system.ui.DialogManager




    properties(Hidden)
        DDGDialog;
        SystemObjectParameterSchema;
        ActiveSystemObjectParameter;
        IsUsingMasking=false;
        SystemObjectPropertyTagInfo;
        SystemObjectParamExpression;
    end

    methods
        function obj=DynDialogManager(varargin)

            obj@matlab.system.ui.DialogManager(varargin{:});
            obj.SystemObjectParameterExpressions=containers.Map;
            obj.SystemObjectParameterCacheForCancel=containers.Map;
            obj.SystemObjectParameterSchema=containers.Map('KeyType','char','ValueType','any');
            obj.SystemObjectPropertyTagInfo=containers.Map('KeyType','char','ValueType','any');
            obj.SystemObjectParamExpression=containers.Map('KeyType','char','ValueType','any');

            mlock;
        end

        function dlgstruct=getBlockDialogSchema(obj,ddgDialog)
            obj.DDGDialog=ddgDialog;
            dlgstruct=getDialogManagerSchema(obj);
            dlgstruct.WebDialog={'MatlabOnline'};
        end

        function dlgstruct=getCustomErrorDialogSchema(obj,err)



            err=matlab.system.ui.DialogManager.removeHyperlinks(err);

            item.Type='text';
            item.Name=sprintf('%s\n%s',...
            getString(message('MATLAB:system:dialogNotGenerated',obj.System)),...
            err);
            item.WordWrap=true;
            item.Tag='text';

            dlgstruct.DialogTitle=getString(message('MATLAB:system:dialogError'));
            dlgstruct.DialogTag=['''',obj.System,''''];
            dlgstruct.Items={item};
        end

        function dlgstruct=getCustomExpandedErrorDialogSchema(obj,err,lineNum,methodName)

            dlgstruct=getCustomErrorDialogSchema(obj,err);


            import matlab.internal.lang.capability.Capability;
            if Capability.isSupported(Capability.LocalClient)
                link.Type='hyperlink';
                link.Name=getString(message('MATLAB:system:dialogNotGeneratedLink',...
                lineNum,obj.System,methodName));
                link.Tag='hyperlink';
                link.MatlabMethod='matlab.desktop.editor.openAndGoToLine';
                link.MatlabArgs={which(obj.System),lineNum};
                link.Graphical=true;

                dlgstruct.Items{end+1}=link;
            end
        end

        function dlgstruct=getDialogManagerSchema(obj)
            isUnspecifiedSO=~obj.IsSystemObjectValid||...
            isempty(obj.SystemObjectClassFile)||obj.ShowSystemParameter;

            if isUnspecifiedSO&&~obj.Platform.isPreview

            else
                try
                    dlgstruct=getDefaultDialogStruct(obj);
                catch e
                    errStack=e.stack;



                    implMethodNames={'getHeaderImpl','getPropertyGroupsImpl'};
                    for errInd=length(errStack):-1:1
                        thisFrame=errStack(errInd);
                        for implInd=1:numel(implMethodNames)
                            implMethod=implMethodNames{implInd};
                            if strcmp(thisFrame.name,[obj.System,'.',implMethod])
                                dlgstruct=getCustomExpandedErrorDialogSchema(obj,e.message,thisFrame.line,implMethod);
                                dlgstruct.DisplayIcon=obj.Platform.getDisplayIconPath();
                                return;
                            end
                        end
                    end



                    errMsg=obj.Platform.getDialogErrorMessage(e);
                    dlgstruct=getCustomErrorDialogSchema(obj,errMsg);
                end


                if obj.Platform.isPropertySetImmediate
                    dlgstruct.StandaloneButtonSet={'Help'};
                end
            end

            dlgstruct.DisplayIcon=obj.Platform.getDisplayIconPath();
            dlgstruct.ExplicitShow=true;
        end

        function dlgstruct=getDialogSchema(obj,~)
            dlgstruct=getDialogManagerSchema(obj);
            dlgstruct.WebDialog={'MatlabOnline'};
            if~isempty(obj.ActiveSystemObjectParameter)



                dlgstruct.Items=obj.SystemObjectParameterSchema(obj.ActiveSystemObjectParameter);
            end
        end

        function onDialogValidate(obj,varargin)

            obj.Platform.validatePropertyValuesSet;


            if nargin>1

                systemObjectParameters=varargin(1);
                paramValue=varargin(2);
            else
                systemObjectParameters=obj.SystemObjectParameterExpressions.keys;
            end
            for k=1:numel(systemObjectParameters)

                builder=obj.SystemObjectParameterExpressions(systemObjectParameters{k});



                if ischar(builder)
                    continue;
                end



                try
                    expression=builder.buildExpression;
                    if nargin>1
                        expression=paramValue{1};
                    end

                    obj.SystemObjectParamExpression(systemObjectParameters{k})=expression;
                    [paramBuilder,parseError]=matlab.system.ui.ConstructorBuilder.parse(expression);
                catch
                    error(message('MATLAB:system:DialogInvalidExpression'));
                end

                matlab.system.ui.DynDialogManager.validateExpression(obj,expression);
            end
        end

        function propSet(obj,~,propName,propValue)
            obj.Platform.setPropertyValue(propName,propValue);
        end

        function callAction(obj,dlg,action,actionTag)
            callbackFcn=action.ActionCalledFcn;
            if ischar(callbackFcn)
                evalin('base',callbackFcn)
            elseif dlg.hasUnappliedChanges
                if isprop(obj.Platform,'BlockHandle')
                    dialogTitle=get(obj.Platform.getSystemHandle,'Name');
                else
                    dialogTitle=class(obj.Platform.getSystemHandle);
                end
                dp=DAStudio.DialogProvider;
                matlab.system.ui.DynDialogManager.errorDialog(...
                dp.errordlg(getString(message('MATLAB:system:DialogUnappliedChangesText')),...
                getString(message('MATLAB:system:DialogUnappliedChangesTitle',dialogTitle)),true));
            else
                fevalCallback;
            end

            function fevalCallback
                dlg.setEnabled(actionTag,false);
                try
                    actionCache=obj.Platform.getActionCache(action,actionTag,obj.Platform.getSystemHandle);
                    try
                        sysObj=obj.Platform.getActionSystemObjectInstance(actionCache.Action,actionCache.ActionData);
                    catch instanceErr
                        error(message('MATLAB:system:DialogCannotCompleteAction',instanceErr.message));
                    end
                    feval(callbackFcn,actionCache.ActionData,sysObj);
                catch err
                    dp=DAStudio.DialogProvider;
                    matlab.system.ui.DynDialogManager.errorDialog(...
                    dp.errordlg(err.message,'Error',true));
                end
                dlg.setEnabled(actionTag,true);
                dlg.setFocus(actionTag);
            end
        end

        function propSetSystemObject(this,~,propValue,property,propertyInfo)


            paramName=propertyInfo.ParameterName;


            if~isKey(this.SystemObjectParameterCacheForCancel,paramName)
                this.SystemObjectParameterCacheForCancel(paramName)=this.Platform.getPropertyValue(paramName,false);
            end

            if property.IsLogical&&islogical(propValue)

                if propValue
                    propValue='true';
                else
                    propValue='false';
                end
            elseif property.IsStringSet
                if isnumeric(propValue)
                    propValue=property.StringSetValues{propValue+1};
                end
            elseif property.IsSystemObject

                if~property.ClassStringSet.AllowCustomExpression
                    propValue=property.ClassStringSet.Set{propValue+1};
                end


                matchingClassInd=strcmp(propValue,property.ClassStringSet.Labels);
                if any(matchingClassInd)
                    propValue=property.ClassStringSet.ConstructorExpressions{matchingClassInd};
                end
                this.SystemObjectParamExpression(paramName)=propValue;
            end







            objectAddress=propertyInfo.ObjectAddress;
            if isempty(objectAddress)



                cacheSystemObjectPropertyExpression(this,property,propValue);




                if~strcmp(propValue,property.ClassStringSet.CustomExpressionLabel)
                    this.Platform.setSystemObjectPropertyValue(paramName,propValue);
                end
            else




                propBuilder=this.SystemObjectParameterExpressions(paramName);
                nestedPropbuilder=propBuilder;
                for k=1:numel(objectAddress)-1
                    nestedPropbuilder=nestedPropbuilder.getParameterBuilder(objectAddress{k});
                end
                property.addDialogValue(propValue,nestedPropbuilder);




                if~property.IsSystemObject||~strcmp(propValue,property.ClassStringSet.CustomExpressionLabel)








                    try
                        expression=propBuilder.buildExpression;

                        if~isempty(propertyInfo.CustomPresenter)
                            expression=feval([propertyInfo.CustomPresenter,'.getParameterExpression'],expression);
                        end
                    catch e
                        this.SystemObjectParamExpression(paramName)=expression;
                        error(message('MATLAB:system:DialogInvalidExpression'));
                    end
                    this.SystemObjectParamExpression(paramName)=expression;
                    this.Platform.setSystemObjectPropertyValue(paramName,expression);
                end
            end
        end
    end

    methods
        function s=getDialogStructFromSystemDisplayGroups(obj,header,groups)


            systemName=obj.System;


            s.DialogTitle=getDialogTitle(obj.Platform);
            s.DialogTag=systemName;
            [helpFcnName,helpFcnArgs]=getHelpFunction(obj.Platform,systemName);
            s.HelpMethod=helpFcnName;
            s.HelpArgs=helpFcnArgs;
            s.ValidationCallback=@(dlg)onDialogValidate(obj);


            s.Items={getHeaderStruct(obj,header)};


            sectiongroups=[];
            numRows=1;
            for panelInd=1:numel(groups)
                group=groups(panelInd);
                if group.IsSection
                    sectionStruct=getSectionStruct(obj,group,0,panelInd);
                    if isempty(sectionStruct)
                        continue;
                    end
                    s.Items{end+1}=sectionStruct;
                    numRows=numRows+1;
                else
                    sectiongroups=[sectiongroups,group];%#ok<AGROW>
                end
            end


            numTabs=numel(sectiongroups);
            if(numTabs>0)
                numRows=numRows+1;
                tabContainer=struct('Type','tab','Tag','tabContainer');
                tabContainer.Tabs={};
                for tabInd=1:numTabs
                    sectiongroup=sectiongroups(tabInd);
                    sg=getSectionGroupStruct(obj,sectiongroup,tabInd);
                    tabContainer.Tabs{end+1}=sg;
                end
                s.Items{end+1}=tabContainer;
            end

            s.LayoutGrid=[numRows+1,obj.MaxNumColsInGrid];
            s.RowStretch=[zeros(1,numRows),1];
        end

        function s=getHeaderStruct(obj,header)



            headerTag=[header.Title,'Header'];
            title=header.Title;

            s=struct(...
            'Type','group',...
            'Name',title,...
            'Tag',headerTag);


            numRows=0;
            if~isempty(header.Text)
                numRows=numRows+1;
                desc.Type='text';
                desc.Tag=[headerTag,'Text'];

                if matlab.system.ui.isMessageID(header.Text)
                    desc.Name=getString(message(header.Text));
                else
                    desc.Name=header.Text;
                end
                desc.ColSpan=[1,obj.MaxNumColsInGrid];
                desc.RowSpan=[numRows,numRows];
                desc.WordWrap=true;
                s.Items={desc};
            else
                s.Items={};
            end



            if header.ShowSourceLink&&~(matlab.internal.environment.context.isMATLABOnline||matlab.ui.internal.desktop.isMOTW)
                numRows=numRows+1;
                w=struct('Type','hyperlink','Tag',[headerTag,'Hyperlink']);
                w.DialogRefresh=true;
                w.Name=obj.Platform.getSourceCodeLinkText;
                w.MatlabMethod='edit';
                w.MatlabArgs={obj.System};
                w.RowSpan=[numRows,numRows];
                s.Items=[s.Items,w];
            end

            s.LayoutGrid=[numRows+1,obj.MaxNumColsInGrid];
            s.RowStretch=[zeros(1,numRows),1];
        end

        function cacheSystemObjectPropertyExpression(obj,property,expression)


            if~isempty(property.CustomPresenter)
                builder=matlab.system.ui.ConstructorBuilder.parse(property,expression,property.CustomPresenterPropertyGroupsArgument);
            else
                builder=matlab.system.ui.ConstructorBuilder.parse(property,expression);
            end
            if isempty(builder)
                obj.SystemObjectParameterExpressions(property.BlockParameterName)=expression;
            else
                obj.SystemObjectParameterExpressions(property.BlockParameterName)=builder;
            end
        end

        function[propItems,rowInd]=getSystemObjectPropertySchema(obj,property,rowInd)


            paramName=property.BlockParameterName;


            if~obj.SystemObjectParameterExpressions.isKey(paramName)
                expression=getPropertyValue(obj.Platform,paramName,false);
                if~isempty(property.CustomPresenter)
                    expression=feval([property.CustomPresenter,'.getDialogExpression'],expression);
                end
                cacheSystemObjectPropertyExpression(obj,property,expression);
            end


            if~isPropertyVisible(obj.Platform,paramName)
                propItems={};
                return;
            end





            cachedValue=obj.SystemObjectParameterExpressions(paramName);
            isEnabled=isPropertyEnabled(obj.Platform,paramName);
            propInfo=struct('ParameterName',paramName);
            propInfo.CustomPresenter=property.CustomPresenter;
            propInfo.ObjectAddress={};




            propInfo.TagAddress={['_',paramName]};

            if ischar(cachedValue)
                propItems={};


                if numel(property.ClassStringSet.Set)>1
                    [lbl,w]=getSystemObjectCombobox(obj,property,rowInd,isEnabled,cachedValue,propInfo);
                    propItems={lbl,w};
                    rowInd=rowInd+1;
                end
            else


                if isprop(obj.Platform,'BlockHandle')
                    sysObj=cachedValue.constructObject(obj.Platform.BlockHandle);
                else
                    sysObj=cachedValue.constructObject;
                end
                [propItems,rowInd]=getSystemObjectPropertyAssistantSchema(obj,property,rowInd,isEnabled,cachedValue,sysObj,propInfo);
            end
        end

        function[lbl,w]=getSystemObjectCombobox(obj,property,rowInd,isEnabled,expression,propInfo)




            tagName=[propInfo.TagAddress{:}];



            w=struct('Tag',tagName,'Type','combobox','Editable',property.ClassStringSet.AllowCustomExpression);
            w.DialogRefresh=true;



            widgetPropInfo=propInfo;
            widgetPropInfo.Tag=tagName;
            if obj.IsUsingMasking
                w.ObjectMethod='handleSysObjectChangeEvent';
                w.MethodArgs={'%value',property,widgetPropInfo,tagName};
                w.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
            else
                w.ObjectMethod='propSetSystemObject';
                w.MethodArgs={'%dialog','%value',property,widgetPropInfo};
                w.ArgDataTypes={'handle','mxArray','mxArray','mxArray'};
            end
            w.RowSpan=[rowInd,rowInd];
            w.ColSpan=[0.4,1]*obj.MaxNumColsInGrid;
            w.Entries=property.ClassStringSet.Set;
            w.Enabled=isEnabled;
            w.Value=expression;
            w.UserData=obj.Platform.getDialogIdentifier;
            w.Graphical=isPropertySetImmediate(obj.Platform);


            lbl=struct('Tag',[w.Tag,'Label'],'Type','text','Buddy',w.Tag);
            lbl.RowSpan=[rowInd,rowInd];
            lbl.ColSpan=[0.1,0.3]*obj.MaxNumColsInGrid;
            if isempty(propInfo.ObjectAddress)
                prompt=getPropertyPrompt(obj.Platform,propInfo.ParameterName);
                if matlab.system.ui.isMessageID(prompt)
                    prompt=[getString(message(prompt)),':'];
                end
                lbl.Name=prompt;
            elseif matlab.system.ui.isMessageID(property.Description)
                lbl.Name=[getString(message(property.Description)),':'];
            else
                lbl.Name=[property.Description,':'];
            end
        end

        function[propItems,rowInd]=getSystemObjectPropertyAssistantSchema(obj,property,rowInd,isEnabled,builder,sysObj,propertyInfo)


            expression=builder.buildExpression;
            className=builder.ClassName;
            isCustomPresenter=~isempty(property.CustomPresenter);
            if isCustomPresenter
                classInd=1;
            else
                classInd=find(strcmp(property.ClassStringSet.Values,className));
            end


            propItems={};
            if~isCustomPresenter&&numel(property.ClassStringSet.Set)>1
                [lbl,w]=getSystemObjectCombobox(obj,property,rowInd,isEnabled,expression,propertyInfo);
                w.Value=property.ClassStringSet.Labels{classInd};
                propItems={lbl,w};
                rowInd=rowInd+1;
            end

            if isCustomPresenter



                classPropertyGroups=obj.Platform.getPropertyGroups(className,...
                'PropertyGroupsArgument',property.CustomPresenterPropertyGroupsArgument);
                for classGroupInd=1:numel(classPropertyGroups)
                    group=classPropertyGroups(classGroupInd);
                    groupInfo=propertyInfo;

                    if group.IsSectionGroup


                        classDialogProps=matlab.system.ui.getPropertyList(className,group,...
                        'IncludeSections',false,...
                        'IncludeFacade',false,...
                        'SetDescription',true);
                        for propInd=1:numel(classDialogProps)
                            [propItems,rowInd]=buildSystemObjectPropertyItems(classDialogProps(propInd),propItems,rowInd,groupInfo);
                        end


                        sections=group.Sections;
                        for sectionInd=1:numel(sections)
                            sectionInfo=groupInfo;
                            [propItems,rowInd]=buildSystemObjectCustomPresenterSectionItems(sections(sectionInd),propItems,rowInd,sectionInfo);
                        end
                    else
                        [propItems,rowInd]=buildSystemObjectCustomPresenterSectionItems(group,propItems,rowInd,groupInfo);
                    end
                end
            else

                groups=obj.Platform.getPropertyGroups(className);
                classDialogProps=matlab.system.ui.getPropertyList(className,groups,...
                'IncludeFacade',false,...
                'SetDescription',true);

                if property.ClassStringSet.NestDisplay
                    classPropItems={};
                    classPropRowInd=1;
                    for propInd=1:numel(classDialogProps)
                        [classPropItems,classPropRowInd]=buildSystemObjectPropertyItems(classDialogProps(propInd),classPropItems,classPropRowInd,propertyInfo);
                    end


                    s=struct('Type','group','Visible',true,...
                    'Name',property.ClassStringSet.PropertiesTitle,...
                    'Tag',[propertyInfo.TagAddress{:},'Panel']);
                    s.ColSpan=[1,obj.MaxNumColsInGrid];
                    s.RowSpan=[rowInd,rowInd];
                    s.LayoutGrid=[classPropRowInd,obj.MaxNumColsInGrid];
                    s.RowStretch=[zeros(1,classPropRowInd-1),1];
                    s.ColStretch=[zeros(1,obj.MaxNumColsInGrid-1),1];
                    s.Items=classPropItems;

                    propItems=[propItems,s];
                    rowInd=rowInd+1;
                else

                    for propInd=1:numel(classDialogProps)
                        [propItems,rowInd]=buildSystemObjectPropertyItems(classDialogProps(propInd),propItems,rowInd,propertyInfo);
                    end
                end
            end

            function[items,sectionRowInd]=buildSystemObjectCustomPresenterSectionItems(section,items,sectionRowInd,sectionInfo)


                if strcmpi(section.TitleSource,'auto')
                    panelTitle=getAutoSectionTitle(obj.Platform);
                else
                    panelTitle=section.Title;
                end

                sectionType=char(section.Type);
                if(strcmp(sectionType,'collapsiblepanel'))
                    sectionType='togglepanel';
                end

                ss=struct(...
                'Type',sectionType,...
                'Name',panelTitle,...
                'Tag',[sectionInfo.TagAddress{:},'_Section',num2str(sectionRowInd)]);
                ss.Items={};


                sectionDialogProps=matlab.system.ui.getPropertyList(className,section,...
                'IncludeFacade',false,...
                'SetDescription',true);
                ssRowInd=1;
                for sectionPropInd=1:numel(sectionDialogProps)
                    [ss.Items,ssRowInd]=buildSystemObjectPropertyItems(sectionDialogProps(sectionPropInd),ss.Items,ssRowInd,sectionInfo);
                end

                ss.RowSpan=[sectionRowInd,sectionRowInd];
                ss.ColSpan=[1,obj.MaxNumColsInGrid];
                ss.Visible=~obj.getAreAllItemsInvisible(ss);
                ss.LayoutGrid=[ssRowInd+1,obj.MaxNumColsInGrid];
                ss.RowStretch=[zeros(1,ssRowInd),1];
                ss.ColStretch=[zeros(1,obj.MaxNumColsInGrid-1),1];

                items=[items,ss];
                sectionRowInd=sectionRowInd+1;
            end

            function[items,propRowInd]=buildSystemObjectPropertyItems(prop,items,propRowInd,propInfo)
                if~prop.IsGraphical||sysObj.isInactiveProperty(prop.Name)
                    return;
                end



                if isParameter(builder,prop.Name)
                    widgetValue=builder.getLiteralParameterValue(prop.Name);
                else
                    try
                        prop.setDefault(sysObj);
                    catch






                        builderProperty=builder.ClassDisplayProperty;
                        propName=builder.ClassName;
                        matchingClassInd=strcmp(propName,property.ClassStringSet.Values);
                        if any(matchingClassInd)
                            propValue=builderProperty.ClassStringSet.ConstructorExpressions{matchingClassInd};
                            defaultSysObj=eval(propValue);
                            prop.setDefault(defaultSysObj);
                        end
                    end
                    widgetValue=prop.Default;

                    if prop.IsLogical
                        if strcmp(widgetValue,'on')
                            widgetValue='true';
                        else
                            widgetValue='false';
                        end
                    end




                    if prop.IsSystemObject
                        prop.addDialogValue(widgetValue,builder);
                    end
                end

                propInfo.TagAddress=[propInfo.TagAddress,'_',className,'_',prop.Name];
                propInfo.ObjectAddress=[propInfo.ObjectAddress,prop.Name];
                if prop.IsSystemObject
                    if isBuildableParameter(builder,prop.Name)
                        [sectionPropItems,propRowInd]=getSystemObjectPropertyAssistantSchema(...
                        obj,prop,propRowInd,isEnabled,builder.getParameterBuilder(prop.Name),sysObj.(prop.Name),propInfo);
                        items=[items,sectionPropItems];
                    else
                        [lbl,w]=getSystemObjectCombobox(obj,prop,propRowInd,isEnabled,widgetValue,propInfo);
                        items=[items,{lbl,w}];
                        propRowInd=propRowInd+1;
                    end
                else
                    items=[items,getSystemObjectPropertyItems(obj,prop,propRowInd,~isEnabled,widgetValue,propInfo)];
                    propRowInd=propRowInd+1;
                end
            end
        end

        function s=getSectionStruct(obj,section,sectionGroupInd,sectionInd)



            if strcmpi(section.TitleSource,'auto')
                panelTitle=getAutoSectionTitle(obj.Platform);
            else
                panelTitle=section.Title;
            end
            panelTag=['SectionGroup',num2str(sectionGroupInd),'_Section',num2str(sectionInd)];

            sectionType=char(section.Type);
            if(strcmp(sectionType,'collapsiblepanel'))
                sectionType='togglepanel';
            end

            s=struct(...
            'Type',sectionType,...
            'Name',panelTitle,...
            'Tag',panelTag);


            numRows=0;
            if~isempty(section.Description)
                numRows=numRows+1;
                desc.Type='text';
                desc.Tag=[panelTag,'Description'];
                desc.Name=section.Description;
                desc.WordWrap=true;
                desc.ColSpan=[1,obj.MaxNumColsInGrid];
                desc.RowSpan=[numRows,numRows];
                s.Items={desc};
            else
                s.Items={};
            end


            sectionProps=section.getDisplayProperties(obj.SystemMetaClass);
            sectionActions=section.Actions;


            if isempty(s.Items)&&isempty(sectionProps)&&isempty(sectionActions)
                s=[];
                return;
            end
            [s,numRows]=addGroupPropertiesAndActions(obj,sectionProps,sectionActions,s,numRows,panelTag);

            s.Visible=~obj.getAreAllItemsInvisible(s);
            s.LayoutGrid=[numRows+1,obj.MaxNumColsInGrid];
            s.RowStretch=[zeros(1,numRows),1];
            s.ColStretch=[zeros(1,obj.MaxNumColsInGrid-1),1];
        end

        function s=getSectionGroupStruct(obj,sectionGroup,sectionGroupInd)



            if strcmpi(sectionGroup.TitleSource,'auto')
                tabTitle=getAutoSectionGroupTitle(obj.Platform);
            else
                tabTitle=sectionGroup.Title;
            end
            tabTag=['SectionGroup',num2str(sectionGroupInd)];
            s=struct(...
            'Name',tabTitle,...
            'Tag',tabTag);


            numRows=0;
            if~isempty(sectionGroup.Description)
                numRows=numRows+1;
                desc.Type='text';
                desc.Tag=[tabTag,'Description'];
                desc.Name=sectionGroup.Description;
                desc.WordWrap=true;
                desc.ColSpan=[1,obj.MaxNumColsInGrid];
                desc.RowSpan=[numRows,numRows];
                s.Items={desc};
            else
                s.Items={};
            end


            sectionGroupProps=sectionGroup.getDisplayProperties(obj.SystemMetaClass);
            sectionGroupsActions=sectionGroup.Actions;
            [s,numRows]=addGroupPropertiesAndActions(obj,sectionGroupProps,sectionGroupsActions,s,numRows,tabTag);


            sections=sectionGroup.Sections;
            for sectionInd=1:sectionGroup.NumSections
                sectionStruct=getSectionStruct(obj,sections(sectionInd),sectionGroupInd,sectionInd);
                if isempty(sectionStruct)
                    continue;
                end
                numRows=numRows+1;
                sectionStruct.RowSpan=[numRows,numRows];
                sectionStruct.ColSpan=[1,obj.MaxNumColsInGrid];
                s.Items=[s.Items,sectionStruct];
            end

            s.Visible=~obj.getAreAllItemsInvisible(s);
            s.LayoutGrid=[numRows+1,obj.MaxNumColsInGrid];
            s.RowStretch=[zeros(1,numRows),1];
            s.ColStretch=[zeros(1,obj.MaxNumColsInGrid-1),1];
        end

        function[s,numRows]=addGroupPropertiesAndActions(obj,groupProps,groupActions,s,numRows,groupTag)

            [firstActions,insertActions,lastActions]=sortActions(groupActions);
            actionInd=0;
            actionTag=[groupTag,'_Action'];


            for action=firstActions
                [s,numRows,actionInd]=addActionItems(obj,s,action,numRows,actionTag,actionInd);
            end

            for propInd=1:numel(groupProps)
                property=groupProps(propInd);
                if~property.IsGraphical
                    continue;
                end

                if~isempty(insertActions)
                    matchingActions=insertActions(strcmp(property.Name,{insertActions.Placement}));
                    for action=matchingActions
                        [s,numRows,actionInd]=addActionItems(obj,s,action,numRows,actionTag,actionInd);
                    end
                end

                numRows=numRows+1;
                if property.IsSystemObject
                    [propItems,numRows]=getSystemObjectPropertySchema(obj,property,numRows);

                    obj.SystemObjectParameterSchema(property.Name)=propItems;
                else
                    propItems=getPropertyItems(obj,property,numRows);
                end
                s.Items=[s.Items,propItems];
            end


            for action=lastActions
                [s,numRows,actionInd]=addActionItems(obj,s,action,numRows,actionTag,actionInd);
            end
        end

        function[s,numRows,actionInd]=addActionItems(obj,s,action,numRows,actionTag,actionInd)
            numRows=numRows+1;
            actionInd=actionInd+1;
            s.Items=[s.Items,getActionItems(obj,action,numRows,[actionTag,num2str(actionInd)])];
        end

        function propItems=getPropertyItems(obj,property,rowInd)


            propName=property.BlockParameterName;







            showAsText=property.IsReadOnly&&~strcmp(propName,'SimulateUsing');
            if showAsText
                tagName=[propName,'Text'];
            else
                tagName=propName;
            end


            w=struct('Tag',tagName);
            w.Value=getPropertyValue(obj.Platform,propName,property.IsLogical);
            w.Enabled=isPropertyEnabled(obj.Platform,propName);
            w.Visible=isPropertyVisible(obj.Platform,propName);
            w.ObjectMethod='propSet';
            w.MethodArgs={'%dialog','%tag','%value'};
            w.ArgDataTypes={'handle','string','mxArray'};
            w.RowSpan=[rowInd,rowInd];
            w.ColSpan=[0.4,1]*obj.MaxNumColsInGrid;
            w.Graphical=isPropertySetImmediate(obj.Platform);
            tooltipText=property.TooltipText;
            if~isempty(tooltipText)
                if matlab.system.ui.isMessageID(tooltipText)
                    tooltipText=getString(message(tooltipText));
                end
                w.ToolTip=tooltipText;
            end


            lbl.Type='text';
            lbl.Tag=[w.Tag,'Label'];
            lbl.Buddy=w.Tag;
            lbl.Visible=w.Visible;
            lbl.RowSpan=[rowInd,rowInd];
            lbl.ColSpan=[0.1,0.3]*obj.MaxNumColsInGrid;
            prompt=getPropertyPrompt(obj.Platform,propName);
            if matlab.system.ui.isMessageID(prompt)
                prompt=getString(message(prompt));
            end
            lbl.Name=prompt;
            if~isempty(tooltipText)
                lbl.ToolTip=tooltipText;
            end
            if strcmp(propName,'SimulateUsing')
                lbl.Enabled=w.Enabled;
            end


            if showAsText
                w.Type='text';
                if property.IsLogical
                    if w.Value
                        w.Name='true';
                    else
                        w.Name='false';
                    end
                else
                    w.Name=w.Value;
                end
                w=rmfield(w,{'Value','ObjectMethod','MethodArgs','ArgDataTypes'});
                w.Enabled=true;
                propItems={lbl,w};
            elseif property.IsLogical
                w.Type='checkbox';
                w.DialogRefresh=true;
                w.ColSpan=[0.1,1]*obj.MaxNumColsInGrid;
                w.Name=prompt;
                propItems={w};
            elseif property.IsStringSet
                w.Type='combobox';
                w.DialogRefresh=true;
                if property.IsLocalizedStringSet


                    w.Entries=property.LocalizedStringSetValues;
                    ind=find(strcmpi(w.Value,property.StringSetValues));
                    if~isempty(ind)
                        w.Value=property.LocalizedStringSetValues{ind};
                    end
                else
                    w.Entries=getStringSetValues(obj.Platform,property);
                end
                propItems={lbl,w};
            elseif property.IsEnumeration
                w.Type='combobox';
                w.DialogRefresh=true;
                if property.IsLocalizedStringSet
                    w.Entries=property.LocalizedStringSetValues;
                else
                    w.Entries=property.StringSetValues;
                end

                if property.IsEnumerationDynamic
                    [activeIdx,valueIdx]=getActiveEnumerationMembersAndValueIndex(obj.Platform,property);
                    w.Entries=w.Entries(activeIdx);
                    w.Value=w.Entries{valueIdx};
                end

                propItems={lbl,w};
            elseif~isempty(property.StaticRange)









                if ischar(w.Value)
                    if(isvarname(w.Value))
                        maskVals=get_param(obj.Platform.BlockHandle,'MaskWSVariables');
                        maskNames={maskVals.Name};
                        w.Value=maskVals(strcmp(maskNames,w.Tag)).Value;
                    else
                        w.Value=str2double(w.Value);
                    end
                end
                w.Range=property.StaticRange;
                w.Graphical=true;
                if~isempty(property.WidgetType)
                    w.Type=char(property.WidgetType);
                else
                    w.Type='dial';
                end
                w.Name=prompt;
                w.Alignment=6;
                w.ColSpan=[.1,1]*obj.MaxNumColsInGrid;
                propItems={w};
            else
                w.Type='edit';
                propItems={lbl,w};
            end
        end

        function propItems=getActionItems(obj,action,rowInd,actionTag)



            w=struct('Tag',actionTag);
            w.Name=action.Label;
            w.ToolTip=action.Description;
            w.Type='pushbutton';
            w.Enabled=action.IsEnabledFcn(obj.Platform.getSystemHandle);



            w.ObjectMethod='callAction';
            w.MethodArgs={'%dialog',action,actionTag};
            w.ArgDataTypes={'handle','mxArray','string'};
            obj.Platform.updateActionCache(action,actionTag,obj.Platform.getSystemHandle);


            w.RowSpan=[rowInd,rowInd];
            if strcmp(action.Alignment,'left')
                w.ColSpan=[0.1,0.1]*obj.MaxNumColsInGrid;
                w.Alignment=1;
            else
                w.ColSpan=[1,1]*obj.MaxNumColsInGrid;
                w.Alignment=7;
            end

            propItems={w};
        end

        function propItems=getSystemObjectPropertyItems(obj,property,rowInd,isLocked,v,propertyInfo)




            tagName=[propertyInfo.TagAddress{:}];


            w=struct('Tag',tagName);
            w.Value=v;
            w.Enabled=~isLocked;
            w.Visible=true;
            widgetPropInfo=propertyInfo;
            widgetPropInfo.Tag=tagName;
            if obj.IsUsingMasking
                w.ObjectMethod='handleSysObjectChangeEvent';
                w.MethodArgs={'%value',property,widgetPropInfo,tagName};
                w.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
            else
                w.ObjectMethod='propSetSystemObject';
                w.MethodArgs={'%dialog','%value',property,widgetPropInfo};
                w.ArgDataTypes={'handle','mxArray','mxArray','mxArray'};
            end
            w.RowSpan=[rowInd,rowInd];
            w.ColSpan=[0.4,1]*obj.MaxNumColsInGrid;
            w.Graphical=isPropertySetImmediate(obj.Platform);
            w.UserData=obj.Platform.getDialogIdentifier;


            lbl.Type='text';
            lbl.Tag=[w.Tag,'Label'];
            lbl.Buddy=w.Tag;
            lbl.Visible=w.Visible;
            lbl.RowSpan=[rowInd,rowInd];
            lbl.ColSpan=[0.1,0.3]*obj.MaxNumColsInGrid;


            if property.IsReadOnly
                w.Type='text';
                if property.IsLogical
                    if w.Value
                        w.Name='true';
                    else
                        w.Name='false';
                    end
                else
                    w.Name=w.Value;
                end
                w=rmfield(w,{'Value','ObjectMethod','MethodArgs','ArgDataTypes'});
                w.Enabled=true;
                if any(strcmp(w.Type,{'edit','popup','combobox'}))
                    propDescription=property.Description;
                    if matlab.system.ui.isMessageID(propDescription)
                        propDescription=getString(message(propDescription));
                    end
                    lbl.Name=[propDescription,':'];
                end
                propItems={lbl,w};
            elseif property.IsLogical
                w.Type='checkbox';
                w.DialogRefresh=true;
                w.Value=strcmp(v,'true');
                w.ColSpan=[0.1,1]*obj.MaxNumColsInGrid;
                w.Name=property.Description;
                propItems={w};
            elseif property.IsStringSet
                w.Type='combobox';
                w.DialogRefresh=true;

                if property.IsLocalizedStringSet


                    strSetValues=property.LocalizedStringSetValues;
                    ind=find(strcmpi(w.Value,property.StringSetValues));
                    if~isempty(ind)
                        w.Value=property.LocalizedStringSetValues{ind};
                    end
                else
                    strSetValues=property.StringSetValues;
                    if isstring(strSetValues)


                        strSetValues=strSetValues.cellstr;
                    end
                end

                w.Entries=strSetValues;

                if property.IsLocalizedStringSet


                    ind=find(strcmpi(w.Value,strSetValues));
                    if~isempty(ind)
                        w.Value=property.LocalizedStringSetValues{ind};
                    end
                end

                propDescription=property.Description;
                if matlab.system.ui.isMessageID(propDescription)
                    propDescription=getString(message(propDescription));
                end
                lbl.Name=[propDescription,':'];
                propItems={lbl,w};
            else
                w.Type='edit';
                if obj.IsUsingMasking


                    obj.SystemObjectPropertyTagInfo(tagName)={property,widgetPropInfo};
                end
                if~property.IsStringLiteral

                    w.ActionProperty=propertyInfo.ParameterName;
                end
                propDescription=property.Description;
                if matlab.system.ui.isMessageID(propDescription)

                    propDescription=getString(message(propDescription));
                end
                lbl.Name=[propDescription,':'];
                propItems={lbl,w};
            end
        end
    end

    methods(Static)
        function onMaskDialogValidate(systemHandle,paramName,paramValue)
            [~,~,isExprResolved]=matlab.system.ui.ConstructorBuilder.resolveExpression(paramValue,systemHandle);
            if isExprResolved
                dm=matlab.system.ui.BlockDialogManager.getInstance;
                dynDialog=dm.get(systemHandle);
                if(~isempty(dynDialog))
                    dynDialog.onDialogValidate(paramName,char(paramValue));
                else
                    matlab.system.ui.DynDialogManager.validateExpression...
                    (dynDialog,char(paramValue),systemHandle);
                end
            end
        end

        function validateExpression(obj,expression,systemHandle)


            try
                [paramBuilder,parseError]=matlab.system.ui.ConstructorBuilder.parse(char(expression));
            catch
                error(message('MATLAB:system:DialogInvalidExpression'));
            end

            if isempty(paramBuilder)



                if parseError
                    error(message('MATLAB:system:DialogInvalidExpression'));
                end
            else
                if~isempty(obj)

                    if isprop(obj.Platform,'BlockHandle')
                        paramBuilder.validateObject(obj.Platform.BlockHandle);
                    end
                else
                    if~isempty(systemHandle)
                        paramBuilder.validateObject(systemHandle);
                    else
                        paramBuilder.validateObject;
                    end
                end
            end
        end

        function onSystemDeleted(systemHandle)


            dm=matlab.system.ui.BlockDialogManager.getInstance;
            dm.remove(systemHandle);

            errorDlg=matlab.system.ui.DynDialogManager.errorDialog;
            if~isempty(errorDlg)&&ishandle(errorDlg)
                delete(errorDlg);
            end
            if isKey(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle)
                actionMap=getKeyValue(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle);
                keys=actionMap.keys;
                for k=1:numel(keys)
                    actionCache=actionMap(keys{k});
                    callback=actionCache.Action.SystemDeletedFcn;
                    if~isempty(callback)
                        feval(callback,actionCache.ActionData);
                    end
                end

                matlab.system.ui.PlatformDescriptor.SystemMap.remove(systemHandle);
                if isKey(matlab.system.ui.PlatformDescriptor.SystemNameMap,systemHandle)
                    systemName=matlab.system.ui.SystemNameMap.getSystemName(systemHandle);
                    matlab.system.ui.PlatformDescriptor.SystemNameMap.remove(systemName);
                end
            end
        end

        function onModelStarted(systemHandle)
            matlab.system.ui.ImplementSystemObjectUsingMask.updateActionsEnabled(systemHandle);
        end

        function onModelStopped(systemHandle)
            matlab.system.ui.ImplementSystemObjectUsingMask.updateActionsEnabled(systemHandle);
        end

        function onDialogApplied(systemHandle,platformDescriptor)


            if isKey(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle)
                sysObj=[];
                actionMap=getKeyValue(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle);
                keys=actionMap.keys;
                for k=1:numel(keys)
                    actionCache=actionMap(keys{k});

                    callback=actionCache.Action.DialogAppliedFcn;
                    if~isempty(callback)
                        if isempty(sysObj)
                            try
                                if nargin>1
                                    sysObj=platformDescriptor.getActionSystemObjectInstance(actionCache.Action,actionCache.ActionData);
                                else

                                    sysObj=matlab.system.ui.SimulinkDescriptor.getBlockActionSystemObjectInstance(...
                                    systemHandle,get(systemHandle,'System'),actionCache.Action,actionCache.ActionData);
                                end
                            catch

                                return;
                            end
                        end
                        feval(callback,actionCache.ActionData,sysObj);
                    end
                end
            end
        end

        function v=errorDialog(newV)



            persistent ErrorDialog;

            if nargin
                if~isempty(ErrorDialog)&&ishandle(ErrorDialog)
                    delete(ErrorDialog);
                end
                ErrorDialog=newV;
            end

            if nargout
                v=ErrorDialog;
            end
        end
    end
end

function[firstActions,insertActions,lastActions]=sortActions(actions)

    firstActions=matlab.system.display.Action.empty;
    insertActions=matlab.system.display.Action.empty;
    lastActions=matlab.system.display.Action.empty;
    for action=actions
        switch action.Placement
        case 'first'
            firstActions=[firstActions,action];%#ok<AGROW>
        case 'last'
            lastActions=[lastActions,action];%#ok<AGROW>
        otherwise
            insertActions=[insertActions,action];%#ok<AGROW>
        end
    end
end

