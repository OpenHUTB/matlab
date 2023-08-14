

classdef RTEViewSource<simulinkcoder.internal.app.DataDictionaryViewSource
    properties
        SubScriptions={};
ClientID
Channel
defaultCache
    end
    properties(Access=private)
m_dd
m_cdefinition
        layoutModel=''
    end
    methods
        function obj=RTEViewSource(ddName,isAttachedToModel,modelHandle)
            obj=obj@simulinkcoder.internal.app.DataDictionaryViewSource(ddName,isAttachedToModel,modelHandle);
            if~coder.internal.CoderDataStaticAPI.isInitialized(ddName)
                coder.internal.CoderDataStaticAPI.initializeDictionary(ddName);
            end
            obj.m_dd=Simulink.dd.open(obj.DataDictionaryFileName);
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            cdict=hlp.openDD(obj.DataDictionaryFileName);
            obj.m_cdefinition=cdict;
            coderdictionary.data.api.startChangeTracking(cdict.owner);
        end
        function onSourceBeingDestroyed(obj,~,~,~)
            onSourceBeingDestroyed@simulinkcoder.internal.app.ViewSourceBase(obj);
            obj.m_dd.close;
            obj.ddConn.close;
            simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(obj.DataDictionaryFileName);
        end
        function receive(obj,msg)
            try
                if~isvalid(obj)
                    return;
                end
                if isfield(msg,'clientID')
                    if(ischar(msg.clientID)&&~strcmp(msg.clientID,obj.ClientID))||...
                        (isnumeric(msg.clientID)&&msg.clientID~=obj.ClientID)
                        return;
                    end
                end
                hlp=coder.internal.CoderDataStaticAPI.getHelper();
                dd=obj.m_cdefinition;
                txn=hlp.beginTxn(dd);
                hlp.commitTxn(txn);
                try
                    obj.handleMessage(msg);
                catch me
                    if~isempty(txn)
                        hlp.rollbackTxn(txn);
                    end
                    rethrow(me);
                end
            catch me
                obj.handleError(me);
            end
        end
        function handleMessage(obj,msg)
            if isfield(msg,'Type')&&strcmp(msg.Type,'command')
                switch(msg.Value)
                case 'SDPUIReady'
                    obj.handleReadyMessage();
                end
            else
                switch msg.messageID
                case{'EditCompleted'}
                    obj.handleEditCompleted(msg);
                case{'ButtonClicked'}
                    obj.handleButtonClicked(msg);
                end
            end
        end
        function handleButtonClicked(obj,msg)
            action=msg.action;
            switch action
            case 'new'
                prop=msg.data.prop;


                tmp=strsplit(prop,'_');
                prop=tmp{2};
                coder.internal.CoderDataStaticAPI.create(obj.m_cdefinition,prop);
                obj.refreshUI;
            case 'delete'
                name=msg.data.value;



                parent=msg.data.parent;
                tmp=strsplit(parent,'_');
                type=tmp{2};
                coder.internal.CoderDataStaticAPI.delete(obj.m_cdefinition,type,{name});
                obj.refreshUI;
            end
        end
        function handleEditCompleted(obj,msg)
            objectID=msg.objectID;
            data=msg.data;
            if~strcmp(objectID,'SDP')
                return;
            end




            cellId=data.cellInfo.id;
            tmp=strsplit(cellId,'_');
            tableName=tmp{1};
            value=data.newValue.value;
            prop=data.newValue.prop;
            try
                rte=obj.m_cdefinition.owner.RTEDefinition;
                if strcmp(tableName,'SDPTable')
                    errMsg=setMainTableValue(rte,prop,value);
                elseif strcmp(tableName,'SDPService')
                    errMsg=setServiceTableValue(rte,prop,value);
                else

                    dataProp=tmp{2};
                    serviceData=rte.(dataProp);
                    for i=1:serviceData.Size
                        timer=serviceData(i);
                        if(timer.UUID==tableName)
                            errMsg=setTimerServiceValue(timer,prop,value);
                        end
                    end
                end
            catch me
                errMsg=me.message;
            end
            if isempty(errMsg)
                msg.messageID='updateSuccessful_SDP';
            else
                msg.messageID='updateFailure_SDP';
                msg.msg=errMsg;
            end
            msg.clientID=obj.ClientID;
            msg.data=data;
            message.publish(obj.Channel,msg);

            function errMsg=setMainTableValue(rte,prop,value)
                errMsg='';
                if ismember(prop,properties(rte))
                    rte.(prop)=value;
                else
                    errMsg=['Software platform does not support to change ',prop,' to ',value,' yet.'];
                end
            end
            function errMsg=setTimerServiceValue(timer,prop,value)
                errMsg='';
                props=properties(timer);
                switch prop
                case props
                    timer.(prop)=value;
                otherwise
                    errMsg=['Timer service  does not support to change ',prop,' to ',value,' yet.'];
                end
            end
            function errMsg=setServiceTableValue(rte,prop,value)
                errMsg='';
                switch prop
                case{'RootOutputExplicitWriteFunctionName',...
                    'RootOutputImplicitWriteFunctionName',...
                    'RootInputExplicitReadFunctionName',...
                    'RootInputImplicitReadFunctionName'}
                    rte.rootIOService.(prop)=value;
                case{'DataImplicitReadFunctionName','DataImplicitWriteFunctionName',...
                    'DataExplicitReadFunctionName','DataExplicitWriteFunctionName'}
                    rte.dataTransferService.(prop)=value;
                otherwise
                    errMsg=['Software platform does not support to change ',prop,' to ',value,' yet.'];
                end
            end
        end
        function refreshUI(obj)
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            dd=obj.m_cdefinition;
            txn=hlp.beginTxn(dd);
            hlp.commitTxn(txn);
            try
                obj.handleReadyMessage;
            catch me
                if~isempty(txn)
                    hlp.rollbackTxn(txn);
                end
                rethrow(me);
            end
        end
        function removeListener(~)

        end
        function addListener(~)

        end

        function handleReadyMessage(obj)
            msg.messageID='responseReady_SDP';
            msg.clientID=obj.ClientID;
            if isempty(obj.m_cdefinition.owner.RTEDefinition)
                rte=coder.internal.CoderDataStaticAPI.create(obj.m_cdefinition,'RuntimeEnvironment');
                rte.init;
            end
            rte=obj.m_cdefinition.owner.RTEDefinition;

            if isempty(obj.layoutModel)
                text=fileread(fullfile(matlabroot,'toolbox','coder',...
                'simulinkcoder_app','ui','+simulinkcoder',...
                '+internal','+app','RTE_layout.json'));
                obj.layoutModel=jsondecode(text);
            end
            layout=obj.layoutModel;
            if isempty(rte.rootIOService)
                rte.rootIOService=coderdictionary.data.RootIOService(mf.zero.getModel(rte));
            end
            if isempty(rte.dataTransferService)
                rte.dataTransferService=coderdictionary.data.DataTransferService(mf.zero.getModel(rte));
            end
            for tt=1:length(layout.children)
                table=layout.children(tt);

                numRow=length(table.children);
                for i=1:length(table.children)
                    row=table.children{i};

                    if strcmp(row.dataProp,'sdp')
                        dataValue=rte;
                    else
                        dataValue=rte.(row.dataProp);
                    end
                    if isfield(row,'children')&&~isempty(row.children)
                        subTable=row.children;
                        numOfChildRow=length(subTable.children)+1;
                        numRow=numRow+dataValue.Size*numOfChildRow;
                    end
                end


                dataCell=cell(1,numRow);

                for i=1:length(table.children)
                    row=table.children{i};

                    if strcmp(row.dataProp,'sdp')
                        dataValue=rte;
                    else
                        dataValue=rte.(row.dataProp);
                    end

                    if~isempty(row.parent)
                        row.parent=[table.tableName,'_',row.parent];
                    end
                    row.id=[table.tableName,'_',row.id];
                    dataCell{i}=loc_createRowWidget(row,dataValue);


                    if isfield(row,'children')&&~isempty(row.children)
                        subData=dataValue;
                        subTable=row.children;
                        subTable.parent=[table.tableName,'_',subTable.parent];
                        numRow=i;


                        for j=1:subData.Size
                            subRowData=subData(j);

                            subHeaderRowId=[subRowData.(subTable.id),'_',row.dataProp];

                            dataCell{numRow+1}=loc_createRowWidget(subTable,...
                            subRowData);
                            dataCell{numRow+1}.Value.id=subHeaderRowId;


                            for jj=1:length(subTable.children)
                                subRow=subTable.children(jj);

                                subRow.id=[subHeaderRowId,'_',subRow.id];
                                subRow.parent=subHeaderRowId;
                                dataCell{numRow+jj+1}=loc_createRowWidget(subRow,subRowData);
                            end
                            numRow=numRow+1+length(subTable.children);
                        end
                    end
                end
                msg.data.(table.tableName)=dataCell;
            end
            msg.dialogTitle=message('SimulinkCoderApp:ui:CoderAppTitle',obj.DataDictionaryFileName).getString;
            message.publish(obj.Channel,msg);
        end

        function sendUpdateFailureMsg(obj,storeId,elementId,property,value,errMsg)
            msg.messageID='updateFailure_defaultMapping';
            msg.clientID=obj.ClientID;
            msg.storeId=storeId;
            msg.elementId=elementId;
            msg.property=property;
            msg.value=value;
            msg.errMsg=errMsg;
            message.publish(obj.Channel,msg);
        end
        function sendUpdateSuccessfulMsg(obj,storeId,newRowInfo)
            msg.messageID='updateSuccessful_defaultMapping';
            msg.clientID=obj.ClientID;
            msg.storeId=storeId;
            msg.rowInfo=newRowInfo;
            message.publish(obj.Channel,msg);
        end

        function handleError(~,e)
            disp(['Error of handling message from dictionary default: ',e.message]);
        end
        function delete(obj)
            obj.unsubscribe;
            if isa(obj.m_dd,'Simulink.data.dictionary')
                obj.m_dd.close;
            end
        end
        function subscribe(obj)
            if~isempty(obj.SubScriptions)
                obj.unsubscribe()
            end
            obj.SubScriptions{end+1}=message.subscribe(obj.Channel,@obj.receive);
        end
        function unsubscribe(obj)
            if(obj.isvalid)
                for i=1:length(obj.SubScriptions)
                    message.unsubscribe(obj.SubScriptions{i});
                end
            end
        end
        function out=CoderDataSourceName(~)
            out='UNKNOWN';
        end
        function onBrowserClose(obj,size)
            onBrowserClose@simulinkcoder.internal.app.DataDictionaryViewSource(obj,size);
            obj.unsubscribe();
        end
    end
    methods(Static=true,Hidden=true)
        function closeCallBack(obj)
            simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(obj.DataDictionaryFileName);
        end
    end
end


function out=loc_createText(name,value,id,parent)
    if(nargin<4)
        parent='';
    end
    out=struct('Name',name,'Value',struct('value',value,...
    'widgetType','text',...
    'prop',id,...
    'id',id,...
    'parent',parent,...
    'group',''));
end
function out=loc_createTextBox(name,prop,value,id,parent,group)
    if(nargin<6)
        group='';
    end
    if(nargin<5)
        parent='';
    end

    if isempty(group)
        group=parent;
    end

    out=struct('Name',name,'Value',struct('value',value,...
    'widgetType','textbox',...
    'prop',prop,...
    'id',id,...
    'parent',parent,...
    'group',group));
end
function out=loc_createOptionList(name,prop,value,allowedValues,id,parent,group)
    if(nargin<7)
        group='';
    end
    if(nargin<6)
        parent='';
    end

    if isempty(group)
        group=parent;
    end

    out=struct('Name',name,...
    'Value',struct('value',value,...
    'widgetType','optionList','prop',prop,'allowedValues','',...
    'id',id,...
    'parent',parent,...
    'group',group));
    out.Value.allowedValues=allowedValues;
end
function rowWidget=loc_createRowWidget(row,rowData)
    id=row.id;
    if~isfield(row,'parent')
        parent='';
    else
        parent=row.parent;
    end
    switch row.widgetType
    case 'text'
        rowWidget=loc_createText(row.label,'',id);
    case 'textbox'
        rowWidget=loc_createTextBox(row.label,row.prop,rowData.(row.prop),id,parent);
    case 'optionList'
        if strcmp(row.prop,'Language')
            value='C';
        else
            value=rowData.(row.prop);
        end
        rowWidget=loc_createOptionList(row.label,row.prop,value,row.allowedValues,id);
    end
    if isfield(row,'action')
        rowWidget.Value.action=row.action;
    end
end


