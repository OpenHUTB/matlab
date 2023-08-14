
function selection=handleAlert(figHandle,condition,msg,title,varargin)

    switch condition

    case 'error'

        selection=[];
        if useAppContainer()
            uialert(figHandle,msg,title)
        else
            errordlg(msg,title);
        end

    case 'errorWithModal'


        selection=[];
        if useAppContainer()
            uialert(figHandle,msg,title);
        else
            errordlg(msg,title,'modal');
        end

    case 'errorWithWaitDlg'


        selection=[];
        if useAppContainer()
            uialert(figHandle,msg,title);
        else
            dlg=vision.internal.uitools.ErrorDlg(varargin{1},msg,title);
            wait(dlg);
        end

    case 'question'

        button1=varargin{1};
        button2=varargin{2};
        button3=varargin{3};

        if numel(varargin)==3
            if useAppContainer()
                selection=uiconfirm(figHandle,msg,title,'Options',{button1,button2},...
                'DefaultOption',button3);
            else
                selection=questdlg(msg,title,button1,button2,button3);
            end
        else
            button4=varargin{4};
            if useAppContainer()
                selection=uiconfirm(figHandle,msg,title,'Options',{button1,button2,button3},...
                'DefaultOption',button4);
            else
                selection=questdlg(msg,title,button1,button2,button3,button4);
            end
        end

    case 'questionWithWaitDlg'


        button1=varargin{2};
        button2=varargin{3};

        if useAppContainer()
            selection=uiconfirm(figHandle,msg,title,'Options',{button1,button2},...
            'DefaultOption',button1);
        else
            selection=vision.internal.uitools.QuestDlg(varargin{1},msg,title);
            wait(selection);
            if selection.IsYes
                selection=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
            else
                selection=vision.getMessage('MATLAB:uistring:popupdialogs:No');
            end
        end

    case 'messageDialog'

        if useAppContainer()
            uiconfirm(figHandle,msg,title,'Icon','none',...
            'Options',{vision.getMessage('MATLAB:uistring:popupdialogs:OK')});
        else
            selection=vision.internal.uitools.MessageDialog(varargin{1},title,msg);
            wait(selection);
        end
        selection=[];

    case 'warndlg'

        if useAppContainer()
            uialert(figHandle,msg,title,'Icon','warning');
        else
            dlg=warndlg(msg,title,'modal');
            uiwait(dlg);
        end
    end

    function tf=useAppContainer()
        tf=vision.internal.labeler.jtfeature('useAppContainer');
    end

end