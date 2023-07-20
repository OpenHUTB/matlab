classdef ResolvedDDGSource<handle











    properties
UserData
    end
    properties(SetAccess=private)
m_ddConn
m_entryID
m_scope
m_upToDate

m_entryInfo
m_entryValueIsMxArray

m_modifiedInDialog
m_ddModificationListener
        m_resolvedView;
    end
    properties(Constant)
        m_metaDataProperties=...
        {'Name',...
        'DataSource',...
        'Status',...
        'LastModified',...
        'LastModifiedBy',...
        'Variant'}
    end
    methods
        function thisObj=ResolvedDDGSource(ddConn,entryNameOrID)
            thisObj.UserData.isUpToDate=false;
            thisObj.m_ddConn=ddConn;

            if ischar(entryNameOrID)

                thisObj.m_entryID=thisObj.m_ddConn.getEntryID(entryNameOrID);



                thisObj.m_entryInfo.Name=entryNameOrID;
            else
                thisObj.m_entryID=entryNameOrID;
                thisObj.m_entryInfo.Name='';
            end
            assert(isnumeric(thisObj.m_entryID));
            thisObj.m_scope=thisObj.m_ddConn.getEntryParentName(thisObj.m_entryID);
            thisObj.m_upToDate=false;
            thisObj.m_modifiedInDialog=false;
            thisObj.m_resolvedView=true;
            thisObj.m_ddModificationListener=event.listener(thisObj.m_ddConn,...
            'DataDictionaryModified',@thisObj.notifyOfDDModification);


        end


        function notifyOfDDModification(thisObj,~,evtData)


            thisObj.invalidate();


            dlgs=DAStudio.ToolRoot.getOpenDialogs(thisObj);
            for i=1:length(dlgs)
                dlg=dlgs(i);
                dlg.refresh;
            end
        end
        function delete(thisObj)

        end
        function displayLabel=getDisplayLabel(thisObj)
            displayLabel=thisObj.m_entryInfo.Name;
        end
        function entryValue=getForwardedObject(thisObj)
            entryValue=[];
            thisObj.validate;
            if thisObj.m_upToDate
                entryValue=thisObj.m_entryInfo.Value;
            end
        end
        function isValid=isValidProperty(thisObj,propName)
            isValid=false;
            thisObj.validate;
            if thisObj.m_upToDate
                if any(strcmp(propName,Simulink.dd.EntryDDGSource.m_metaDataProperties))

                    isValid=true;
                else
                    if thisObj.m_entryValueIsMxArray
                        isValid=strcmp(propName,'Value');
                    else
                        try
                            isValid=thisObj.m_entryInfo.Value.isValidProperty(propName);
                        catch
                            isValid=strcmp(propName,'Value');
                        end
                    end
                end
            end
        end
        function isReadonly=isReadonlyProperty(thisObj,propName)
            isReadonly=true;
        end
        function propDataType=getPropDataType(thisObj,propName)
            propDataType='';
            thisObj.validate;
            if thisObj.m_upToDate
                if any(strcmp(propName,Simulink.dd.EntryDDGSource.m_metaDataProperties))

                    propDataType='string';
                else
                    if thisObj.m_entryValueIsMxArray
                        propDataType='string';
                    else
                        try
                            propDataType=getPropDataType(thisObj.m_entryInfo.Value,propName);
                        catch
                            propDataType='mxArray';
                        end
                    end
                end
            end
        end
        function allowedValues=getPropAllowedValues(thisObj,propName)
            allowedValues=[];
            if thisObj.m_upToDate&&~thisObj.m_entryValueIsMxArray
                allowedValues=getPropAllowedValues(thisObj.m_entryInfo.Value,propName);
            end
        end
        function setPropValue(thisObj,propName,propValue)
        end
        function propValue=getPropValue(thisObj,propName)

            propValue=[];
            thisObj.validate;
            if thisObj.m_upToDate
                switch propName
                case 'Name'
                    if thisObj.m_entryInfo.Value.isValidProperty(propName)
                        propValue=thisObj.m_entryInfo.Value.getPropValue(propName);
                    else
                        propValue=thisObj.m_entryInfo.Name;
                    end
                case 'DataSource'
                    propValue=thisObj.m_entryInfo.DataSource;
                case 'Variant'
                    propValue=thisObj.m_entryInfo.Variant;
                case{'Status','LastModified','LastModifiedBy'}

                    assert(false);
                otherwise
                    if thisObj.m_entryValueIsMxArray
                        switch(propName)
                        case 'DataType'
                            propValue=class(thisObj.m_entryInfo.Value);
                        case 'Value'
                            propValue=DAStudio.MxStringConversion.convertToString(...
                            thisObj.m_entryInfo.Value);
                        otherwise
                            assert(false);
                        end
                    else
                        try
                            propValue=thisObj.m_entryInfo.Value.getPropValue(propName);
                        catch
                            switch(propName)
                            case 'DataType'
                                propValue=class(thisObj.m_entryInfo.Value);
                            case 'Value'
                                propValue=DAStudio.MxStringConversion.convertToString(...
                                thisObj.m_entryInfo.Value);
                            otherwise
                                assert(false);
                            end
                        end
                        if islogical(propValue)
                            if propValue
                                propValue='on';
                            else
                                propValue='off';
                            end
                        end
                    end
                end
            end
        end


        function dlgstruct=getDialogSchema(thisObj,~)
            thisObj.validate;
            if thisObj.m_upToDate
                [dlgstruct,thisObj.m_clientCallbacks,thisObj.m_entryInfo.Value]=...
                slddEntryDDG(thisObj,thisObj.m_entryInfo.Name,...
                thisObj.m_entryInfo.Value,thisObj.m_entryValueIsMxArray,...
                thisObj.m_resolvedEntryInfo.Value);
            else
                messageText.Name='';
                name=thisObj.m_entryInfo.Name;
                if isempty(name)
                    try
                        thisObj.m_entryInfo=thisObj.m_ddConn.getEntryInfo(...
                        thisObj.m_entryID);
                        if isempty(thisObj.m_entryInfo.Name)
                            name=num2str(thisObj.m_entryID);
                        else
                            name=thisObj.m_entryInfo.Name;
                        end
                    catch E
                        messageText.Name=E.message;
                    end
                end
                if isempty(messageText.Name)
                    messageText.Name=DAStudio.message(...
                    'Simulink:dialog:DataDictEntryNotFound',name);
                end
                messageText.Type='text';
                messageText.WordWrap=true;
                messageText.Alignment=6;

                dlgstruct.DialogTitle=thisObj.m_entryInfo.Name;
                dlgstruct.Items={messageText};
                dlgstruct.HelpMethod='helpview';
                dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};
            end
        end

        function close(thisObj,dialog,source)
            delete(thisObj);
        end


    end


    methods(Access=private)
        function validate(thisObj)
            if~thisObj.m_upToDate

                try
                    thisObj.m_entryInfo=thisObj.m_ddConn.getEntryBoundInfo(...
                    thisObj.m_entryID);
                catch

                    thisObj.m_entryInfo=thisObj.m_ddConn.getEntryInfo(...
                    thisObj.m_entryID);
                end

                try
                    entryValue=thisObj.m_entryInfo.Value;

                    if Simulink.data.isSupportedEnumObject(entryValue)||...
                        isa(entryValue,'embedded.fi')||...
                        isa(entryValue,'half')
                        objectLevel=0;
                    else
                        objectLevel=Simulink.data.getScalarObjectLevel(entryValue);
                    end



                    if(objectLevel>0)&&...
                        (~Simulink.data.isHandleObject(entryValue))&&...
                        (~Simulink.dd.EntryDDGSource.hasMethod(entryValue,'getDialogSchema'))&&...
                        (~isa(entryValue,'Simulink.Bus'))&&...
                        (~isa(entryValue,'Simulink.ConnectionBus'))&&...
                        (~isa(entryValue,'Simulink.ServiceBus'))&&...
                        (~isa(entryValue,'Simulink.NumericType'))&&...
                        (~isa(entryValue,'Simulink.AliasType'))



                        entryValue=Simulink.dd.DAObjectWrapper(entryValue);
                    end
                    thisObj.m_entryInfo.Value=entryValue;
                    thisObj.m_entryValueIsMxArray=objectLevel==0;


                    thisObj.m_upToDate=true;
                catch me
                    thisObj.m_entryValueIsMxArray=false;
                end

                thisObj.m_modifiedInDialog=false;
            end
        end
        function invalidate(thisObj)
            if thisObj.m_upToDate
                thisObj.m_entryInfo.Value=[];
                thisObj.m_upToDate=false;
                thisObj.UserData.isUpToDate=false;
            end
        end

    end





end
