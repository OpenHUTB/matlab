function userCanceled=undoRunDialog(tool,instanceName)







    userCanceled=true;
    checkBoxPrefChanged=false;

    dlgTitle=vision.getMessage('vision:labeler:undoRunDlgTitle');
    dlgMessage=vision.getMessage('vision:labeler:undoRunDlgMessage');

    dlgSize=[400,200];
    if~useAppContainer
        dlgPosition=imageslib.internal.apputil.ScreenUtilities.getModalDialogPos(tool.Name,dlgSize);
        hDlg=dialog('Name',dlgTitle,'WindowStyle','modal',...
        'Position',dlgPosition','tag','undoRunDlg','Visible','on');

        movegui(hDlg,'onscreen');
    else
        dlgPosition=imageslib.internal.app.utilities.ScreenUtilities.getModalDialogPos(tool,dlgSize);
        hDlg=uifigure('Name',dlgTitle,'WindowStyle','modal',...
        'Position',dlgPosition','tag','undoRunDlg','Visible','on',...
        'Resize','off');
    end


    buttonSize=[60,20];
    textSize=[340,50];
    checkBoxSize=[340,20];
    buttonHalfSpace=10;
    leftOffset=30;
    bottomOffset=10;
    vertGap=10;


    x=dlgSize(1)/2-buttonSize(1)-buttonHalfSpace;
    y=bottomOffset;
    if~useAppContainer
        uicontrol('Parent',hDlg,'Callback',@onOk,...
        'Position',[x,y,buttonSize],'FontUnits','normalized',...
        'FontSize',0.6,...
        'String',vision.getMessage('MATLAB:uistring:popupdialogs:OK'),...
        'Tag','OKButton');


        x=dlgSize(1)/2+buttonHalfSpace;
        uicontrol('Parent',hDlg,'Callback',@onCancel,...
        'Position',[x,y,buttonSize],'FontUnits','normalized',...
        'FontSize',0.6,...
        'String',vision.getMessage('MATLAB:uistring:popupdialogs:Cancel'),...
        'Tag','CancelButton');


        x=leftOffset;
        y=y+buttonSize(2)+vertGap;
        checkBox=uicontrol('Parent',hDlg,'Style','checkbox',...
        'Callback',@onCheck,'Position',[x,y,checkBoxSize],...
        'String',vision.getMessage('vision:labeler:DontShowAgain'),...
        'HorizontalAlignment','left','Value',0);


        x=leftOffset;
        y=y+checkBoxSize(2)+vertGap;
        uicontrol('Parent',hDlg,'Style','text',...
        'Position',[x,y,textSize],'HorizontalAlignment','left',...
        'String',dlgMessage);
    else
        uibutton('Parent',hDlg,'ButtonPushedFcn',@onOk,...
        'Position',[x,y,buttonSize],...
        'FontSize',12,...
        'Text',vision.getMessage('MATLAB:uistring:popupdialogs:OK'),...
        'Tag','OKButton');


        x=dlgSize(1)/2+buttonHalfSpace;
        uibutton('Parent',hDlg,'ButtonPushedFcn',@onCancel,...
        'Position',[x,y,buttonSize],...
        'FontSize',12,...
        'Text',vision.getMessage('MATLAB:uistring:popupdialogs:Cancel'),...
        'Tag','CancelButton');


        x=leftOffset;
        y=y+buttonSize(2)+vertGap;
        checkBox=uicheckbox('Parent',hDlg,...
        'ValueChangedFcn',@onCheck,'Position',[x,y,checkBoxSize],...
        'Text',vision.getMessage('vision:labeler:DontShowAgain'),...
        'Value',0);


        x=leftOffset;
        y=y+checkBoxSize(2)+vertGap;
        uilabel('Parent',hDlg,...
        'Position',[x,y,textSize],'HorizontalAlignment','left',...
        'Text',dlgMessage,'WordWrap','on');
    end


    hDlg.Position(4)=y+textSize(2)+vertGap;
    hDlg.Visible='on';
    uiwait(hDlg);


    function onOk(varargin)
        userCanceled=false;


        if checkBoxPrefChanged
            showDlgFlag=~checkBox.Value;
            s=settings;
            if strcmpi(instanceName,'videoLabeler')
                s.vision.videoLabeler.ShowUndoRunDialog.PersonalValue=showDlgFlag;
            elseif strcmpi(instanceName,'groundTruthLabeler')
                s.driving.groundTruthLabeler.ShowUndoRunDialog.PersonalValue=showDlgFlag;
            elseif strcmpi(instanceName,'imageLabeler')
                s.vision.imageLabeler.ShowUndoRunDialog.PersonalValue=showDlgFlag;
            elseif strcmpi(instanceName,'lidarLabeler')
                s.lidar.lidarLabeler.ShowUndoRunDialog.PersonalValue=showDlgFlag;
            end
        end
        closeDlg(hDlg);
    end

    function onCancel(varargin)
        userCanceled=true;
        closeDlg(hDlg);
    end

    function onCheck(varargin)
        checkBoxPrefChanged=true;
    end

    function closeDlg(dlg)
        if~useAppContainer()
            close(dlg);
        else
            delete(dlg);
        end
    end

    function tf=useAppContainer()
        tf=vision.internal.labeler.jtfeature('UseAppContainer');
    end
end