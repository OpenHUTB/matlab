function varargout=opcslwriteitf(block,action,varargin)








    if ischar(block),
        block=get_param(block,'Object');
    else
        block=get(block,'Object');
    end

    if nargout,
        [varargout{1:nargout}]=feval(action,block,varargin{:});
    else
        feval(action,block,varargin{:});
    end



    function RefreshClientList(block,handles,clntList)

        if nargin<3,

            clntList=opcslclntmgritf(block,'GetClientList');
        end
        if strcmp(get(handles.popClient,'Enable'),'on'),
            cI=get(handles.popClient,'Value');
            pStr=get(handles.popClient,'String');
            clientStr=pStr{cI};
        else


            writeBlk=handles.blockHandle;
            if isempty(writeBlk.serverHost),
                clientStr='';
            else
                clientStr=sprintf('%s/%s',...
                writeBlk.serverHost,writeBlk.serverID);
            end
        end

        modified=false;
        if isempty(clntList),


            dlgStr='<None defined>';
            enStr='off';
            newInd=1;
        else
            enStr='on';
            clntParms=get(clntList,{'host','serverid'});
            dlgStr=cell(length(clntList),1);
            for k=1:length(clntList),
                dlgStr{k}=sprintf('%s/%s',clntParms{k,1:2});
            end

            newInd=find(strcmpi(clientStr,dlgStr));
            if~any(newInd),
                newInd=1;
                modified=true;


                set(handles.lstItemIDs,'String','<No items defined>');
            end
        end

        set(handles.popClient,'String',dlgStr,'Value',newInd,'Enable',enStr);
        set(handles.btnAdd,'Enable',enStr);
        checkenable([handles.popClient,handles.btnAdd]);

        if modified,
            set(handles.btnApply,'Enable','on');
        end



        function myDlg=GetOpenBlockDlg(block)

            myDlg=[];
            allDlg=findall(0,'Tag','dlgOPCWrite');
            for k=1:length(allDlg),
                dlgHandles=guidata(allDlg(k));
                if isfield(dlgHandles,'blockHandle')&&...
                    ~isempty(dlgHandles.blockHandle)&&...
                    dlgHandles.blockHandle==block.Handle,
                    myDlg=allDlg(k);
                    break
                end
            end