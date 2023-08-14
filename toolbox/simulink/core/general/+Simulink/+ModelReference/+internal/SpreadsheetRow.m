




classdef SpreadsheetRow<handle
    properties(SetAccess=private,GetAccess=public)
m_DlgSource
m_Name
m_DefaultValue
m_ModelName
m_Value
m_FullPath
m_IsFromProtectedModel
m_SlimDialog
    end

    properties(Access=private,Constant=true)
        nameColumn=DAStudio.message('Simulink:dialog:ModelRefArgsTableNameColumn');
        valueColumn=DAStudio.message('Simulink:dialog:ModelRefArgsTableValueColumn');
        pathColumn=[DAStudio.message('Simulink:dialog:ModelRefArgsTableFullPathColumn'),' '];
        ownerColumn=DAStudio.message('Simulink:dialog:ModelRefArgsTableOwnerColumn');
    end

    properties(Access=public,Constant=true)
        protectedLabel=DAStudio.message('Simulink:dialog:ModelRefArgsTableProtectedModel');
    end

    methods
        function obj=SpreadsheetRow(aDlgSource,aName,aDefaultValue,aModelName,aValue,aFullPath,aIsFromProtectedModel,aIsSlimDialog)
            obj.m_DlgSource=aDlgSource;
            obj.m_Name=aName;
            if isempty(aDefaultValue)
                obj.m_DefaultValue='[]';
            else
                obj.m_DefaultValue=aDefaultValue;
            end
            obj.m_ModelName=aModelName;
            obj.m_Value=aValue;
            obj.m_FullPath=aFullPath;
            obj.m_IsFromProtectedModel=aIsFromProtectedModel;
            obj.m_SlimDialog=aIsSlimDialog;
        end

        function[aLabel]=getDisplayLabel(this)
            aLabel=this.m_Name;
        end

        function[aIcon]=getDisplayIcon(~)
            aIcon='';
        end

        function[bIsValid]=isValidProperty(this,aPropName)
            try
                switch(aPropName)
                case{this.nameColumn,this.valueColumn,this.pathColumn}
                    bIsValid=true;

                case{this.ownerColumn}
                    bIsValid=false;

                otherwise
                    bIsValid=false;
                end
            catch me
                this.reportError(me);
            end
        end

        function[bIsReadOnly]=isReadonlyProperty(this,aPropName)
            try
                switch(aPropName)
                case{this.valueColumn}
                    bIsReadOnly=false;

                otherwise
                    bIsReadOnly=true;
                end
            catch me
                this.reportError(me);
            end
        end

        function[aPropValue]=getPropValue(this,aPropName)
            try
                switch(aPropName)
                case{this.nameColumn}
                    aPropValue=this.m_Name;

                case{this.valueColumn}
                    if isempty(this.m_Value)
                        aPropValue=this.m_DefaultValue;
                    else
                        aPropValue=this.m_Value;
                    end

                case{this.pathColumn}
                    aPropValue=this.getBlockPathForDisplay();

                case{this.ownerColumn}
                    aPropValue=this.m_ModelName;

                otherwise
                    aPropValue='';
                end
            catch me
                this.reportError(me);
            end
        end

        function setPropValue(this,aPropName,aPropValue)
            try
                switch(aPropName)
                case{this.valueColumn}
                    if isempty(aPropValue)
                        this.m_Value=this.m_DefaultValue;
                    else
                        this.m_Value=aPropValue;
                    end


                    if this.m_SlimDialog
                        mdlrefddg_cb('SetModelArgs',this.m_DlgSource);
                    else
                        aDlgs=DAStudio.ToolRoot.getOpenDialogs(this.m_DlgSource);
                        for i=1:length(aDlgs)
                            aDlg=aDlgs(i);
                            aDlg.enableApplyButton(true);
                        end
                    end

                otherwise

                end
            catch me
                this.reportError(me);
            end
        end



        function getPropertyStyle(this,aPropName,aStyle)
            try
                switch(aPropName)
                case{this.nameColumn}
                    if(~this.isProtected())
                        aStyle.Tooltip=DAStudio.message('Simulink:dialog:ModelRefArgsTableNameColumnTooltip');
                    end

                case{this.ownerColumn}

                case{this.valueColumn}

                    if isempty(this.m_Value)
                        aStyle.Italic=true;
                        aStyle.ForegroundColor=[0,0,1];
                    end

                case{this.pathColumn}
                end
            catch me
                this.reportError(me);
            end
        end



        function isHyperlink=propertyHyperlink(this,aPropName,clicked)
            try
                isHyperlink=false;
                switch(aPropName)
                case{this.nameColumn}
                    if((~this.isProtected())&&(~this.isFromProtectedModel()))
                        isHyperlink=true;
                        if clicked
                            model=this.m_ModelName;
                            param=this.m_Name;
                            open_system(model);
                            slprivate('exploreListNode',model,'model',param);
                        end
                    end

                case{this.ownerColumn}
                    if((~this.isProtected())&&(~this.isFromProtectedModel()))
                        isHyperlink=true;

                        if clicked
                            model=this.m_ModelName;
                            open_system(model);
                        end
                    end
                end
            catch me
                this.reportError(me);
            end
        end
    end


    methods(Access=private)
        function reportError(~,me)
            dp=DAStudio.DialogProvider;
            title=DAStudio.message('Simulink:utility:ErrorDialogSeverityError');
            dp.errordlg(me.message,title,true);
        end

        function isFmProtModel=isFromProtectedModel(this)
            isFmProtModel=this.m_IsFromProtectedModel;
        end


        function isProtected=isProtected(this)
            isProtected=strcmp(this.m_FullPath,this.protectedLabel);
        end

        function displayString=getBlockPathForDisplay(this)
            displayString='';
            if(~this.isProtected())
                displayString=this.m_FullPath;
            end

            if isempty(displayString)
                displayString=' ';
            end
        end
    end

    methods(Access=public,Static=true)
        function lastBlock=getLastBlockInBlockPath(blockPath)




            [~,~,~,~,lastBlock]=regexp(blockPath,'^.*(?<!/)/(?!/)(.*)$');
            lastBlock=lastBlock{1};
            lastBlock=lastBlock{1};
        end
    end
end


