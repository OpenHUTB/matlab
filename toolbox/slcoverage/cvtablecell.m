function cvtablecell(~,varargin)













    rows=cvprivate('createTableCellInfo',varargin{:});

    dlg=create_dialog(rows);


    figure(dlg);




    function dialog=create_dialog(rows)

        prevPos=[];


        dialogTag='cvtablecell';
        figBuffer=8;
        vertSpace=3;
        labelDelta=10;
        textSize=10;
        figBgColor=[1,1,1]*0.8;

        dialog=findobj(0,'Type','figure','Tag',dialogTag);
        if~isempty(dialog)
            prevPos=get(dialog,'Position');
            close(dialog);
        end
        dialog=figure('NumberTitle','off'...
        ,'Menu','none'...
        ,'Toolbar','none'...
        ,'Tag',dialogTag...
        ,'HandleVisibility','on'...
        ,'Visible','off'...
        ,'Color',figBgColor...
        ,'Resize','off'...
        ,'DeleteFcn',''...
        ,'Units','points'...
        ,'IntegerHandle','off'...
        ,'DefaultUiControlUnits','points'...
        ,'DefaultUiControlHorizontalAlign','left'...
        ,'DefaultUiControlEnable','on'...
        ,'Interruptible','off'...
        ,'BusyAction','cancel'...
        );

        labelProps={...
        'Parent',dialog,...
        'style','text',...
        'HorizontalAlignment','left',...
        'BackgroundColor',figBgColor,...
        'Units','points',...
        'FontWeight','bold',...
        'FontSize',textSize...
        };

        dispProps={...
        'Parent',dialog,...
        'style','text',...
        'HorizontalAlignment','left',...
        'BackgroundColor',figBgColor,...
        'Units','points',...
        'FontWeight','normal',...
        'FontSize',textSize...
        };

        sizeCheck=uicontrol(...
        labelProps{:},...
        'Visible','off'...
        );



        currX=figBuffer;
        currY=figBuffer;


        maxWidths=ones(1,2);
        maxHeights=ones(1,2);
        for idx=1:2
            [widths,heights]=cellfun(@(x)findWH(sizeCheck,x),rows(:,idx));
            maxWidths(idx)=max(widths);
            maxHeights(idx)=max(heights);
        end

        textHeight=max(maxHeights);
        labelWidth=maxWidths(1);
        displWidth=maxWidths(2);
        dispCol=currX+labelWidth+labelDelta;

        for idx=size(rows,1):-1:2

            labelPos=[currX,currY,labelWidth,textHeight];
            dispStringPos=[dispCol,currY,displWidth,textHeight];

            uDIdx=idx-1;
            UD.label(uDIdx)=uicontrol(labelProps{:},...
            'Position',labelPos,...
            'String',cvi.ReportUtils.html_to_str(rows{idx,1}));
            UD.dispStr(uDIdx)=uicontrol(dispProps{:},...
            'Position',dispStringPos,...
            'String',cvi.ReportUtils.html_to_str(rows{idx,2}));

            currY=currY+vertSpace+textHeight;
        end

        totalY=currY-vertSpace+figBuffer;
        totalX=dispCol+max(labelWidth,displWidth)+figBuffer;

        if~isempty(prevPos)
            defaultFigPos=prevPos;
        else
            oldUnits=get(0,'Units');
            set(0,'Units','points');
            defaultFigPos=get(0,'defaultFigurePosition');
            set(0,'Units',oldUnits);
        end
        defaultFigPos(3:4)=[totalX,totalY];

        set(dialog,'Name',cvi.ReportUtils.html_to_str(rows{1,1}),'Position',defaultFigPos,'UserData',UD,'Visible','on');

        function[width,height]=findWH(ui,str)
            set(ui,'String',str);
            txtExtent=get(ui,'Extent');
            width=txtExtent(3);
            height=txtExtent(4);