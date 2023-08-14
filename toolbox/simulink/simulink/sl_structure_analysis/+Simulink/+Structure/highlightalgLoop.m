


function[algLoops,uiHandle]=highlightalgLoop(objName,enableUI)


    import Simulink.Structure.*

    if nargin<2
        enableUI=false;
    end


    if slfeature('EngineInterface')==0
        slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);
        disableFeature=true;
    else
        disableFeature=false;
    end



    mdl=get_param(bdroot(objName),'Name');




    c=onCleanup(@()localCleanup(mdl,disableFeature));

    [algLoops,totalLoops]=getAlgLoopInfo(objName);



    nLoops=length(algLoops);

    if nLoops<1
        uiHandle=[];
        disp(DAStudio.message('Simulink:utility:NoLoopsFound'));
        return;
    end

    if~enableUI
        for i=1:nLoops
            Id=algLoops(i).Id;

            if algLoops(i).isGraphicalLoop
                algLoops(i)=algLoops(i).highlight(Id(2),totalLoops);
            else
                algLoops(i)=algLoops(i).highlightNoneGraphicalLoop(Id(2),totalLoops);
            end
        end
    else
        uiHandle=algLoopGui_build(mdl,algLoops,totalLoops);
    end

    localCleanup(mdl,disableFeature);
end





function localCleanup(mdl,disableFeature)

    if strcmpi(get_param(mdl,'SimulationStatus'),'paused')

        modelObj=get_param(mdl,'object');
        modelObj.term;
    end

    if disableFeature
        slfeature('EngineInterface',0);
    end
end




function fig_hdl=algLoopGui_build(mdl,algLoops,totalLoops)



    handles=struct();

    fig_hdl=build_gui(mdl,algLoops,totalLoops,handles);

end




function fig_hdl=build_gui(mdl,algLoops,totalLoops,handles)


    persistent mdlToUIMap;

    if isempty(mdlToUIMap)
        mdlToUIMap=containers.Map('KeyType','char','ValueType','any');
    end


    if mdlToUIMap.isKey(mdl)
        value=mdlToUIMap(mdl);
        old_fig=value{1};

        delete(old_fig);
    end


    handles.mdl=mdl;
    handles.algLoops=algLoops;
    handles.totalLoops=totalLoops;
    handles.mdlToUIMap={};


    strVisible=DAStudio.message('Simulink:utility:Visible');
    strLoopId=DAStudio.message('Simulink:utility:LoopId');
    strType=DAStudio.message('Simulink:utility:Type');
    strLegend=DAStudio.message('Simulink:utility:Legend');
    strArtificial=DAStudio.message('Simulink:utility:Artificial');
    strReal=DAStudio.message('Simulink:utility:Real');
    strLoopInfo=DAStudio.message('Simulink:utility:LoopInfo',mdl);
    strExit=DAStudio.message('Simulink:utility:Exit');
    strClearall=DAStudio.message('Simulink:utility:Clearall');
    strHighlightall=DAStudio.message('Simulink:utility:Highlightall');





    defaultUnit=get(groot,'Units');
    if~strcmp(defaultUnit,'pixels')
        set(groot,'units','pixels');
    end
    screenSize=get(groot,'ScreenSize');
    screenLength=screenSize(3);
    screenHeight=screenSize(4);
    dialogLength=450;
    dialogHeight=250;
    dialogX=(screenLength-dialogLength)/2;
    dialogY=(screenHeight-dialogHeight)/2;

    handles.figure1=figure(...
    'Tag','figure1',...
    'Units','pixels',...
    'Position',[dialogX,dialogY,dialogLength,dialogHeight],...
    'Name',strLoopInfo,...
    'MenuBar','none',...
    'Resize','off',...
    'NumberTitle','off',...
    'HandleVisibility','off',...
    'Color',get(0,'DefaultUicontrolBackgroundColor'));



    handles.uitable1=uitable(...
    'Parent',handles.figure1,...
    'Tag','uitable1',...
    'UserData',zeros(1,0),...
    'Position',[15,65,dialogLength*0.85,dialogHeight*0.68],...
    'FontName','Helvetica',...
    'FontSize',10,...
    'BackgroundColor',[1,1,1;0.94,0.94,0.94],...
    'ColumnEditable',[true,false,false,false],...
    'ColumnFormat',{'logical','char','char','char'},...
    'ColumnName',{strVisible,strLoopId,strType,strLegend},...
    'ColumnWidth',{'auto','auto','auto','auto'},...
    'Data',{false,'','','';false,'','','';false,'','','';false,'','','';false,'','','';false,'','','';false,'','','';false,'','',''});


    mdlToUIMap(mdl)={handles.figure1,handles.uitable1,algLoops};
    handles.mdlToUIMap=mdlToUIMap;



    handles.Exit=uicontrol(...
    'Parent',handles.figure1,...
    'Tag','Exit',...
    'Style','pushbutton',...
    'Units','characters',...
    'Position',[40.2857142857143,0.732142857142861,14.1428571428571,2.125],...
    'FontName','Helvetica',...
    'FontSize',10,...
    'String',strExit,...
    'Callback',{@Exit_Callback,handles});


    handles.Clearall=uicontrol(...
    'Parent',handles.figure1,...
    'Tag','Clearall',...
    'Style','pushbutton',...
    'Units','characters',...
    'Position',[25.5714285714286,0.732142857142861,13.1428571428571,2.125],...
    'FontName','Helvetica',...
    'FontSize',10,...
    'String',strClearall,...
    'Callback',{@Clearall_Callback,handles});


    handles.Highlightall=uicontrol(...
    'Parent',handles.figure1,...
    'Tag','Highlightall',...
    'Style','pushbutton',...
    'Units','characters',...
    'Position',[9.57142857142857,0.732142857142861,14.4285714285714,2.125],...
    'FontName','Helvetica',...
    'FontSize',10,...
    'String',strHighlightall,...
    'Callback',{@Highlightall_Callback,handles});

    n=length(algLoops);

    loopType={strReal,strArtificial,strArtificial};

    dat=cell(n,4);


    f=figure('visible','off');
    cmap=colormap(f);
    close(f);

    for i=1:n
        loopId=algLoops(i).Id;
        colorIndex=loopId(2);
        dat{i,1}=true;
        dat{i,2}=strcat(int2str(loopId(1)),'#',int2str(loopId(2)));

        if algLoops(i).isGraphicalLoop
            dat{i,3}=loopType{algLoops(i).IsArtificial+1};
            algLoops(i).highlight(algLoops(i).Id(2),totalLoops);
        else
            dat{i,3}=' ';
            algLoops(i).highlightNoneGraphicalLoop(algLoops(i).Id(2),totalLoops);

            warning('off','backtrace');
            msgId='Simulink:utility:NoGraphicalLoopsFound';
            warning(msgId,DAStudio.message(msgId));
        end

        s=char(9600);
        s1=sprintf('%s %s %s %s',s,s,s,s);
        s2=[s,s,s,s,s];
        if algLoops(i).IsArtificial>0&&algLoops(i).isGraphicalLoop>0
            dat{i,4}=s1;
        else
            dat{i,4}=s2;
        end

        blk=[0,0,0];
        blkclr=dec2hex(round(blk*255),2)';
        blkclr=['#';blkclr(:)]';

        col=getColorFromColorMap(cmap,colorIndex,0,totalLoops);
        col=col(1:3);
%# format color as: #FFFFFF
        clr=dec2hex(round(col*255),2)';clr=['#';clr(:)]';

%# apply formatting to third row first column
        dat{i,4}=strcat(...
        ['<html><font color="',clr,'">'],...
        dat{i,4});
    end


    tooltipStr=DAStudio.message('Simulink:utility:ALoopToolTip');
    set(handles.uitable1,'TooltipString',tooltipStr);


    fig_hdl=handles.figure1;


    set(handles.uitable1,'Data',dat,'CellEditCallBack',{@highlightCallback,handles});
    set(handles.uitable1,'Data',dat,'CellSelectionCallBack',{@focusthisLoopCallback,handles});

    set(fig_hdl,'CloseRequestFcn',{@CloseRequest_Callback,handles});


    set(fig_hdl,'DeleteFcn',{@CloseRequest_Callback,handles});



    systemObj=get_param(mdl,'Object');
    listener=Simulink.listener(systemObj,'CloseEvent',@(src,evnt)ModelClose_Callback(src,evnt,handles));
    set(fig_hdl,'UserData',listener);
end




function Highlightall_Callback(hObject,eventdata,handles)



    t=handles.uitable1;
    algLoops=handles.algLoops;
    totalLoops=handles.totalLoops;

    data=get(t,'Data');

    for i=1:length(algLoops)
        if(data{i,1}==false)
            data{i,1}=true;
            loopId=algLoops(i).Id;

            if algLoops(i).isGraphicalLoop
                algLoops(i).highlight(loopId(2),totalLoops);
            else
                algLoops(i).highlightNoneGraphicalLoop(loopId(2),totalLoops);
            end
        end
    end
    set(t,'Data',data);

end




function Clearall_Callback(hObject,eventdata,handles)



    t=handles.uitable1;
    algLoops=handles.algLoops;

    data=get(t,'Data');

    for i=1:length(algLoops)
        if(data{i,1}==true)
            data{i,1}=false;
            algLoops(i).removehighlight();
        end
    end
    set(t,'Data',data);

end





function CloseRequest(handles)

    t=handles.uitable1;
    algLoops=handles.algLoops;
    mdl=handles.mdl;

    data=get(t,'Data');


    if isvalid(algLoops)
        for i=1:length(algLoops)
            if(data{i,1}==true)
                algLoops(i).removehighlight();
            end
        end
    end


    set(handles.figure1,'DeleteFcn',[]);
    delete(handles.figure1);

    handles.mdlToUIMap.remove(mdl);

end




function CloseRequest_Callback(hObject,eventdata,handles)



    CloseRequest(handles);
end




function Exit_Callback(hObject,eventdata,handles)



    CloseRequest(handles);
end




function ModelClose_Callback(hObject,eventdata,handles)



    if ishghandle(handles.figure1)
        CloseRequest(handles);
    end
end




function highlightCallback(hObject,eventdata,handles)

    algLoops=handles.algLoops;
    totalLoops=handles.totalLoops;

    data=get(hObject,'Data');

    cols=get(hObject,'ColumnFormat');

    mm=eventdata.Indices(1);
    if strcmp(cols(eventdata.Indices(2)),'logical')
        if eventdata.EditData
            data{eventdata.Indices(1),eventdata.Indices(2)}=true;
            highL=true;
        else
            data{eventdata.Indices(1),eventdata.Indices(2)}=false;
            highL=false;
        end
    end

    set(hObject,'Data',data);

    Id=algLoops(mm).Id;

    if highL

        if algLoops(mm).isGraphicalLoop
            algLoops(mm).highlight(Id(2),totalLoops);
        else
            algLoops(mm).highlightNoneGraphicalLoop(Id(2),totalLoops);
        end
    else
        algLoops(mm).removehighlight();
    end
end



























function focusthisLoopCallback(hObject,eventdata,handles)

    algLoops=handles.algLoops;
    cols=get(hObject,'ColumnFormat');
    topModel=handles.mdl;
    t=handles.uitable1;

    if~isempty(eventdata.Indices)&&~isempty(topModel)
        if~strcmp(cols(eventdata.Indices(2)),'logical')
            n=eventdata.Indices(2);

            if n==2
                m=eventdata.Indices(1);


                if~isempty(algLoops(m).VariableBlockHandles)
                    varBlock=algLoops(m).VariableBlockHandles;
                else
                    varBlock=algLoops(m).BlockHandles;
                end



                for i=1:length(varBlock)
                    if ishandle(varBlock(i))
                        blockHandle=varBlock(i);
                        break;
                    end
                end

                try
                    open_system(get(blockHandle,'Parent'),'tab');
                catch
                    open_system(topModel,'tab');
                end


                data=get(t,'Data');
                data{m,1}=~data{m,1};
                set(t,'Data',data);
                data{m,1}=~data{m,1};
                set(t,'Data',data);
            end
        end
    end
end





function color=getColorFromColorMap(cmap,value,min,max)
    [m,~]=size(cmap);
    row=round((value/(max-min))*(m-1))+1;
    color=cmap(row,:);
    color=[color,1];
end



