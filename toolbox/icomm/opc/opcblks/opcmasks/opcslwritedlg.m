function varargout=opcslwritedlg(varargin)








    gui_Singleton=0;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@opcslwritedlg_OpeningFcn,...
    'gui_OutputFcn',@opcslwritedlg_OutputFcn,...
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




    function opcslwritedlg_OpeningFcn(hObject,eventdata,handles,varargin)%#ok
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
        set(handles.btnHelp,'String',sprintf('Help'))

        if length(varargin)>=1&&~iscell(varargin{1})
            error('opcblks:configdlg:syntax','Incorrect syntax.');
        end

        if ischar(varargin{1}{1})
            hBlock=get_param(varargin{1}{1},'Object');
        else
            hBlock=get(varargin{1}{1},'Object');
        end

        if~strcmp(hBlock.MaskType,'OPC Write')
            error('opcblks:write:incorrectBlockType',...
            'Block passed to OPCSLWRITEDLG is not an OPC Write block.');
        end

        existDlg=opcslwriteitf(hBlock,'GetOpenBlockDlg');
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
            return;
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

            opcslwriteitf(hBlock,'RefreshClientList',handles);
        end
        enStr='on';

        itemIDs=strtrim(strread(hBlock.itemIDs,'%s','delimiter',','));
        if isempty(itemIDs)

            if strcmp(get(handles.popClient,'Enable'),'off')
                dispStr='<Configure a client to add items>';
            else
                dispStr='<No items defined>';
            end
            set(handles.lstItemIDs,'Value',[],'String',dispStr,'Enable','off');
        else
            set(handles.lstItemIDs,'Value',1,'String',itemIDs,'Enable',enStr);
        end

        itembuttonsenable(handles,enStr);

        if~isempty(hBlock.serverHost)
            set(handles.btnAdd,'Enable','on');
        end

        writeModes=get(handles.popWriteMode,'String');
        rmInd=find(strcmpi(hBlock.writeMode,writeModes));
        if isempty(rmInd)

            rmInd=1;
        end
        set(handles.popWriteMode,'Value',rmInd,'Enable',enStr);

        set(handles.edtSampleTime,'String',hBlock.updateRate,'Enable',enStr);


        switch get_param(strtok(hBlock.Path,'/'),'SimulationStatus')
        case{'initializing','running','paused'}

            opcslwritecb(hBlock,'StartFcn');
        end

        if isblocklibrary(hBlock)&&strcmp(get_param(strtok(hBlock.Path,'/'),'Lock'),'on')



            set([handles.btnImport,...
            handles.popClient,...
            handles.lstItemIDs,...
            handles.btnMoveUp,handles.btnMoveDn,...
            handles.btnAdd,handles.btnDelete,...
            handles.popWriteMode,...
            handles.edtSampleTime,...
            handles.btnApply],'Enable','off');
        end


        checkenable(handles);



        function varargout=opcslwritedlg_OutputFcn(hObject,eventdata,handles)%#ok

            if isempty(handles.output)
                delete(handles.dlgOPCWrite);
            end
            varargout{1}=handles.output;




            function popClient_Callback(hObject,eventdata,handles)%#ok


                set(handles.btnApply,'Enable','on');



                function popClient_CreateFcn(hObject,eventdata,handles)%#ok
                    if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                        set(hObject,'BackgroundColor','white');
                    end



                    function lstItemIDs_Callback(hObject,eventdata,handles)%#ok

                        itembuttonsenable(handles);



                        function lstItemIDs_CreateFcn(hObject,eventdata,handles)%#ok
                            if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                set(hObject,'BackgroundColor','white');
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
                                                    existingItems(end+1)=itemsToAdd(k);
                                                    selInd(end+1)=length(existingItems);
                                                end
                                                applyEnable=true;
                                            else
                                                selInd(end+1)=thisInd;
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



                                    function popWriteMode_Callback(hObject,eventdata,handles)%#ok
                                        set(handles.btnApply,'Enable','on');



                                        function popWriteMode_CreateFcn(hObject,eventdata,handles)%#ok
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
                                                if isnan(newVal)||(newVal<0&&newVal~=-1)

                                                    uiwait(errordlg('Sample time must be -1 or 0 or a positive value.',...
                                                    'OPC Write: Error','modal'));
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


                                                            warnState=warning('backtrace','off');
                                                            warning('opc:simulink:writeItemsEmpty',...
                                                            'OPC Write block has no items. You cannot start this simulation without defining items.');
                                                            warning(warnState);
                                                            itemStr='';
                                                        else
                                                            itemStr=sprintf('%s, ',itemLst{:});
                                                            itemStr(end-1:end)=[];
                                                        end
                                                        hBlock.itemIDs=itemStr;

                                                        rmStr=get(handles.popWriteMode,'String');
                                                        hBlock.writeMode=rmStr{get(handles.popWriteMode,'Value')};

                                                        hBlock.updateRate=get(handles.edtSampleTime,'String');

                                                        set(hObject,'Enable','off');



                                                        function btnHelp_Callback(hObject,eventdata,handles)%#ok
                                                            helpview("icomm","block_opc_write");



                                                            function btnCancel_Callback(hObject,eventdata,handles)%#ok

                                                                close(handles.dlgOPCWrite);



                                                                function btnOK_Callback(hObject,eventdata,handles)

                                                                    btnApply_Callback(hObject,eventdata,handles);
                                                                    close(handles.dlgOPCWrite);



                                                                    function btnMoveDn_Callback(hObject,eventdata,handles)%#ok

                                                                        allItems=get(handles.lstItemIDs,'String');
                                                                        thisInd=sort(get(handles.lstItemIDs,'Value'),2,'descend');
                                                                        for k=1:length(thisInd)
                                                                            allItems(thisInd(k):thisInd(k)+1)=allItems([thisInd(k)+1,thisInd(k)]);
                                                                        end
                                                                        set(handles.lstItemIDs,'String',allItems,'Value',thisInd+1);

                                                                        set(handles.btnApply,'Enable','on');
                                                                        itembuttonsenable(handles);



                                                                        function btnMoveUp_Callback(hObject,eventdata,handles)%#ok

                                                                            allItems=get(handles.lstItemIDs,'String');
                                                                            thisInd=sort(get(handles.lstItemIDs,'Value'));
                                                                            for k=1:length(thisInd)
                                                                                allItems(thisInd(k)-1:thisInd(k))=allItems([thisInd(k),thisInd(k)-1]);
                                                                            end
                                                                            set(handles.lstItemIDs,'String',allItems,'Value',thisInd-1);

                                                                            set(handles.btnApply,'Enable','on');
                                                                            itembuttonsenable(handles);




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



                                                                                function btnClientMgr_Callback(hObject,eventdata,handles)%#ok

                                                                                    myBlock=handles.blockHandle;
                                                                                    if~isempty(myBlock)
                                                                                        configBlk=opcslconfigitf(myBlock,'FindUsed');
                                                                                        opcslclntmgr(configBlk);
                                                                                    end



                                                                                    function btnImport_Callback(hObject,eventdata,handles)%#ok

                                                                                        wsVars=evalin('base','whos;');
                                                                                        grpObj=wsVars(strcmp({wsVars.class},'dagroup'));

                                                                                        if isempty(grpObj)
                                                                                            uiwait(warndlg('No group objects exist in the workspace.',...
                                                                                            'OPC Write: Import Failed','modal'));
                                                                                        else


                                                                                            [selInd,ok]=listdlg('PromptString','Select dagroup variable:',...
                                                                                            'Name','OPC Write: Select Group Object',...
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
                                                                                                    itmStr='';
                                                                                                else
                                                                                                    itemIDs=grpObj.Item.ItemID;
                                                                                                    if ischar(itemIDs)
                                                                                                        itemIDs={itemIDs};
                                                                                                    end

                                                                                                    itmStr=sprintf('%s, ',itemIDs{:});
                                                                                                    itmStr(end-1:end)=[];
                                                                                                end
                                                                                                hBlock.itemIDs=itmStr;

                                                                                                hBlock.updateRate=num2str(grpObj.UpdateRate);
                                                                                                set(handles.edtSampleTime,'String',hBlock.updateRate);

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



