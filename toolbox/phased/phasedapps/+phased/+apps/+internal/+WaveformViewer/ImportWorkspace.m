function[waveformName,out]=ImportWorkspace()


    out=[];
    waveformName=[];
    fig=figure('ToolBar','none',...
    'Name',getString(message('phased:apps:waveformapp:importfromwksp')),...
    'MenuBar','none',...
    'NumberTitle','off',...
    'Visible','off',...
    'WindowStyle','modal',...
    'CloseRequestFcn',@(h,e)closeCallback());
    fig.Position(3)=300;
    fig.Position(4)=290;


    workspaceVar=evalin('base','whos');
    k=numel(evalin('base','whos'));
    list=uitable('units','pixels',...
    'Tag','importList',...
    'position',[20,60,250,200],...
    'rowname','numbered');
    OKButton=uicontrol('Style','pushbutton',...
    'Parent',fig,...
    'String',getString(message('phased:apps:waveformapp:Ok')),...
    'tag','okBtn',...
    'Enable','on',...
    'Position',[75,25,60,20],...
    'Callback',@(h,e)Btn_Callback());
    cancelButton=uicontrol('Style','pushbutton',...
    'Parent',fig,...
    'String',getString(message('phased:apps:waveformapp:cancel')),...
    'Enable','on',...
    'tag','cancelBtn',...
    'Position',[150,25,60,20],...
    'Callback',@(h,e)closeCallback());
    count=1;
    for i=1:k
        if(strcmp(workspaceVar(i).class,'phased.RectangularWaveform')...
            ||strcmp(workspaceVar(i).class,'phased.LinearFMWaveform')||strcmp(workspaceVar(i).class,'phased.SteppedFMWaveform')...
            ||strcmp(workspaceVar(i).class,'phased.PhaseCodedWaveform')||strcmp(workspaceVar(i).class,'phased.FMCWWaveform')...
            ||strcmp(workspaceVar(i).class,'phased.MatchedFilter')...
            ||strcmp(workspaceVar(i).class,'phased.StretchProcessor')||strcmp(workspaceVar(i).class,'pulseWaveformLibrary'))...
            ||strcmp(workspaceVar(i).class,'pulseCompressionLibrary')
            list.Data{count,1}=workspaceVar(i).name;
            list.Data{count,2}=false;
            count=count+1;
        end
    end
    list.ColumnName={'Variables','Select'};
    list.ColumnEditable=true;
    if~isempty(list.Data)
        columnwidth=cell(1,count);
        val=cellfun(@(x)numel(x),list.Data);
        columnwidth(:)={max(val(1)*10)};
        if any(val<7)
            columnwidth(:)={80};
        end
        list.ColumnWidth=columnwidth;
        table_extent=get(list,'Extent');
        if~all(table_extent==0)
            if(table_extent(3)<(cancelButton.Position(3)+cancelButton.Position(1)))
                cancelButton.Position(1)=110;
                OKButton.Position(1)=40;
                set(list,'Position',[20,75,table_extent(3)-1,table_extent(4)-1]);
            else
                set(list,'Position',[20,75,table_extent(3)-1,table_extent(4)-1]);
            end
            figure_size=get(fig,'outerposition');
            desired_fig_size=[figure_size(1),figure_size(2),table_extent(3)+85,table_extent(4)+150];
            set(fig,'outerposition',desired_fig_size);
        end
    else
        OKButton.Enable='off';
    end
    uiwait(fig);

    function closeCallback()

        out=[];
        waveformName=[];
        delete(fig);
    end
    function Btn_Callback()

        [row,~]=size(list.Data);
        selectcount=1;
        for i=1:row %#ok<FXUP>
            if list.Data{i,2}==1
                out{selectcount}=evalin('base',sprintf('%s;',list.Data{i,1}));
                waveformName{selectcount}=list.Data{i,1};
                selectcount=selectcount+1;
            end
        end
        uiresume(fig);
    end
    if~isempty(out)
        out=out(~cellfun(@isempty,out));
        waveformName=waveformName(~cellfun(@isempty,waveformName));
    end
    delete(fig);
end