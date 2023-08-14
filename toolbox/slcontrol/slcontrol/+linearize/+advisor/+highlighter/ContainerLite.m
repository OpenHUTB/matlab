classdef ContainerLite<handle


















    properties
Model
    end

    properties(Access=protected)

Fig
UITable
HLData


Exit
Help


ModelListener
    end

    methods
        function updateHLData(thisGUI,HighlighterData)
            import linearize.advisor.highlighter.*

            if~isempty(thisGUI.HLData)
                removehighlight(thisGUI.HLData);
            end
            if isa(HighlighterData,'linearize.advisor.highlighter.SCDHighlighterData')
                thisGUI.HLData=createHighlighter(HighlighterData);
            else
                thisGUI.HLData=HighlighterData;
            end
            createTable(thisGUI);
        end

        function hldata=getHLData(thisGUI)
            hldata=thisGUI.HLData;
        end
    end

    methods(Access=protected)

        function thisGUI=ContainerLite(model)
            thisGUI.Model=model;
            initialize(thisGUI);
            installListener(thisGUI);
        end

        function createTable(thisGUI)
            num=numel(thisGUI.HLData);
            TableData=cell(num,2);


            for ct=1:num
                IsEmpty=thisGUI.HLData(ct).IsDataEmpty&&...
                ~strcmp(thisGUI.HLData(ct).Description,...
                getString(message('Slcontrol:linadvisor:HighlightOffPath')));

                if~IsEmpty
                    fontColor='#000000';
                else
                    fontColor='#808080';
                end
                bgcolor='%FFFFFF';

                TableData{ct,1}=sprintf('<html><table border=0 width=400 bgcolor="%s" color = "%s"><font color="%s"> %s',...
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

                HLOptions=thisGUI.HLData(ct).HLOptions;

                if~strcmpi(HLOptions.highlightstyle,'SolidLine')
                    TableData{ct,2}=s1;
                else
                    TableData{ct,2}=s2;
                end

                col=HLOptions.highlightcolor(1:3);

                clr=dec2hex(round(col*255),2)';clr=['#';clr(:)]';

                if~IsEmpty

                    TableData{ct,2}=strcat(...
                    ['<html><font color="',clr,'">'],TableData{ct,2});
                else
                    TableData{ct,2}=['<html><font color="#808080">','(None)'];
                end
            end



            TableData=TableData(num:-1:1,:);












            set(thisGUI.UITable,'Data',TableData);

            figure(thisGUI.Fig)
        end

        function initialize(thisGUI)


            strLegend=getString(message('Slcontrol:lintool:TableLegend'));
            strExit=getString(message('Slcontrol:lintool:ButtonExit'));
            strExitTT=getString(message('Slcontrol:lintool:ButtonExitToolTip'));
            strHelp=getString(message('Slcontrol:lintool:Help'));
            strFigName=getString(message('Slcontrol:lintool:SCDHighlightingTool'));
            tooltipstr=getString(message('Slcontrol:lintool:HLTableTooltip'));
            BlockColumnName=getString(message('Slcontrol:lintool:HLTableCol1Header'));

            thisGUI.Fig=figure('Tag','figure1',...
            'Units','characters',...
            'Position',[80,10,60,14],...
            'Name',strFigName,...
            'MenuBar','none',...
            'Resize','off',...
            'NumberTitle','off',...
            'HandleVisibility','off',...
            'Color',get(0,'DefaultUicontrolBackgroundColor'),...
            'CloseRequestFcn',{@LocalCloseFigureCallBack,thisGUI});


            movegui(thisGUI.Fig,'center');



            thisGUI.UITable=uitable(...
            'Parent',thisGUI.Fig,...
            'Tag','uitable1',...
            'UserData',zeros(1,0),...
            'Units','normalized',...
            'Position',[0.05,0.25,0.90,0.70],...
            'FontName','Helvetica',...
            'FontSize',10,...
            'RowStriping','off',...
            'RowName',[],...
            'TooltipString',tooltipstr,...
...
            'BackgroundColor',[1,1,1;0.94,0.94,0.94],...
...
            'ColumnEditable',[false,false],...
            'ColumnFormat',{'char','char'},...
            'ColumnName',{BlockColumnName,strLegend},...
            'ColumnWidth',{200,60});

            thisGUI.Exit=uicontrol(...
            'Parent',thisGUI.Fig,...
            'Tag','Exit',...
            'Style','pushbutton',...
            'Units','normalized',...
            'Position',[0.75,0.05,0.2,0.15],...
            'FontName','Helvetica',...
            'FontSize',10,...
            'String',strExit,...
            'TooltipString',strExitTT,...
            'Callback',{@LocalExitCallBack,thisGUI});

            thisGUI.Help=uicontrol(...
            'Parent',thisGUI.Fig,...
            'Tag','Help',...
            'Style','pushbutton',...
            'Units','normalized',...
            'Position',[0.50,0.05,0.2,0.15],...
            'FontName','Helvetica',...
            'FontSize',10,...
            'String',strHelp,...
            'Callback',{@LocalHelpCallBack,thisGUI});


        end

        function installListener(thisGUI)
            mdlObj=get_param(thisGUI.Model,'Object');
            thisGUI.ModelListener=addListener(mdlObj,...
            'CloseEvent',{@LocalModelCloseCallBack,thisGUI});
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
                thisGUI=linearize.advisor.highlighter.ContainerLite(model);
                mdlToGUIMap(model)=thisGUI;
            end
        end
    end

    methods(Hidden)

        function GUIHandles=qeGetUIHandles(thisGUI)
            GUIHandles=struct('Figure',thisGUI.Fig,...
            'Table',thisGUI.UITable,...
            'Button_EX',thisGUI.Exit,...
            'Button_HP',thisGUI.Help);
        end

        function val=qeIsFigureOn(thisGUI)
            val=strcmp(thisGUI.Fig.Visible,'on');
        end

        function hd=qeGetHLData(thisGUI)
            hd=thisGUI.HLData;
        end

        function qeRemoveSelection(thisGUI)

            TableData=get(thisGUI.UITable,'Data');
            numData=size(TableData,1);


            bgcolor='#FFFFFF';

            for ct=1:numData
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

function LocalHelpCallBack(~,~,~)

    web('https://www.mathworks.com');
end

function LocalCloseFigureCallBack(~,~,thisGUI)
    delete(thisGUI.Fig);
    removehighlight(thisGUI.HLData);
end