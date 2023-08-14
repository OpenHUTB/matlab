classdef Container<handle


















    properties
Model
    end

    properties(Access=protected)
LayoutData
Fig
UITable
HLData


Highlightall
Clearall
MoveUp
MoveDown
Exit
Help


ModelListener


SelectedIdx
    end

    methods
        function updateHLData(thisGUI,HighlighterData)
            import linearize.advisor.highlighter.*
            if isa(HighlighterData,'linearize.advisor.highlighter.SCDHighlighterData')
                thisGUI.HLData=createHighlighter(HighlighterData);
            else
                thisGUI.HLData=HighlighterData;
            end
            thisGUI.SelectedIdx=false(numel(HighlighterData),1);
            createTable(thisGUI);
        end

        function hldata=getHLData(thisGUI)
            hldata=thisGUI.HLData;
        end
    end

    methods(Access=protected)

        function thisGUI=Container(model)
            thisGUI.Model=model;
            initialize(thisGUI);
            installListener(thisGUI);
        end

        function createTable(thisGUI)
            num=numel(thisGUI.HLData);
            TableData=cell(num,3);


            for ct=1:num
                IsEmpty=thisGUI.HLData(ct).IsDataEmpty;
                TableData{ct,1}=~IsEmpty;

                if~IsEmpty
                    fontColor='#000000';
                else
                    fontColor='#808080';
                end




                bgcolor='%FFFFFF';


                TableData{ct,2}=sprintf('<html><table border=0 width=400 bgcolor="%s" color = "%s"><font color="%s"> %s',...
                bgcolor,...
                fontColor,...
                fontColor,...
                thisGUI.HLData(ct).Description);


                if TableData{ct,1}
                    highlight(thisGUI.HLData(ct));
                end

                s=char(9600);
                s1=sprintf('%s %s %s %s',s,s,s,s);
                s2=[s,s,s,s];

                HLOptions=thisGUI.HLData(ct).HLOptions();

                if~strcmpi(HLOptions.highlightstyle,'SolidLine')
                    TableData{ct,3}=s1;
                else
                    TableData{ct,3}=s2;
                end

                blk=[0,0,0];
                blkclr=dec2hex(round(blk*255),2)';
                blkclr=['#';blkclr(:)]';

                col=HLOptions.highlightcolor(1:3);
%# format color as: #FFFFFF
                clr=dec2hex(round(col*255),2)';clr=['#';clr(:)]';

                if~IsEmpty
%# apply formatting to third row first column
                    TableData{ct,3}=strcat(...
                    ['<html><font color="',clr,'">'],TableData{ct,3});
                else
                    TableData{ct,3}=['<html><font color="#808080">','(None)'];
                end
            end

            set(thisGUI.UITable,'Data',TableData,'CellEditCallBack',{@LocalTableHighlgihtCallback,thisGUI},'CellSelectionCallBack',{@LocalFocusthisPathCallback,thisGUI});
            figure(thisGUI.Fig)
        end

        function initialize(thisGUI)

            initializeLayoutData(thisGUI);


            strVisible=getString(message('Slcontrol:lintool:VisibleControl'));
            strLegend=getString(message('Slcontrol:lintool:TableLegend'));
            strHighlightall=getString(message('Slcontrol:lintool:ButtonHighlightAll'));
            strClearall=getString(message('Slcontrol:lintool:ButtonClearAll'));
            strExit=getString(message('Slcontrol:lintool:ButtonExit'));
            strMoveUp=getString(message('Slcontrol:lintool:ButtonMoveUp'));
            strMoveDown=getString(message('Slcontrol:lintool:ButtonMoveDown'));
            strHelp=getString(message('Slcontrol:lintool:Help'));
            strFigName=getString(message('Slcontrol:lintool:SCDHighlightingTool'));

            thisGUI.Fig=figure('Tag','figure1',...
            'Units','characters',...
            'Position',thisGUI.LayoutData.figuresize,...
            'Name',strFigName,...
            'MenuBar','none',...
            'Resize','on',...
            'NumberTitle','off',...
            'HandleVisibility','off',...
            'Color',get(0,'DefaultUicontrolBackgroundColor'),...
            'CloseRequestFcn',{@LocalCloseFigureCallBack,thisGUI});


            movegui(thisGUI.Fig,'center');


            set(thisGUI.Fig,'Units','pixel')
            positionInPixel=get(thisGUI.Fig,'Position');
            set(thisGUI.Fig,'Units','characters')
            thisGUI.LayoutData.pixelOverCharactor=positionInPixel(3)/80;


            BlockColumnName='Description';
            thisGUI.UITable=uitable(...
            'Parent',thisGUI.Fig,...
            'Tag','uitable1',...
            'UserData',zeros(1,0),...
            'Units','character',...
            'Position',thisGUI.LayoutData.uitablesize,...
            'FontName','Helvetica',...
            'FontSize',10,...
            'RowStriping','off',...
            'RowName',[],...
            'BackgroundColor',[1,1,1;0.94,0.94,0.94],...
            'ColumnEditable',[true,false,false],...
            'ColumnFormat',{'logical','char','char'},...
            'ColumnName',{strVisible,BlockColumnName,strLegend},...
            'ColumnWidth',thisGUI.LayoutData.uitablecolumn);


            thisGUI.Highlightall=uicontrol(...
            'Parent',thisGUI.Fig,...
            'Tag','Highlightall',...
            'Style','pushbutton',...
            'Units','characters',...
            'Position',thisGUI.LayoutData.button_hl,...
            'FontName','Helvetica',...
            'FontSize',10,...
            'String',strHighlightall,...
            'Callback',{@LocalHighlightAllCallBack,thisGUI});

            thisGUI.Clearall=uicontrol(...
            'Parent',thisGUI.Fig,...
            'Tag','Clearall',...
            'Style','pushbutton',...
            'Units','characters',...
            'Position',thisGUI.LayoutData.button_cr,...
            'FontName','Helvetica',...
            'FontSize',10,...
            'String',strClearall,...
            'Callback',{@LocalClearAllCallBack,thisGUI});

            thisGUI.MoveUp=uicontrol(...
            'Parent',thisGUI.Fig,...
            'Tag','Highlightall',...
            'Style','pushbutton',...
            'Units','characters',...
            'Position',thisGUI.LayoutData.button_up,...
            'FontName','Helvetica',...
            'FontSize',10,...
            'String',strMoveUp,...
            'Callback',{@LocalMoveUp,thisGUI});

            thisGUI.MoveDown=uicontrol(...
            'Parent',thisGUI.Fig,...
            'Tag','Highlightall',...
            'Style','pushbutton',...
            'Units','characters',...
            'Position',thisGUI.LayoutData.button_dw,...
            'FontName','Helvetica',...
            'FontSize',10,...
            'String',strMoveDown,...
            'Callback',{@LocalMoveDown,thisGUI});

            thisGUI.Exit=uicontrol(...
            'Parent',thisGUI.Fig,...
            'Tag','Exit',...
            'Style','pushbutton',...
            'Units','characters',...
            'Position',thisGUI.LayoutData.button_ex,...
            'FontName','Helvetica',...
            'FontSize',10,...
            'String',strExit,...
            'Callback',{@LocalExitCallBack,thisGUI});

            thisGUI.Help=uicontrol(...
            'Parent',thisGUI.Fig,...
            'Tag','Help',...
            'Style','pushbutton',...
            'Units','characters',...
            'Position',thisGUI.LayoutData.button_hp,...
            'FontName','Helvetica',...
            'FontSize',10,...
            'String',strHelp,...
            'Callback',{@LocalHelpCallBack,thisGUI});


            thisGUI.Fig.SizeChangedFcn={@LocalResizeGUI,thisGUI};
        end

        function installListener(thisGUI)
            mdlObj=get_param(thisGUI.Model,'Object');
            thisGUI.ModelListener=addlistener(mdlObj,'CloseEvent',@(s,e)LocalModelCloseCallBack(s,e,thisGUI));
        end

        function initializeLayoutData(thisGUI)



            delta=0;


            buttonGroupOrigin=[2,0.75,0,2.125];
            thisGUI.LayoutData.figuresize=[80,10,80,30];
            thisGUI.LayoutData.uitablesize=[2.3,3.5,76,11.5+15];
            thisGUI.LayoutData.uitablecolumn={70,245,60};

            button_hl=buttonGroupOrigin+[0,0,14,0];
            button_cr=buttonGroupOrigin+[delta+button_hl(1)+button_hl(3),0,14,0];
            button_up=buttonGroupOrigin+[delta+button_cr(1)+button_cr(3),0,9,0];
            button_dw=buttonGroupOrigin+[delta+button_up(1)+button_up(3),0,9,0];
            button_hp=buttonGroupOrigin+[delta+button_dw(1)+button_dw(3),0,10,0];
            button_ex=buttonGroupOrigin+[delta+button_hp(1)+button_hp(3),0,10,0];


            thisGUI.LayoutData.button_hl=button_hl;
            thisGUI.LayoutData.button_cr=button_cr;
            thisGUI.LayoutData.button_up=button_up;
            thisGUI.LayoutData.button_dw=button_dw;
            thisGUI.LayoutData.button_hp=button_hp;
            thisGUI.LayoutData.button_ex=button_ex;

            thisGUI.LayoutData.pixelOverCharactor=1;
        end


        function updateTableData(thisGUI,newRowOrder)

            thisGUI.HLData=thisGUI.HLData(newRowOrder);
            thisGUI.SelectedIdx=thisGUI.SelectedIdx(newRowOrder);

            oldTableData=get(thisGUI.UITable,'Data');
            newTableData=cell(size(oldTableData));
            numData=size(oldTableData,1);

            for ctd=1:numData
                newTableData(ctd,:)=oldTableData(newRowOrder(ctd),:);

                if thisGUI.SelectedIdx(ctd)
                    bgcolor='#46A0FF';
                else
                    bgcolor='%FFFFFF';
                end

                if~thisGUI.HLData(ctd).IsDataEmpty()
                    fontColor='#000000';
                else
                    fontColor='#808080';
                end

                newTableData{ctd,2}=sprintf('<html><table border=0 width=400 bgcolor="%s" color = "%s"><font color="%s"> %s',...
                bgcolor,...
                fontColor,...
                fontColor,...
                thisGUI.HLData(ctd).Description);
            end


            set(thisGUI.UITable,'Data',newTableData);
        end
    end

    methods
        function delete(thisGUI)
            if isvalid(thisGUI.Fig)
                close(thisGUI.Fig);
            end
        end
    end

    methods(Static)
        function thisGUI=getInstance(model)

            if~bdIsLoaded(model)
                open_system(model);
            end

            persistent mdlToGUIMap
            if isempty(mdlToGUIMap)
                mdlToGUIMap=containers.Map('KeyType','char','ValueType','any');
            end

            createNewGUI=true;
            if mdlToGUIMap.isKey(model)
                old_GUI=mdlToGUIMap(model);
                if isvalid(old_GUI)&&isvalid(old_GUI.Fig)
                    thisGUI=old_GUI;
                    createNewGUI=false;
                else
                    delete(old_GUI);
                end
            end
            if createNewGUI
                thisGUI=linearize.advisor.highlighter.Container(model);
                mdlToGUIMap(model)=thisGUI;
            end
        end
    end

    methods(Hidden)

        function GUIHandles=qeGetUIHandles(thisGUI)
            GUIHandles=struct('Figure',thisGUI.Fig,...
            'Table',thisGUI.UITable,...
            'Button_HL',thisGUI.Highlightall,...
            'Button_CL',thisGUI.Clearall,...
            'Button_UP',thisGUI.MoveUp,...
            'Button_DW',thisGUI.MoveDown,...
            'Button_EX',thisGUI.Exit,...
            'Button_HP',thisGUI.Help);
        end

        function val=qeIsFigureOn(thisGUI)
            val=strcmp(thisGUI.Fig.Visible,'on');
        end

        function hd=qeGetHLData(thisGUI)
            hd=thisGUI.HLData;
        end


        function qeClickTable(thisGUI,ct)

            thisGUI.SelectedIdx(ct)=true;
            TableData=get(thisGUI.UITable,'Data');


            bgcolor='#46A0FF';

            if~thisGUI.HLData(ct).IsDataEmpty()
                fontColor='#000000';
            else
                fontColor='#808080';
            end

            TableData{ct,2}=sprintf('<html><table border=0 width=400 bgcolor="%s" color = "%s"><font color="%s"> %s',...
            bgcolor,...
            fontColor,...
            fontColor,...
            thisGUI.HLData(ct).Description);


            set(thisGUI.UITable,'Data',TableData);
        end

        function qeRemoveSelection(thisGUI)

            TableData=get(thisGUI.UITable,'Data');
            numData=size(TableData,1);


            bgcolor='#FFFFFF';

            for ct=1:numData
                thisGUI.SelectedIdx(ct)=false;
                if~thisGUI.HLData(ct).IsDataEmpty()
                    fontColor='#000000';
                else
                    fontColor='#808080';
                end

                TableData{ct,2}=sprintf('<html><table border=0 width=400 bgcolor="%s" color = "%s"><font color="%s"> %s',...
                bgcolor,...
                fontColor,...
                fontColor,...
                thisGUI.HLData(ct).Description);


                set(thisGUI.UITable,'Data',TableData);
            end
        end

    end

end




function LocalModelCloseCallBack(~,~,thisGUI)
    delete(thisGUI);
end

function LocalExitCallBack(~,~,thisGUI)
    delete(thisGUI.Fig);
    removehighlight(thisGUI.HLData);
end

function LocalHighlightAllCallBack(~,~,thisGUI)
    T=thisGUI.UITable;
    TableData=get(T,'Data');

    for ct=1:length(thisGUI.HLData)
        if~thisGUI.HLData(ct).IsDataEmpty
            if TableData{ct,1}==false
                TableData{ct,1}=true;
            end
        end
    end




    thisGUI.HLData.highlight();

    set(T,'Data',TableData);
    figure(thisGUI.Fig);
end

function LocalClearAllCallBack(~,~,thisGUI)
    T=thisGUI.UITable;
    TableData=get(T,'Data');
    HLInfo=thisGUI.HLData;
    numData=size(TableData,1);

    for ct=1:numData
        if(TableData{ct,1}==true)
            TableData{ct,1}=false;
            removehighlight(HLInfo(ct));
        end
    end




















    set(T,'Data',TableData,...
    'CellEditCallBack',{@LocalTableHighlgihtCallback,thisGUI},...
    'CellSelectionCallBack',{@LocalFocusthisPathCallback,thisGUI});
    thisGUI.HLData=HLInfo;
    figure(thisGUI.Fig);
end


function LocalResizeGUI(hObjects,~,thisGUI)

    if hObjects.Position(3)>=thisGUI.LayoutData.figuresize(3)&&...
        hObjects.Position(4)>=thisGUI.LayoutData.figuresize(4)
        thisGUI.UITable.Position(3)=hObjects.Position(3)-4;
        thisGUI.UITable.Position(4)=hObjects.Position(4)-3.5;


        thisGUI.UITable.ColumnWidth={thisGUI.LayoutData.uitablecolumn{1},...
        thisGUI.LayoutData.uitablecolumn{2}+...
        (hObjects.Position(3)-thisGUI.LayoutData.figuresize(3))*thisGUI.LayoutData.pixelOverCharactor,...
        thisGUI.LayoutData.uitablecolumn{3}};


        numButtons=6;
        delta=hObjects.Position(3)-thisGUI.LayoutData.figuresize(3);
        thisGUI.Clearall.Position(1)=thisGUI.LayoutData.button_cr(1)+delta/(numButtons-1);
        thisGUI.MoveUp.Position(1)=thisGUI.LayoutData.button_up(1)+delta/(numButtons-1)*2;
        thisGUI.MoveDown.Position(1)=thisGUI.LayoutData.button_dw(1)+delta/(numButtons-1)*3;
        thisGUI.Help.Position(1)=thisGUI.LayoutData.button_hp(1)+delta/(numButtons-1)*4;
        thisGUI.Exit.Position(1)=thisGUI.LayoutData.button_ex(1)+delta/(numButtons-1)*5;
    end
end


function LocalMoveUp(~,~,thisGUI)

    oldTableData=get(thisGUI.UITable,'Data');
    numData=size(oldTableData,1);
    selectedRow=find(thisGUI.SelectedIdx);

    if~isempty(selectedRow)

        IndexContainedInRow=1:numData;

        for ct=1:numel(selectedRow)
            if selectedRow(ct)~=1&&...
                ~ismember(IndexContainedInRow(selectedRow(ct)-1),selectedRow)

                temp=IndexContainedInRow(selectedRow(ct)-1);
                IndexContainedInRow(selectedRow(ct)-1)=selectedRow(ct);
                IndexContainedInRow(selectedRow(ct))=temp;
            end
        end

        updateTableData(thisGUI,IndexContainedInRow);







        firstIdx=find(IndexContainedInRow(:)-(1:numData)',1,'first');
        affectedIdx=firstIdx:numData;


        removehighlight(thisGUI.HLData(affectedIdx));
        for ct=firstIdx:numData
            if oldTableData{IndexContainedInRow(ct),1}
                highlight(thisGUI.HLData(ct));
            end
        end
        figure(thisGUI.Fig);
    end
end


function LocalMoveDown(~,~,thisGUI)
    oldTableData=get(thisGUI.UITable,'Data');
    numData=size(oldTableData,1);
    selectedRow=find(thisGUI.SelectedIdx);

    if~isempty(selectedRow)

        IndexContainedInRow=1:numData;

        for ct=numel(selectedRow):-1:1
            if selectedRow(ct)~=numData&&...
                ~ismember(IndexContainedInRow(selectedRow(ct)+1),selectedRow)

                temp=IndexContainedInRow(selectedRow(ct)+1);
                IndexContainedInRow(selectedRow(ct)+1)=selectedRow(ct);
                IndexContainedInRow(selectedRow(ct))=temp;
            end
        end

        updateTableData(thisGUI,IndexContainedInRow);






        firstIdx=find(IndexContainedInRow(:)-(1:numData)',1,'first');
        affectedIdx=firstIdx:numData;


        removehighlight(thisGUI.HLData(affectedIdx));
        for ct=firstIdx:numData
            if oldTableData{IndexContainedInRow(ct),1}
                highlight(thisGUI.HLData(ct));
            end
        end
        figure(thisGUI.Fig);
    end
end


function LocalHelpCallBack(~,~,~)

    web('https://www.mathworks.com');
end

function LocalTableHighlgihtCallback(hObject,eventdata,thisGUI)

    HLInfo=thisGUI.HLData;

    TableData=get(hObject,'Data');
    TableColumns=get(hObject,'ColumnFormat');

    RowIdx=eventdata.Indices(1);
    ColIdx=eventdata.Indices(2);
    if strcmp(TableColumns(ColIdx),'logical')

        if eventdata.EditData&&~HLInfo(RowIdx).IsDataEmpty
            TableData{RowIdx,ColIdx}=true;
            highL=true;
        else
            TableData{RowIdx,ColIdx}=false;
            highL=false;
        end
    end

    set(hObject,'Data',TableData);

    selectedRowIdx=1:length(HLInfo);
    hlSelection=[TableData{:,1}];
    selectedRowIdx=selectedRowIdx(hlSelection);

    if highL
        for ct=1:length(HLInfo)

            removehighlight(HLInfo(ct));
        end
        highlight(HLInfo(selectedRowIdx));
    else
        removehighlight(HLInfo(RowIdx));
    end
    thisGUI.HLData=HLInfo;
    figure(thisGUI.Fig);
end

function LocalFocusthisPathCallback(~,eventdata,thisGUI)
    if~isempty(eventdata.Indices)&&all(eventdata.Indices(1,2)==2)

        thisGUI.SelectedIdx=false(numel(thisGUI.HLData),1);
        TableData=get(thisGUI.UITable,'Data');
        numData=size(TableData,1);
        for ct=1:numData
            bgcolor='%FFFFFF';
            if~thisGUI.HLData(ct).IsDataEmpty()
                fontColor='#000000';
            else
                fontColor='#808080';
            end
            TableData{ct,2}=sprintf('<html><table border=0 width=400 bgcolor="%s" color = "%s"><font color="%s"> %s',...
            bgcolor,...
            fontColor,...
            fontColor,...
            thisGUI.HLData(ct).Description);
        end

        set(thisGUI.UITable,'Data',TableData);

        thisGUI.SelectedIdx(eventdata.Indices(:,1))=true;
    end
end

function LocalCloseFigureCallBack(~,~,thisGUI)
    delete(thisGUI.Fig);
    removehighlight(thisGUI.HLData);
end
