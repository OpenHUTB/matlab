
classdef InstParamSpreadsheetRow<handle
    properties(SetAccess=private,GetAccess=public)
m_RealPath
m_Name
m_DefaultValue
m_DefaultValueInstSpec
m_Value
m_InstanceSpecific
m_IsFromProtectedModel
m_SIDPath
    end
    properties(SetAccess=private,GetAccess=private)
m_DlgSource
m_IsTerminalNode
m_Source
m_ModelName
m_SlimDialog
m_ParameterCreatedFrom
m_ParentName
m_DefaultValueInternal
    end
    properties(Hidden=true)
m_Children
    end

    properties(Access=private,Constant=true)
        sourceColumn=DAStudio.message('Simulink:dialog:ModelRefArgsTableSourceColumn');
        valueColumn=DAStudio.message('Simulink:dialog:ModelRefArgsTableValueColumn');
        instanceSpecificColumn=DAStudio.message('Simulink:dialog:ModelRefArgsTableInstanceSpecificCheckBoxColumn');
    end

    methods
        function obj=InstParamSpreadsheetRow(aDlgSource,aSource,aIsSlimDialog,aRealPath,aName,aDefaultValue,aDefaultValueInstSpec,aDefaultValueInternal,aModelName,aValue,aInstanceSpecific,aSIDPath,aIsFromProtectedModel,aParameterCreatedFrom)
            try
                if nargin==4
                    obj.m_DlgSource=aDlgSource;
                    obj.m_IsTerminalNode=false;
                    obj.m_SlimDialog=aIsSlimDialog;
                    obj.m_Source=aSource;
                    obj.m_RealPath=aRealPath;
                    obj.m_Name=[];
                    obj.m_DefaultValue=[];
                    obj.m_DefaultValueInstSpec=[];
                    obj.m_ModelName=[];
                    obj.m_Value=[];
                    obj.m_InstanceSpecific=[];
                    obj.m_IsFromProtectedModel=[];
                    obj.m_SIDPath=[];
                    obj.m_Children=[];
                    obj.m_ParameterCreatedFrom=[];
                elseif nargin==14
                    obj.m_DlgSource=aDlgSource;
                    obj.m_IsTerminalNode=true;
                    obj.m_SlimDialog=aIsSlimDialog;
                    obj.m_Source=aSource;
                    obj.m_RealPath=aRealPath;
                    obj.m_Name=aName;
                    obj.m_DefaultValue=aDefaultValue;
                    obj.m_DefaultValueInstSpec=aDefaultValueInstSpec;
                    obj.m_DefaultValueInternal=aDefaultValueInternal;
                    obj.m_ModelName=aModelName;
                    obj.m_Value=aValue;
                    obj.m_InstanceSpecific=aInstanceSpecific;
                    obj.m_IsFromProtectedModel=aIsFromProtectedModel;
                    obj.m_SIDPath=aSIDPath;
                    obj.m_Children=[];
                    obj.m_ParameterCreatedFrom=aParameterCreatedFrom;
                    obj.m_ParentName=get_param(obj.m_DlgSource.getBlock().Handle,'Parent');
                end
            catch me
                this.reportError(this,me);
            end
        end


        function ch=getChildren(this,~)
            ch=this.m_Children;
        end

        function ch=getHierarchicalChildren(this)
            ch=this.m_Children;
        end

        function tf=isHierarchical(this)
            tf=~isempty(this.m_Children);
        end

        function tf=isHierarchicalChildren(this)
            tf=~isempty(this.m_Children);
        end

        function appendChildren(this,children)
            this.m_Children=[this.m_Children,children];
        end

        function removeChildren(this,idx)
            this.m_Children(idx)=[];
        end

        function[aLabel]=getDisplayLabel(this)
            if~this.m_IsTerminalNode
                modelNameAndModelBlockName=strsplit(this.m_Source,'/');
                modelBlockName=modelNameAndModelBlockName(end);
                modelBlockName=modelBlockName{:};
                aLabel=modelBlockName;
            else
                aLabel=this.m_Name;
            end
        end

        function fileName=getDisplayIcon(~)
            fileName='';
        end

        function[bIsValid]=isValidProperty(this,aPropName)
            try
                switch(aPropName)
                case{this.sourceColumn}
                    bIsValid=true;
                case{this.valueColumn,this.instanceSpecificColumn}
                    if this.m_IsTerminalNode
                        bIsValid=true;
                    else
                        bIsValid=false;
                    end
                otherwise
                    bIsValid=false;
                end
            catch me
                this.reportError(this,me);
            end
        end

        function[bIsReadOnly]=isReadonlyProperty(this,aPropName)
            try
                switch(aPropName)
                case{this.instanceSpecificColumn}
                    if(this.m_DlgSource.isHierarchySimulating)
                        bIsReadOnly=cosimBlockddg_cb('EnableParamArgValues',this.m_DlgSource);
                    elseif bdIsLibrary(bdroot(this.m_DlgSource.getBlock.Handle))||...
                        bdIsSubsystem(bdroot(this.m_DlgSource.getBlock.Handle))||...
                        ~strcmp(get_param(this.m_DlgSource.getBlock.Handle,'LinkStatus'),'none')
                        bIsReadOnly=true;
                    else
                        bIsReadOnly=false;
                    end
                case{this.valueColumn}
                    if(this.m_DlgSource.isHierarchySimulating)
                        blockH=this.m_DlgSource.getBlock.Handle;
                        modelH=bdroot(blockH);
                        isRefModel=~isempty(get_param(modelH,'ModelReferenceNormalModeVisibilityBlockPath'));
                        if(isRefModel&&strcmp(this.m_InstanceSpecific,'on'))
                            bIsReadOnly=true;
                        else
                            bIsReadOnly=false;
                        end
                    else
                        bIsReadOnly=false;
                    end

                otherwise
                    bIsReadOnly=true;
                end
            catch me
                this.reportError(this,me);
            end
        end

        function[bIsReadOnly]=isHierarchyReadonly(this)
            bIsReadOnly=false;
            if(this.m_DlgSource.isHierarchySimulating)
                blockH=this.m_DlgSource.getBlock.Handle;
                modelH=bdroot(blockH);
                if(isParameterWrittenByParamWriter(this,modelH,blockH))
                    bIsReadOnly=true;
                end
            end
        end

        function[aPropValue]=getPropValue(this,aPropName)
            try
                switch(aPropName)
                case{this.valueColumn}
                    if isempty(this.m_Value)
                        if this.getIsArgument()
                            aPropValue=this.m_DefaultValueInstSpec;
                        else
                            aPropValue=this.m_DefaultValue;
                        end
                    else
                        aPropValue=this.m_Value;
                    end
                case{this.sourceColumn}
                    if~this.m_IsTerminalNode
                        modelNameAndModelBlockName=strsplit(this.m_Source,'/');
                        modelBlockName=modelNameAndModelBlockName(end);
                        modelBlockName=modelBlockName{:};
                        aPropValue=modelBlockName;
                    else
                        aPropValue=this.m_Name;
                    end
                case{this.instanceSpecificColumn}
                    aPropValue=this.m_InstanceSpecific;
                otherwise
                    aPropValue='';
                end
            catch me
                this.reportError(this,me);
            end
        end

        function setInstanceSpecificPropValue(this,aPropValue)
            this.m_InstanceSpecific=aPropValue;




            this.m_Value=this.getInternalArgumentValue(this.m_Value);

            if this.getIsArgument
                aDlgs=DAStudio.ToolRoot.getOpenDialogs(this.m_DlgSource);
                for i=1:length(aDlgs)
                    dlg=aDlgs(i);
                    src=dlg.getWidgetSource('cosim_ArgumentSpreadsheet');
                    src.showPromotedModelArgumentDialog();
                end
            end

            if this.m_SlimDialog
                cosimBlockddg_cb('SetInstSpecModelArgs',this.m_DlgSource);
            else
                aDlgs=DAStudio.ToolRoot.getOpenDialogs(this.m_DlgSource);
                for i=1:length(aDlgs)
                    aDlg=aDlgs(i);
                    aDlg.enableApplyButton(true);
                end
            end
        end

        function setPropValue(this,aPropName,aPropValue)
            try
                switch(aPropName)
                case{this.valueColumn}
                    orgVal=this.m_Value;
                    this.m_Value=this.getInternalArgumentValue(aPropValue);

                    if this.m_SlimDialog
                        cosimBlockddg_cb('SetInstSpecModelArgs',this.m_DlgSource);
                    else
                        aDlgs=DAStudio.ToolRoot.getOpenDialogs(this.m_DlgSource);
                        for i=1:length(aDlgs)
                            aDlg=aDlgs(i);
                            aDlg.enableApplyButton(true);
                        end
                    end

                case{this.instanceSpecificColumn}
                    this.setInstanceSpecificPropValue(aPropValue);

                otherwise

                end
                aDlgs=DAStudio.ToolRoot.getOpenDialogs(this.m_DlgSource);
                for i=1:length(aDlgs)
                    aDlg=aDlgs(i);
                    aDlg.enableApplyButton(true);
                end
            catch me
                this.reportError(this,me);
                this.m_Value=orgVal;
            end
        end

        function[aPropType]=getPropDataType(this,aPropName)
            try
                switch(aPropName)
                case{this.instanceSpecificColumn}
                    aPropType='bool';
                otherwise
                    aPropType='string';
                end
            catch me
                this.reportError(this,me);
            end
        end


        function getPropertyStyle(this,aPropName,aStyle)
            try
                if this.isValidProperty(aPropName)
                    switch(aPropName)
                    case{this.instanceSpecificColumn}

                        if this.getIsArgument()
                            aStyle.Tooltip=DAStudio.message('Simulink:dialog:ModelRefArgsTableInstanceSpecificCheckedTooltip');
                        else
                            aStyle.Tooltip=DAStudio.message('Simulink:dialog:ModelRefArgsTableInstanceSpecificUncheckedTooltip',...
                            this.m_Name,this.m_ParentName);
                        end

                    case{this.sourceColumn}
                        if~(this.m_IsTerminalNode)
                            blockPath=this.getBlockPathForTooltip();
                            aStyle.Tooltip=blockPath;
                        elseif~this.isFromProtectedModel()
                            blockPath=this.getBlockPathForTooltip();
                            aStyle.Tooltip=[DAStudio.message('Simulink:dialog:ModelRefArgsTableNameColumnTooltip'),...
                            newline,blockPath];
                        end
                    case{this.valueColumn}
                        if(this.m_IsTerminalNode)
                            if isequal(this.m_Value,this.m_DefaultValueInternal)
                                aStyle.Tooltip=DAStudio.message('Simulink:dialog:ModelRefArgsTableInstanceSpecificDefaultValueTooltip',...
                                this.m_Name);
                            else
                                aStyle.Tooltip=DAStudio.message('Simulink:dialog:ModelRefArgsTableInstanceSpecificValueTooltip',...
                                this.m_Name);
                            end
                        end
                    end
                end
            catch me
                this.reportError(this,me);
            end
        end

        function isHyperlink=propertyHyperlink(this,aPropName,clicked)
            try
                isHyperlink=false;
                switch(aPropName)
                case{this.sourceColumn}
                    if~this.isFromProtectedModel()
                        isHyperlink=true;
                        if clicked
                            if(~isempty(this.m_ParameterCreatedFrom))
                                model=this.m_ParameterCreatedFrom;
                            else
                                model=this.m_ModelName;
                            end
                            param=this.m_Name;
                            open_system(model);
                            slprivate('exploreListNode',model,'model',param);
                        end
                    end
                end
            catch me
                this.reportError(this,me);
            end
        end

        function rtn=hasPropertyActions(this,propertyName)%#ok<INUSL>

            rtn=false;
            if strcmp(propertyName,'Value')
                rtn=true;
            end
        end

        function rtn=getPropertyActions(this,propertyName,propertyValue)

            rtn=[];
            if(strcmp(propertyName,'Value'))
                blk=this.m_DlgSource.getBlock();
                internalValue=this.getInternalArgumentValue(propertyValue);
                try

                    otherActions=getPropertyActions(blk,this.m_SIDPath,internalValue);
                catch
                    otherActions=[];
                end

                try

                    blkFullName=blk.getFullName;
                    rtn=Simulink.cosimblock.internal.PropActionResetToDefault.build(...
                    blkFullName,this.m_SIDPath,internalValue,true);
                    rtn=[otherActions,rtn];
                catch
                    rtn=otherActions;
                end
            end
        end

        function found=findAndUpdateInHierarchy(this,sidPath,propName,propValue)
            found=false;

            if this.isHierarchical
                for i=1:length(this.m_Children)
                    found=findAndUpdateInHierarchy(this.m_Children(i),...
                    sidPath,propName,propValue);
                    if found
                        return;
                    end
                end
            elseif isequal(this.m_SIDPath,sidPath)
                found=true;
                this.setPropValue(propName,propValue);
            end
        end
    end

    methods(Access=private)
        function isFmProtModel=isFromProtectedModel(this)
            isFmProtModel=this.m_IsFromProtectedModel;
        end

        function tooltipValue=getBlockPathForTooltip(this)
            tooltipValue='';

            indent='';

            for i=1:length(this.m_RealPath)
                nextPath=this.m_RealPath{i};
                if(~isempty(tooltipValue))
                    tooltipValue=sprintf('%s\n',tooltipValue);
                    indent=[indent,'  '];
                end
                tooltipValue=sprintf('%s%s%s',tooltipValue,indent,nextPath);
            end

            if(~isempty(tooltipValue))
                tooltipValue=sprintf('%s\n',tooltipValue);
                indent=[indent,'  '];
            end
            if this.m_IsTerminalNode
                tooltipValue=sprintf('%s%s%s',tooltipValue,indent,this.m_ParameterCreatedFrom);

            else
                tooltipValue=sprintf('%s',tooltipValue);
            end
        end

        function displayString=getBlockPathForDisplay(this)
            displayString='';
            if(~this.isFromProtectedModel())
                if(~isempty(this.m_RealPath))
                    for i=1:this.m_RealPath.getLength()
                        thisPath=this.m_RealPath.getBlock(i);
                        lastBlock=this.getLastBlockInBlockPath(thisPath);

                        if(~isempty(displayString))
                            displayString=[displayString,':'];
                        end
                        displayString=[displayString,lastBlock];
                    end
                end
            end

            if isempty(displayString)
                displayString=' ';
            end
        end




        function isParamWritten=isParameterWrittenByParamWriter(this,modelH,blockH)
            isParamWritten=false;
            accessorMap=get_param(modelH,'ParamAccessorInfoMap');
            for k=1:length(accessorMap)
                if((accessorMap(k).ParamOwnerBlock==blockH)&&(strcmp(accessorMap(k).ParamName,this.m_Name)==1))
                    writerSet=[accessorMap(k).ParamWriterBlockSet,accessorMap(k).StateflowSfuncSet];
                    for i=1:length(writerSet)
                        if strcmp(get_param(writerSet(i),'Commented'),'off')
                            isParamWritten=true;
                            return;
                        end
                    end
                else
                    continue;
                end
            end
        end
    end

    methods(Access=private,Static=true)
        function reportError(~,me)
            dp=DAStudio.DialogProvider;
            title=DAStudio.message('Simulink:utility:ErrorDialogSeverityError');
            dp.errordlg(me.message,title,true);
        end

        function lastBlock=getLastBlockInBlockPath(blockPath)




            [~,~,~,~,lastBlock]=regexp(blockPath,'^.*(?<!/)/(?!/)(.*)$');
            lastBlock=lastBlock{1};
            lastBlock=lastBlock{1};
        end
    end

    methods(Access=private)
        function isArgument=getIsArgument(this)
            isArgument=(isequal(this.m_InstanceSpecific,'on')||...
            isequal(this.m_InstanceSpecific,'1'));
        end

        function value=getInternalArgumentValue(this,aValue)



            value=aValue;
            if this.getIsArgument()
                if isequal(aValue,this.m_DefaultValueInstSpec)
                    value=this.m_DefaultValueInternal;
                end
            else
                if isequal(aValue,this.m_DefaultValue)
                    value=this.m_DefaultValueInternal;
                end
            end
        end
    end
end
