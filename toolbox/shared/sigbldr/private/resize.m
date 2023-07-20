function UD=resize(UD)




    newPos=get(UD.dialog,'Position');

    makeWiderObjs=[UD.hgCtrls.chFrame.top...
    ,UD.hgCtrls.chFrame.bottom...
    ,UD.hgCtrls.tabFrame.top...
    ,UD.hgCtrls.tabFrame.bottom...
    ,UD.hgCtrls.chFrame.topInner...
    ,UD.hgCtrls.chFrame.bottomInner...
    ,UD.hgCtrls.chanListbox...
    ,UD.hgCtrls.status.selFrame.top...
    ,UD.hgCtrls.status.selFrame.bottom];

    if strcmp(get(UD.tlegend.scrollbar,'Enable'),'on')
        makeWiderObjs=[makeWiderObjs,UD.tlegend.scrollbar];
    end

    moveXPosObjs=[UD.hgCtrls.chFrame.right...
    ,UD.hgCtrls.chFrame.rightInner...
    ,UD.hgCtrls.tabFrame.right...
    ,UD.hgCtrls.status.selFrame.right...
    ];

    makeTallerObjs=[UD.hgCtrls.chFrame.left...
    ,UD.hgCtrls.chFrame.right...
    ,UD.hgCtrls.chFrame.leftInner...
    ,UD.hgCtrls.chFrame.rightInner];

    moveYPosObjs=[UD.hgCtrls.tabselect.axesH...
    ,UD.hgCtrls.chFrame.top...
    ,UD.hgCtrls.chFrame.topInner...
    ,UD.hgCtrls.tabselect.leftScroll...
    ,UD.hgCtrls.tabselect.rightScroll...
    ,UD.hgCtrls.tabFrame.top...
    ,UD.hgCtrls.tabFrame.bottom...
    ,UD.hgCtrls.tabFrame.left...
    ,UD.hgCtrls.tabFrame.right];


    if~isfield(UD,'minExtent')||isempty(UD.minExtent)
        allPos=get(makeWiderObjs,'Position');
        allPos=cat(1,allPos{:});
        minAdjWidth=min(allPos(:,3));
        minWidth=UD.current.figPos(3)-minAdjWidth;
        minHeight=UD.current.figPos(4)-UD.current.axesExtent(4);
        UD.minExtent=[minWidth,minHeight];
    end

    minWidth=UD.minExtent(1)+5;
    minHeight=(UD.minExtent(2)+...
    UD.geomConst.axesOffset(2)+...
    (UD.numAxes-1)*UD.geomConst.axesVdelta)+...
    UD.geomConst.scrollHeight;

    if newPos(3)<minWidth||newPos(4)<minHeight
        if isfield(UD,'tooSmall')&&~isempty(UD.tooSmall)
            return;
        end

        UD.allChildren=findobj(UD.dialog,'Visible','on');
        UD.allChildren=UD.allChildren(UD.allChildren~=UD.dialog);


        allTypes=get(UD.allChildren,'Type');
        allMenus=UD.allChildren(strcmp(allTypes,'uimenu'));
        allMenusEnableStates=get(allMenus,'Enable');
        removeDisabled=strcmp(allMenusEnableStates,'off');
        allMenus(removeDisabled)=[];
        UD.disabledMenus=allMenus;

        removeIdx=strcmp(allTypes,'uimenu')|strcmp(allTypes,'uipushtool')|strcmp(allTypes,'uitoggletool');
        UD.allChildren(removeIdx)=[];
        set(UD.disabledMenus,'Enable','off');
        set(UD.allChildren,'Visible','off');
        UD.tooSmall=uicontrol('Parent',UD.dialog...
        ,'Style','Text'...
        ,'Visible','off'...
        ,'String',getString(message('sigbldr_ui:resize:TooSmallWindow'))...
        );
        ext=get(UD.tooSmall,'Extent');
        set(UD.tooSmall,'Position',[0.5*(newPos(3:4)-ext(3:4)),ext(3:4)],'Visible','on');
        return;
    end

    if isfield(UD,'tooSmall')&&~isempty(UD.tooSmall)
        if ishghandle(UD.tooSmall,'uicontrol')
            delete(UD.tooSmall);
        end
        keepIdx=ishghandle(UD.allChildren);
        actChildren=UD.allChildren(keepIdx);

        set(UD.disabledMenus,'Enable','on');
        set(actChildren,'Visible','on');
        UD.tooSmall=[];
    end


    delta=newPos-UD.current.figPos;
    UD.current.axesExtent=UD.current.axesExtent+[0,0,delta(3:4)];

    if UD.numAxes>0&&~ishghandle(UD.axes(1).handle,'axes')
        return;
    end


    for i=1:UD.numAxes
        pos=calc_new_axes_position(UD.current.axesExtent,UD.geomConst,UD.numAxes,i);
        set(UD.axes(i).handle,'Position',pos);
    end

    adjust_axes(makeWiderObjs,delta(3),'width');
    adjust_axes(moveXPosObjs,delta(3),'x_coord');
    adjust_axes(moveYPosObjs,delta(4),'y_coord');
    adjust_axes(makeTallerObjs,delta(4),'height');
    if isfield(UD,'axes')
        update_all_axes_label(UD.axes);
    end
    sigbuilder_tabselector('resize',UD.hgCtrls.tabselect.axesH,delta(3));

    if~isempty(UD.verify.hg.component)&&strcmp(get(UD.verify.hg.componentContainer,'visible'),'on')
        pos=find_verify_position(UD.dialog,UD.current.axesExtent,UD.geomConst.figBuffer,UD.current.verifyWidth,UD.current.isVerificationVisible);
        set(UD.verify.hg.componentContainer,'Position',pos);
    end

    UD.current.figPos=newPos;
