function varargout=opcslreaddlg(varargin)






    gui_Singleton=1;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@opcslreaddlg_OpeningFcn,...
    'gui_OutputFcn',@opcslreaddlg_OutputFcn,...
    'gui_LayoutFcn',[],...
    'gui_Callback',[]);
    if nargin&&ischar(varargin{1})
        gui_State.gui_Callback=str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}]=gui_mainfcn(gui_State,varargin{:});
    else
        gui_mainfcn(gui_State,varargin{:});
    end




    function opcslreaddlg_OpeningFcn(hObject,eventdata,handles,varargin)%#ok

        if~usejava('jvm')
            uiwait(errordlg(...
            {'This dialog requires Java to open. You can run Simulink';...
            'models containing OPC blocks without Java, but you';...
            'cannot configure OPC blocks without Java. To enable';...
            'Java in MATLAB, run MATLAB without the -nojvm flag.'},...
            'OPC: Dialog requires Java',...
            'modal'));
            handles.output=[];
            guidata(hObject,handles);
            return
        end


        handles.output=hObject;

        guidata(hObject,handles);
        fontName=get(0,'DefaultUIControlFontName');
        set(findall(hObject,'Type','uicontrol'),'FontName',fontName);

        if length(varargin)>=1&&~iscell(varargin{1})
            error('opcblks:configdlg:syntax','Incorrect syntax.');
        end

        if ischar(varargin{1}{1})
            hBlock=get_param(varargin{1}{1},'Object');
        else
            hBlock=get(varargin{1}{1},'Object');
        end

        if~strcmp(hBlock.MaskType,'OPC Read')
            error('opcblks:read:incorrectBlockType',...
            'Block passed to OPCSLREADDLG is not an OPC Read block.');
        end

        existDlg=opcslreaditf(hBlock,'GetOpenBlockDlg');
        if~isempty(existDlg)

            handles.output=[];
            guidata(hObject,handles);
            figure(existDlg);
            return;
        end

        handles.blockHandle=hBlock;
        guidata(hObject,handles);



        configBlk=opcslconfigitf(hBlock,'FindUsed',true);
        if isempty(configBlk)

            handles.output=[];
            guidata(hObject,handles);

            return
        end

        if~isempty(hBlock.serverHost)
            clntObj=opcslclntmgritf(hBlock,'GetClient');
            if isempty(clntObj)
                opcslclntmgritf(configBlk,'AddClient',hBlock.serverHost,hBlock.serverID);
            end
        end

        clntList=opcslclntmgritf(hBlock,'GetClientList');
        if isempty(clntList)



            set(handles.popClient,...
            'Value',1,...
            'Enable','off');
        else

            opcslreaditf(hBlock,'RefreshClientList',handles);
        end

        itemIDs=strtrim(strread(hBlock.itemIDs,'%s','delimiter',','));
        if isempty(itemIDs)

            if strcmp(get(handles.popClient,'Enable'),'off')
                dispStr='<Configure a client to add items>';
            else
                dispStr='<No items defined>';
            end
            set(handles.lstItemIDs,'Value',[],'String',dispStr,'Enable','off');
        else
            set(handles.lstItemIDs,'Value',1,'String',itemIDs,'Enable','on');
        end

        itembuttonsenable(handles,'on');

        if~isempty(hBlock.serverHost)
            set(handles.btnAdd,'Enable','on');
        end

        readModes=get(handles.popReadMode,'String');
        rmInd=find(strcmpi(hBlock.readMode,readModes));
        if isempty(rmInd)

            rmInd=1;
        end
        set(handles.popReadMode,'Value',rmInd,'Enable','on');

        set(handles.edtSampleTime,'String',hBlock.updateRate,'Enable','on');


        dTypes=get(handles.popDataType,'String');
        dtInd=find(strcmpi(hBlock.dataType,dTypes));
        if isempty(dtInd)
            dtInd=1;
        end
        set(handles.popDataType,'Value',dtInd,'Enable','on');

        set(handles.chkShowQuality,'Value',strcmp(hBlock.showQual,'on'),...
        'Enable','on');

        set(handles.chkShowTimestamp,'Value',strcmp(hBlock.showTS,'on'),...
        'Enable','on');

        if get(handles.chkShowTimestamp,'Value')==1
            enStr='on';
        else
            enStr='off';
        end
        if strcmp(hBlock.tsMode,'Seconds since start')
            secVal=1;
        else
            secVal=0;
        end
        set([handles.rdoSeconds,handles.rdoDatenum],'Enable',enStr);
        set(handles.rdoSeconds,'Value',secVal);
        set(handles.rdoDatenum,'Value',1-secVal);


        switch get_param(strtok(hBlock.Path,'/'),'SimulationStatus')
        case{'initializing','running','paused'}

            opcslreadcb(hBlock,'StartFcn');
        end


        if isblocklibrary(hBlock)&&strcmp(get_param(strtok(hBlock.Path,'/'),'Lock'),'on')



            set([handles.btnImport,...
            handles.popClient,...
            handles.lstItemIDs,...
            handles.btnMoveUp,handles.btnMoveDn,...
            handles.btnAdd,handles.btnDelete,...
            handles.popReadMode,...
            handles.edtSampleTime,...
            handles.popDataType,...
            handles.chkShowQuality,...
            handles.chkShowTimestamp,...
            handles.rdoSeconds,handles.rdoDatenum,...
            handles.btnApply],'Enable','off');
        end


        checkenable(handles);



        function varargout=opcslreaddlg_OutputFcn(hObject,eventdata,handles)%#ok

            if isempty(handles.output)
                delete(handles.dlgOPCRead);
            end
            varargout{1}=handles.output;



            function btnImport_Callback(hObject,eventdata,handles)%#ok

                wsVars=evalin('base','whos;');
                grpObj=wsVars(strcmp({wsVars.class},'dagroup'));

                if isempty(grpObj)
                    uiwait(warndlg('No group objects exist in the workspace.',...
                    'OPCRead: Import Failed','modal'));
                else


                    [selInd,ok]=listdlg('PromptString','Select dagroup variable:',...
                    'Name','OPCRead: Select Group Object',...
                    'SelectionMode','single',...
                    'ListString',{grpObj.name});
                    if ok

                        selName=grpObj(selInd).name;
                        grpObj=evalin('base',selName);
                        hBlock=handles.blockHandle;
                        hBlock.serverHost=grpObj.Parent.Host;
                        hBlock.serverID=grpObj.Parent.ServerID;

                        clntInd=opcslclntmgritf(hBlock,'AddClient',hBlock.serverHost,hBlock.serverID);
                        opcslwriteitf(hBlock,'RefreshClientList',handles);
                        set(handles.popClient,'Value',clntInd);

                        if isempty(grpObj.Item)
                            itemIDs={};
                            dTypes={'double'};
                            itmStr='';
                        else
                            itemIDs=grpObj.Item.ItemID;
                            if~iscell(itemIDs)
                                itemIDs={itemIDs};
                            end
                            dTypes=grpObj.Item.DataType;
                            if~iscell(dTypes)
                                dTypes={dTypes};
                            end

                            itmStr=sprintf('%s, ',itemIDs{:});
                            itmStr(end-1:end)=[];
                        end
                        hBlock.itemIDs=itmStr;

                        hBlock.updateRate=num2str(grpObj.UpdateRate);
                        set(handles.edtSampleTime,'String',hBlock.updateRate);

                        alldType=unique(dTypes);
                        if length(alldType)==1

                            dtInd=find(strcmp(alldType{1},get(handles.popDataType,'String')));
                            if~isempty(dtInd)
                                hBlock.dataType=alldType{1};
                                set(handles.popDataType,'Value',dtInd);
                            end
                        end

                        if isempty(itemIDs)
                            set(handles.lstItemIDs,'Value',[],...
                            'String','<No items defined>','Enable','off');
                        else
                            set(handles.lstItemIDs,'Value',1,...
                            'String',itemIDs,'Enable','on');
                        end
                        checkenable(handles.lstItemIDs);

                        itembuttonsenable(handles,'on');
                    end
                end



                function popClient_Callback(hObject,eventdata,handles)%#ok


                    set(handles.btnApply,'Enable','on');



                    function popClient_CreateFcn(hObject,eventdata,handles)%#ok
                        if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                            set(hObject,'BackgroundColor','white');
                        end



                        function btnClientMgr_Callback(hObject,eventdata,handles)%#ok

                            hBlock=handles.blockHandle;
                            if~isempty(hBlock)
                                configBlk=opcslconfigitf(hBlock,'FindUsed');
                                opcslclntmgr(configBlk);
                            end



                            function lstItemIDs_Callback(hObject,eventdata,handles)%#ok

                                itembuttonsenable(handles);



                                function lstItemIDs_CreateFcn(hObject,eventdata,handles)%#ok
                                    if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                        set(hObject,'BackgroundColor','white');
                                    end



                                    function btnMoveUp_Callback(hObject,eventdata,handles)%#ok

                                        allItems=get(handles.lstItemIDs,'String');
                                        thisInd=sort(get(handles.lstItemIDs,'Value'));
                                        for k=1:length(thisInd)
                                            allItems(thisInd(k)-1:thisInd(k))=allItems([thisInd(k),thisInd(k)-1]);
                                        end
                                        set(handles.lstItemIDs,'String',allItems,'Value',thisInd-1);

                                        set(handles.btnApply,'Enable','on');
                                        itembuttonsenable(handles);



                                        function btnMoveDn_Callback(hObject,eventdata,handles)%#ok

                                            allItems=get(handles.lstItemIDs,'String');
                                            thisInd=sort(get(handles.lstItemIDs,'Value'),2,'descend');
                                            for k=1:length(thisInd)
                                                allItems(thisInd(k):thisInd(k)+1)=allItems([thisInd(k)+1,thisInd(k)]);
                                            end
                                            set(handles.lstItemIDs,'String',allItems,'Value',thisInd+1);

                                            set(handles.btnApply,'Enable','on');
                                            itembuttonsenable(handles);



                                            function btnAdd_Callback(hObject,eventdata,handles)%#ok


                                                hBlock=handles.blockHandle;

                                                configBlk=opcslconfigitf(hBlock,'FindUsed');
                                                clntList=configBlk.UserData;
                                                clntObj=clntList(get(handles.popClient,'Value'));

                                                if strcmp(get(handles.lstItemIDs,'Enable'),'off')
                                                    existingItems={};
                                                else
                                                    existingItems=get(handles.lstItemIDs,'String');
                                                end

                                                itemsToAdd=browsenamespace(clntObj);
                                                if~isempty(itemsToAdd)

                                                    applyEnable=false;
                                                    selInd=[];
                                                    for k=1:length(itemsToAdd)
                                                        thisInd=find(strcmp(itemsToAdd{k},existingItems));
                                                        if isempty(thisInd)

                                                            if isempty(existingItems)
                                                                existingItems=itemsToAdd(k);
                                                                selInd=1;
                                                            else
                                                                existingItems(end+1)=itemsToAdd(k);%#ok<AGROW>
                                                                selInd(end+1)=length(existingItems);%#ok<AGROW>
                                                            end
                                                            applyEnable=true;
                                                        else
                                                            selInd(end+1)=thisInd;%#ok<AGROW>
                                                        end
                                                    end

                                                    set(handles.lstItemIDs,'String',existingItems,'Value',selInd,...
                                                    'Enable','on');
                                                    if applyEnable
                                                        set(handles.btnApply,'Enable','on');
                                                    end
                                                    itembuttonsenable(handles);
                                                    checkenable(handles.lstItemIDs);
                                                end


                                                dlgClntMgr=opcslclntmgritf(configBlk,'GetOpenClntMgr');
                                                if~isempty(dlgClntMgr)
                                                    opcslclntmgritf(configBlk,'RefreshClientList',guidata(dlgClntMgr));
                                                end



                                                function btnDelete_Callback(hObject,eventdata,handles)%#ok

                                                    allItemIDs=get(handles.lstItemIDs,'String');
                                                    thisInd=get(handles.lstItemIDs,'Value');
                                                    allItemIDs(thisInd)=[];

                                                    lbTop=get(handles.lstItemIDs,'ListBoxTop');
                                                    if(lbTop>length(allItemIDs))

                                                        lbTop=1;
                                                    end
                                                    if isempty(allItemIDs)
                                                        set(handles.lstItemIDs,'String','<No items defined>','Value',[],'Enable','off',...
                                                        'ListBoxTop',lbTop);
                                                        checkenable(handles.lstItemIDs);
                                                    else
                                                        set(handles.lstItemIDs,'String',allItemIDs,'Value',[],'ListBoxTop',lbTop);
                                                    end

                                                    set(handles.btnApply,'Enable','on');

                                                    itembuttonsenable(handles);



                                                    function popReadMode_Callback(hObject,eventdata,handles)%#ok

                                                        curSampleTime=str2double(get(handles.edtSampleTime,'String'));
                                                        newInd=get(hObject,'Value');
                                                        applyEnable=true;
                                                        if((newInd==1)&&(curSampleTime<=0))
                                                            uiwait(errordlg('Cannot set Read Mode to asynchronous when sample time is 0.',...
                                                            'OPC Read: Error','modal'));
                                                            applyEnable=false;
                                                            rmStr=get(hObject,'String');
                                                            hBlock=handles.blockHandle;
                                                            newInd=find(strcmp(hBlock.readMode,rmStr));

                                                            if isempty(newInd)||(newInd==1)
                                                                newInd=2;
                                                            end
                                                        end
                                                        set(hObject,'Value',newInd);
                                                        if applyEnable
                                                            set(handles.btnApply,'Enable','on');
                                                        end



                                                        function popReadMode_CreateFcn(hObject,eventdata,handles)%#ok
                                                            if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                                                set(hObject,'BackgroundColor','white');
                                                            end



                                                            function edtSampleTime_Callback(hObject,eventdata,handles)%#ok

                                                                hBlock=handles.blockHandle;
                                                                origVal=hBlock.updateRate;
                                                                applyEnable=false;
                                                                try
                                                                    newVal=str2double(get(hObject,'String'));
                                                                    applyEnable=(newVal~=origVal);
                                                                catch ME %#ok<NASGU>
                                                                    newVal=NaN;
                                                                end

                                                                if isnan(newVal)||(newVal<0)

                                                                    uiwait(errordlg('Sample time must be 0 (synchronous reads only) or a positive value.',...
                                                                    'OPC Read: Error','modal'));
                                                                    applyEnable=false;
                                                                    newVal=origVal;
                                                                end

                                                                if((get(handles.popReadMode,'Value')==1)&&(newVal<=0))
                                                                    uiwait(errordlg('Sample time must be a positive value for asynchronous read mode.',...
                                                                    'OPC Read: Error','modal'));
                                                                    applyEnable=false;
                                                                    newVal=origVal;
                                                                end
                                                                set(hObject,'String',num2str(newVal));

                                                                if applyEnable
                                                                    set(handles.btnApply,'Enable','on');
                                                                end



                                                                function edtSampleTime_CreateFcn(hObject,eventdata,handles)%#ok
                                                                    if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                                                        set(hObject,'BackgroundColor','white');
                                                                    end



                                                                    function popDataType_Callback(hObject,eventdata,handles)%#ok

                                                                        hBlock=handles.blockHandle;
                                                                        dtStr=get(hObject,'String');
                                                                        dtInd=get(hObject,'Value');
                                                                        if~strcmp(dtStr{dtInd},hBlock.dataType)
                                                                            set(handles.btnApply,'Enable','on');
                                                                        end



                                                                        function popDataType_CreateFcn(hObject,eventdata,handles)%#ok
                                                                            if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                                                                set(hObject,'BackgroundColor','white');
                                                                            end



                                                                            function chkShowQuality_Callback(hObject,eventdata,handles)%#ok

                                                                                set(handles.btnApply,'Enable','on');



                                                                                function chkShowTimestamp_Callback(hObject,eventdata,handles)%#ok

                                                                                    if(get(hObject,'Value')==1)
                                                                                        enStr='on';
                                                                                    else
                                                                                        enStr='off';
                                                                                    end
                                                                                    set([handles.rdoSeconds,handles.rdoDatenum],'Enable',enStr);

                                                                                    set(handles.btnApply,'Enable','on');



                                                                                    function rdoSeconds_Callback(hObject,eventdata,handles)%#ok
                                                                                        otherVal=1-get(hObject,'Value');
                                                                                        set(handles.rdoDatenum,'Value',otherVal);
                                                                                        set(handles.btnApply,'Enable','on');



                                                                                        function rdoDatenum_Callback(hObject,eventdata,handles)%#ok
                                                                                            otherVal=1-get(hObject,'Value');
                                                                                            set(handles.rdoSeconds,'Value',otherVal);
                                                                                            set(handles.btnApply,'Enable','on');



                                                                                            function btnOK_Callback(hObject,eventdata,handles)

                                                                                                btnApply_Callback(hObject,eventdata,handles);
                                                                                                close(handles.dlgOPCRead);



                                                                                                function btnCancel_Callback(hObject,eventdata,handles)%#ok

                                                                                                    close(handles.dlgOPCRead);



                                                                                                    function btnHelp_Callback(hObject,eventdata,handles)%#ok
                                                                                                        helpview("icomm","block_opc_read");



                                                                                                        function btnApply_Callback(hObject,eventdata,handles)%#ok

                                                                                                            hBlock=handles.blockHandle;

                                                                                                            if isblocklibrary(hBlock)&&strcmp(get_param(strtok(hBlock.Path,'/'),'Lock'),'on')
                                                                                                                return;
                                                                                                            end

                                                                                                            allServers=get(handles.popClient,'String');
                                                                                                            if iscell(allServers)
                                                                                                                thisServer=allServers{get(handles.popClient,'Value')};
                                                                                                            else
                                                                                                                thisServer=allServers;
                                                                                                            end


                                                                                                            hstList=regexp(thisServer,'(?<host>[^/]*)/(?<serverid>.*)','names');
                                                                                                            if~isempty(hstList)

                                                                                                                hBlock.serverHost=hstList.host;
                                                                                                                hBlock.serverID=hstList.serverid;
                                                                                                            end

                                                                                                            itemLst=get(handles.lstItemIDs,'String');
                                                                                                            if strcmp(get(handles.lstItemIDs,'Enable'),'off')
                                                                                                                if~isblocklibrary(hBlock)


                                                                                                                    warnState=warning('backtrace','off');
                                                                                                                    warning('opc:simulink:readItemsEmpty',...
                                                                                                                    'OPC Read block has no items. You cannot start this simulation without defining items.');
                                                                                                                    warning(warnState);
                                                                                                                end
                                                                                                                itemStr='';
                                                                                                            else
                                                                                                                itemStr=sprintf('%s, ',itemLst{:});
                                                                                                                itemStr(end-1:end)=[];
                                                                                                            end
                                                                                                            hBlock.itemIDs=itemStr;

                                                                                                            rmStr=get(handles.popReadMode,'String');
                                                                                                            hBlock.readMode=rmStr{get(handles.popReadMode,'Value')};

                                                                                                            dtStr=get(handles.popDataType,'String');
                                                                                                            hBlock.dataType=dtStr{get(handles.popDataType,'Value')};

                                                                                                            hBlock.updateRate=get(handles.edtSampleTime,'String');

                                                                                                            if get(handles.chkShowQuality,'Value')
                                                                                                                hBlock.showQual='on';
                                                                                                            else
                                                                                                                hBlock.showQual='off';
                                                                                                            end

                                                                                                            if get(handles.chkShowTimestamp,'Value')
                                                                                                                hBlock.showTS='on';
                                                                                                            else
                                                                                                                hBlock.showTS='off';
                                                                                                            end

                                                                                                            if(get(handles.rdoSeconds,'Value')==1)
                                                                                                                hBlock.tsMode='Seconds since start';
                                                                                                            else
                                                                                                                hBlock.tsMode='Serial date number';
                                                                                                            end

                                                                                                            set(hObject,'Enable','off');



                                                                                                            function itembuttonsenable(handles,enStr)

                                                                                                                if nargin<2
                                                                                                                    enStr='on';
                                                                                                                end
                                                                                                                lst=get(handles.lstItemIDs,'String');


                                                                                                                if ischar(lst)
                                                                                                                    if any(strcmp(lst,{'<No items defined>','<Configure a client to add items>'}))
                                                                                                                        lst={};
                                                                                                                    else
                                                                                                                        lst={lst};
                                                                                                                    end
                                                                                                                end
                                                                                                                ind=get(handles.lstItemIDs,'Value');

                                                                                                                upStr='off';
                                                                                                                dnStr='off';
                                                                                                                delStr='off';
                                                                                                                if~isempty(lst)
                                                                                                                    delStr=enStr;

                                                                                                                    if ind>1
                                                                                                                        upStr=enStr;
                                                                                                                    end
                                                                                                                    if ind<length(lst)
                                                                                                                        dnStr=enStr;
                                                                                                                    end
                                                                                                                end
                                                                                                                set(handles.btnMoveUp,'Enable',upStr);
                                                                                                                set(handles.btnMoveDn,'Enable',dnStr);
                                                                                                                set(handles.btnDelete,'Enable',delStr);
                                                                                                                checkenable([handles.btnMoveUp,handles.btnMoveDn,handles.btnDelete]);


