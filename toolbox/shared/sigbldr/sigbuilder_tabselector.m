function varargout=sigbuilder_tabselector(method,varargin)














    UD=[];
    axesH=[];
    switch(method)
    case 'create'

        figH=varargin{1};
        origin=varargin{2};
        width=varargin{3};
        entryNames=varargin{4};
        activeEntry=varargin{5};
        contextMenuH=varargin{6};

        handleStruct=create_selector(figH,origin,width,entryNames,activeEntry,contextMenuH);
        varargout{1}=handleStruct;

    case 'addentry'

        axesH=varargin{1};
        labelStr=varargin{2};
        UD=get(axesH,'UserData');
        UD=add_entry(UD,axesH,labelStr);
        if nargin>3&&varargin{3}
            UD=activate_entry(UD,axesH,length(UD.tabentries));
        end
        set(axesH,'UserData',UD);


    case 'rename'

        axesH=varargin{1};
        index=varargin{2};
        labelStr=varargin{3};
        UD=get(axesH,'UserData');
        UD=rename_entry(UD,axesH,index,labelStr);
        set(axesH,'UserData',UD);


    case 'removeentry'

        axesH=varargin{1};
        index=varargin{2};
        UD=get(axesH,'UserData');
        UD=remove_entry(UD,axesH,index);
        set(axesH,'UserData',UD);


    case 'movetab'

        axesH=varargin{1};
        oldIdx=varargin{2};
        newIdx=varargin{3};
        UD=get(axesH,'UserData');
        UD=move_tab(UD,axesH,oldIdx,newIdx);
        set(axesH,'UserData',UD);


    case 'mouseAction'

        switch(get(gcbo,'Type'))
        case{'uicontrol'}
            axesH=gcbo;
        otherwise
            error(message('sigbldr_ui:sigbuilder_tabselector:unknownObjectType'));
        end
        UD=get(axesH,'UserData');
        xpos=[];
        action=varargin{1};

        UD=mouse_handler(action,axesH,UD,xpos);


    case 'tab_left'

        axesH=get(gcbo,'UserData');
        UD=get(axesH,'UserData');
        UD=tab_left(UD,axesH);
        set(axesH,'UserData',UD);


    case 'context_menu'

        contextH=get(gcbo,'UIContextMenu');
        panel=get(gcbo,'Parent');
        set(panel,'Units','Pixels');
        set(gcbo,'Units','Pixels');
        position=get(panel,'Position')+get(gcbo,'Position');
        set(contextH,'Position',position(1:2));
        set(contextH,'Visible','on');
        set(panel,'Units','Points');

    case 'tab_right'

        axesH=get(gcbo,'UserData');
        UD=get(axesH,'UserData');
        UD=tab_right(UD,axesH);
        set(axesH,'UserData',UD);


    case 'activate'

        axesH=varargin{1};
        index=varargin{2};
        if nargin>3
            ignoreCB=varargin{3};
        else
            ignoreCB=0;
        end
        UD=get(axesH,'UserData');
        UD=activate_entry(UD,axesH,index,ignoreCB);


    case 'resize'

        axesH=varargin{1};
        deltaWidth=varargin{2};
        UD=get(axesH,'UserData');
        UD=resize(UD,axesH,deltaWidth);
        set(axesH,'UserData',UD);

    case 'touch'
        axesH=varargin{1};
        touch(axesH);

    otherwise
        error(message('sigbldr_ui:sigbuilder_tabselector:unknownMethod'));


    end


    if~isempty(UD)&&~isempty(axesH)
        checkButtonVisiblity(UD,axesH);
    end


    function UD=mouse_handler(action,axesH,UD,~)

        switch(action)
        case 'BD'
            pressedIdx=get(axesH,'Value');
            UD=activate_entry(UD,axesH,pressedIdx,0);

        otherwise,
            error(message('sigbldr_ui:sigbuilder_tabselector:unknownMethod'));
        end

        function UD=tab_left(UD,axesH)


            activeIdx=get(axesH,'Value');
            activeIdx=activeIdx-1;
            if activeIdx<=0



                return;
            end
            UD=activate_entry(UD,axesH,activeIdx,0);
            UD=resize(UD,axesH,0);


            function UD=tab_right(UD,axesH)


                activeIdx=get(axesH,'Value');
                activeIdx=activeIdx+1;
                if activeIdx>length(get(axesH,'String'))


                    return;
                end
                UD=activate_entry(UD,axesH,activeIdx,0);

                UD=resize(UD,axesH,0);

                function UD=resize(UD,axesH,deltaWidth)

                    rightPaneloldPos=get(UD.rightScroll,'Position');
                    set(UD.rightScroll,'Position',rightPaneloldPos+[deltaWidth,0,0,0]);

                    oldPos=get(axesH,'Position');
                    set(axesH,'Position',oldPos+[0,0,deltaWidth,0]);


                    function touch(axesH)


                        pos=get(axesH,'Position');
                        set(axesH,'Position',pos+[1,1,0,0]);
                        set(axesH,'Position',pos);


                        function UD=remove_entry(UD,axesH,index)

                            entryNames=get(axesH,'String');
                            entryNames(index)=[];
                            set(axesH,'String',entryNames);
                            UD.activeIdx=get(axesH,'Value');


                            function UD=move_tab(UD,axesH,oldIdx,newIdx)

                                entryNames=get(axesH,'String');


                                if oldIdx<=1
                                    temp=entryNames(2:end);
                                elseif oldIdx>=length(entryNames)
                                    temp=entryNames(1:end-1);
                                else
                                    temp=[entryNames(1:oldIdx-1);entryNames(oldIdx+1:end);];
                                end


                                if isempty(temp)
                                    return;
                                end



                                if newIdx<=1
                                    entryNames=[entryNames(oldIdx);temp];
                                elseif newIdx>=length(entryNames)
                                    entryNames=[temp;entryNames(oldIdx)];
                                else
                                    entryNames=[temp(1:newIdx-1);entryNames(oldIdx);temp(newIdx:end)];
                                end

                                set(axesH,'String',entryNames);

                                if oldIdx==newIdx
                                    return;
                                end


                                if oldIdx~=UD.activeIdx
                                    UD=activate_entry(UD,axesH,oldIdx,1);
                                end




                                function UD=checkButtonVisiblity(UD,axesH)
                                    lastIdx=length(get(axesH,'String'));
                                    children=[findall(UD.rightScroll,'tag','GroupLeftScroll'),...
                                    findall(UD.rightScroll,'tag','GroupRightScroll')];
                                    if~isempty(children)
                                        leftButton=children(1);
                                        rightButton=children(2);
                                        if UD.activeIdx==1
                                            set(leftButton,'Enable','off');
                                        else
                                            set(leftButton,'Enable','on');
                                        end
                                        if UD.activeIdx==lastIdx
                                            set(rightButton,'Enable','off');
                                        else
                                            set(rightButton,'Enable','on');

                                        end


                                    end


                                    function UD=activate_entry(UD,axesH,pressedIdx,ignoreCB)

                                        if nargin<4
                                            ignoreCB=0;
                                        end


                                        set(axesH,'Value',pressedIdx);
                                        UD.activeIdx=pressedIdx;
                                        set(axesH,'UserData',UD);


                                        figH=get(axesH,'Parent');

                                        if~ignoreCB
                                            sigbuilder('DSChange',figH,[],pressedIdx);
                                        end

                                        function handleStruct=create_selector(figH,origin,width,entryNames,activeIdx,contextMenuH)


                                            buttonWidth=22;
                                            axesButtonDelta=8;



                                            load('sigbuilder_tab_images');
                                            imHeight=length(gtext_bmp);


                                            [axHeightArray,pix2points]=pixels2points(figH,imHeight);
                                            axHeight=axHeightArray(2);

                                            bgColor=get(figH,'Color');

                                            estHeight=18;

                                            UD.leftScroll=uipanel('Parent',figH,...
                                            'Units','Points',...
                                            'BackgroundColor',bgColor,...
                                            'Visible','off');


                                            label=uicontrol('Parent',UD.leftScroll,...
                                            'Units','Points',...
                                            'Style','text',...
                                            'String',getString(message('sigbldr_ui:sigbuilder_tabselector:ActiveGroup')),...
                                            'BackgroundColor',bgColor,...
                                            'FontWeight','bold',...
                                            'HorizontalAlignment','right'...
                                            );
                                            labelExtent=get(label,'Extent');
                                            labelWidth=labelExtent(3);
                                            leftPanelWidth=labelWidth+axesButtonDelta;
                                            set(UD.leftScroll,'Position',[origin(1),origin(2)-1,leftPanelWidth,axHeight+estHeight]);
                                            set(label,'Position',[0,0,labelWidth,axHeight+2]);
                                            set(UD.leftScroll,'Visible','on');


                                            uiCurrX=leftPanelWidth+axesButtonDelta/2;
                                            uiCurrY=origin(2)+4;



                                            axWidth=width-4*axesButtonDelta-(3*buttonWidth)-labelWidth;


                                            axesH=uicontrol('Parent',figH,...
                                            'Units','Points',...
                                            'Position',[uiCurrX,uiCurrY,axWidth,axHeight],...
                                            'Style','popup',...
                                            'String',entryNames,...
                                            'BackgroundColor',bgColor,...
                                            'Callback','sigbuilder_tabselector(''mouseAction'',''BD'');',...
                                            'Enable','on',...
                                            'Visible','on',...
                                            'HorizontalAlignment','left',...
                                            'Tag','SignalBuilderGroupPopup',...
                                            'handlevisibility','callback');


                                            uiCurrX=uiCurrX+axWidth+axesButtonDelta/2;
                                            uiCurrY=origin(2);
                                            rightPanelWidth=3*buttonWidth+3*axesButtonDelta;

                                            UD.rightScroll=uipanel('Parent',figH,...
                                            'Units','Points',...
                                            'Position',[uiCurrX,uiCurrY-1,rightPanelWidth,axHeight+estHeight],...
                                            'BackgroundColor',bgColor,...
                                            'Visible','on');



                                            uiCurrX=axesButtonDelta/2;
                                            uiCurrY=0;
                                            uicontrol('Parent',UD.rightScroll...
                                            ,'Units','Points'...
                                            ,'Position',[uiCurrX,uiCurrY+3,buttonWidth,axHeight]...
                                            ,'Style','pushbutton'...
                                            ,'CData',group_context_png...
                                            ,'Callback','sigbuilder_tabselector(''context_menu'');'...
                                            ,'HandleVisibility','callback'...
                                            ,'BackgroundColor',bgColor...
                                            ,'Enable','on'...
                                            ,'UIContextMenu',contextMenuH...
                                            ,'Tag','GroupContext'...
                                            );
                                            uiCurrX=uiCurrX+buttonWidth+axesButtonDelta/2;
                                            uiCurrY=0;

                                            uicontrol('Parent',UD.rightScroll...
                                            ,'Units','Points'...
                                            ,'Position',[uiCurrX,uiCurrY+3,buttonWidth,axHeight]...
                                            ,'Style','pushbutton'...
                                            ,'UserData',axesH...
                                            ,'FontWeight','bold'...
                                            ,'CData',up_triangle...
                                            ,'Callback','sigbuilder_tabselector(''tab_left'');'...
                                            ,'HandleVisibility','callback'...
                                            ,'Tag','GroupLeftScroll'...
                                            ,'Enable','on'...
                                            );

                                            uiCurrX=uiCurrX+buttonWidth+axesButtonDelta/2;
                                            uiCurrY=0;


                                            uicontrol('Parent',UD.rightScroll...
                                            ,'Units','Points'...
                                            ,'Position',[uiCurrX,uiCurrY+3,buttonWidth,axHeight]...
                                            ,'Style','pushbutton'...
                                            ,'UserData',axesH...
                                            ,'FontWeight','bold'...
                                            ,'CData',down_triangle...
                                            ,'Callback','sigbuilder_tabselector(''tab_right'');'...
                                            ,'HandleVisibility','callback'...
                                            ,'Tag','GroupRightScroll'...
                                            ,'Enable','on'...
                                            );


                                            set(UD.rightScroll,'Visible','on');
                                            handleStruct.axesH=axesH;
                                            handleStruct.leftScroll=UD.leftScroll;
                                            handleStruct.rightScroll=UD.rightScroll;

                                            UD.tabentries=[];

                                            UD.leftMostIdx=1;
                                            UD.activeIdx=activeIdx;
                                            UD.tabBoundaries=[];
                                            UD.pix2points=pix2points;
                                            UD.totalAxesWidth=1;
                                            UD.imBuff=[];
                                            UD.contextMenuH=contextMenuH;

                                            set(axesH,'Visible','on','UserData',UD);

                                            function UD=add_entry(UD,axesH,labelStr)



                                                if iscell(labelStr)
                                                    set(axesH,'String',labelStr);
                                                else

                                                    entryNames=get(axesH,'String');
                                                    entryNames(length(entryNames)+1)={labelStr};
                                                    set(axesH,'String',entryNames);
                                                end


                                                function UD=rename_entry(UD,axesH,tabIdx,labelStr)

                                                    entryNames=get(axesH,'String');
                                                    entryNames(tabIdx)={labelStr};
                                                    set(axesH,'String',entryNames);
                                                    UD=resize(UD,axesH,0);


