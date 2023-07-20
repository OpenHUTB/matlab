function strVals=sigbuilder_modal_edit_dialog(tag,titleStr,labels,...
    startvals,origin,popupChoices)











    geomConst.figBuff=6;
    geomConst.ojbHoffset=4;
    geomConst.rowDelta=8;
    geomConst.sysButtonExt=[55,20];
    geomConst.editBoxExt=[120,15];

    bgColor=[0.8,0.8,0.8];


    prevUnits=get(0,'Units');
    set(0,'Units','Points');
    screenPoint=get(0,'PointerLocation');
    screenSize=get(0,'ScreenSize');
    set(0,'Units',prevUnits);





    FigPos=get(0,'DefaultFigurePosition');
    FigWidth=75;
    FigHeight=45;
    FigPos(3:4)=[FigWidth,FigHeight];

    dlg=dialog(...
    'Visible','off',...
    'Name',titleStr,...
    'Pointer','arrow',...
    'Units','points',...
    'Position',FigPos,...
    'UserData',0,...
    'IntegerHandle','off',...
    'Color',bgColor,...
    'WindowStyle','normal',...
    'HandleVisibility','callback',...
    'Tag',tag...
    );

    textExtent=uicontrol(...
    'Units','points',...
    'Parent',dlg,...
    'Visible','off',...
    'Style','text',...
    'String','abcdefghijklABCDEFG'...
    );




    txtExt=get(textExtent,'Extent');
    if(ispc)
        txtDispHeight=1.15*txtExt(4);
        geomConst.staticTextH=txtExt(4);
    elseif(ismac)
        txtDispHeight=1.5*txtExt(4);
        geomConst.staticTextH=txtExt(4);
    else
        txtDispHeight=txtExt(4);
        geomConst.staticTextH=txtExt(4);
    end
    geomConst.sysButtonExt=[55,txtDispHeight+4];
    geomConst.editBoxExt=[120,txtDispHeight];


    if iscell(labels)
        numRows=length(labels);
        if nargin==3||isempty(startvals)
            startvals=cell(numRows,1);
        else
            if length(startvals)~=numRows
                error(message('sigbldr_ui:sigbuilder_modal_edit_dialog:labelsStringMustBeSameLength'));
            end
        end
        rowWidth(numRows)=0;
        for i=1:numRows
            rowWidth(i)=get_text_width(labels{i},textExtent);
        end
    else
        numRows=1;
        rowWidth=get_text_width(labels,textExtent);
        if nargin==3||isempty(startvals)
            startvals='';
        end

    end

    if nargin<6
        popupChoices=cell(1,numRows);
    end

    xMargin2=geomConst.figBuff+max(rowWidth)+geomConst.ojbHoffset;

    figWidth=xMargin2+geomConst.editBoxExt(1)+geomConst.figBuff;
    figHeight=numRows*(geomConst.editBoxExt(2)+geomConst.rowDelta)+...
    2*geomConst.figBuff+geomConst.sysButtonExt(2);

    if nargin<5||isempty(origin)
        origin=screenPoint;
    end

    if origin(1)+figWidth>(screenSize(3)-40)
        origin(1)=screenSize(3)-40-figWidth;
    end
    if origin(2)+figHeight>(screenSize(4)-40)
        origin(2)=screenSize(4)-40-figHeight;
    end
    newFigPos=[origin,figWidth,figHeight];

    set(dlg,'Position',newFigPos);


    currY=figHeight-geomConst.editBoxExt(2)-geomConst.figBuff;

    for i=1:numRows
        labelPos=[geomConst.figBuff,currY,max(rowWidth),geomConst.editBoxExt(2)];
        editPos=[xMargin2,currY,geomConst.editBoxExt];

        if iscell(labels)
            labelStr=labels{i};
            if isempty(popupChoices{i})
                editStr=char(startvals{i});
            end
        else
            labelStr=labels;
            editStr=startvals;
        end
        editFieldTag=['DialogEditField',num2str(i)];
        editFieldTitleTag=['DialogEditFieldTitle',num2str(i)];

        uicontrol('Parent',dlg,...
        'Style','text',...
        'BackgroundColor',bgColor,...
        'HorizontalAlignment','left',...
        'String',labelStr,...
        'Units','points',...
        'Position',labelPos,...
        'Tag',editFieldTitleTag...
        );

        if isempty(popupChoices{i})
            editH(i)=uicontrol('Parent',dlg,...
            'Style','edit',...
            'BackgroundColor','w',...
            'HorizontalAlignment','left',...
            'String',editStr,...
            'Units','points',...
            'Position',editPos,...
            'Tag',editFieldTag...
            );
        else



            editH(i)=uicontrol('Parent',dlg,...
            'Style','popup',...
            'BackgroundColor','w',...
            'HorizontalAlignment','left',...
            'String',popupChoices{i},...
            'Value',startvals{i},...
            'Units','points',...
            'Position',editPos,...
            'Tag',editFieldTag...
            );
        end

        currY=currY-(geomConst.editBoxExt(2)+geomConst.rowDelta);
    end

    currY=geomConst.figBuff;
    currX=figWidth-geomConst.figBuff-2*(geomConst.sysButtonExt(1))-...
    geomConst.ojbHoffset;

    okPos=[currX,currY,geomConst.sysButtonExt];
    cancelPos=okPos+[geomConst.sysButtonExt(1)+geomConst.ojbHoffset,0,0,0];


    uicontrol('Parent',dlg,...
    'Style','push',...
    'BackgroundColor',bgColor,...
    'HorizontalAlignment','left',...
    'HandleVisibility','callback',...
    'Callback','uiresume(gcf)',...
    'String',getString(message('sigbldr_ui:sigbuilder_modal_edit_dialog:OK')),...
    'Units','points',...
    'Position',okPos,...
    'Tag','OKDlg'...
    );



    uicontrol('Parent',dlg,...
    'Style','push',...
    'BackgroundColor',bgColor,...
    'HorizontalAlignment','left',...
    'HandleVisibility','callback',...
    'Callback','uiresume(gcf)',...
    'String',getString(message('sigbldr_ui:sigbuilder_modal_edit_dialog:Cancel')),...
    'Units','points',...
    'Position',cancelPos,...
    'Tag','CancelDlg'...
    );



    axH=findobj(dlg,'Style','axes');
    if~isempty(axH)
        delete(axH);
    end

    set(dlg,'WindowStyle','modal','Visible','on');
    drawnow;
    uiwait(dlg);

    if ishghandle(dlg,'figure'),
        objStr=get(get(dlg,'CurrentObject'),'Tag');
        if(strcmp(objStr,'CancelDlg'))
            strVals=0;
        else
            for i=1:numRows
                if isempty(popupChoices{i})
                    strVals{i}=get(editH(i),'String');
                else
                    allStrings=get(editH(i),'String');
                    strVals{i}=allStrings{get(editH(i),'Value')};
                end
            end
        end
        delete(dlg);
        if numRows==1&iscell(strVals)
            strVals=strVals{1};
        end
    else
        strVals=0;
    end


    function width=get_text_width(labelStr,hgObj)
        set(hgObj,'String',labelStr);
        ext=get(hgObj,'Extent');
        width=ext(3);
