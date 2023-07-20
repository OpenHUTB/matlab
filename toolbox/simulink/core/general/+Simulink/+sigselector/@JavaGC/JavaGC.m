




classdef JavaGC<handle



    properties(Access=private)
TCPeer
APIListeners
GUIPeer
GUIListeners
        PreferredSize=[200,200];
JavaItems
    end
    events
TreeChangeEvent
UserInteractionEvent
KeyboardEvent
    end
    methods

        function this=JavaGC(tc)
            this.TCPeer=tc;
            opts=tc.getOptions;
            hidebusroot=opts.HideBusRoot;
            this.setPeer(javaObjectEDT('com.mathworks.toolbox.simulink.sigselector.SignalSelectorDialog',...
            opts.RootName,...
            hidebusroot,...
            opts.FilterVisible,...
            opts.TreeMultipleSelection,...
            opts.InteractiveSelection));


            cb=this.getPeer.getSelectionCallback();
            addCallbackListener(this,cb,{@LocalApplySelection,this});

            cb=this.getPeer.getFilterCallback();
            addCallbackListener(this,cb,{@LocalApplyFilter,this});

            cb=this.getPeer.getRegExpCallback();
            addCallbackListener(this,cb,{@LocalApplyRegExp,this});

            cb=this.getPeer.getFlatListCallback();
            addCallbackListener(this,cb,{@LocalApplyFlatList,this});


            cb=this.getPeer.getFilterDeletedWithBackspaceCallback();
            addCallbackListener(this,cb,{@LocalClearFilterWithoutUpdate,this});


            cb=this.getPeer.getKeyPressedCallback();
            addCallbackListener(this,cb,{@LocalKeyPressed,this});

            M(1)=addlistener(this.TCPeer,'ComponentChanged',@this.vUpdate);
            M(2)=addlistener(this.TCPeer,'ObjectBeingDestroyed',@(x,y)delete(this));
            M(3)=addlistener(this.TCPeer,'ItemsChanged',@(es,ed)updateItems(this,hidebusroot,es));
            this.APIListeners=M;

            updateItems(this,hidebusroot,tc);
            vUpdate(this);
        end
        function setPeer(this,peer)
            this.GUIPeer=peer;
        end
        function peer=getPeer(this)
            peer=this.GUIPeer;
        end
        function pnl=getPanel(this)
            pnl=this.GUIPeer;
        end
        function vUpdate(this,varargin)

            peer=this.getPeer;
            tc=this.TCPeer;
            opts=tc.getOptions();

            previoussel=tc.getSelectedTreeIDs();

            [matchingids,~,filtitems]=tc.executeFilter();

            treeitems=[];
            listitems=[];

            if tc.getFlatList()

                listitems=LocalCreateJavaListItems(filtitems,matchingids,tc.FullItemNames);
            else

                treeitems=LocalCreateJavaTreeItems(filtitems,opts.HideBusRoot);
            end

            peer.update(this.JavaItems,tc.getFilterText,treeitems,listitems,...
            tc.getRegularExpression,tc.getFlatList,previoussel);

            eventdata=Simulink.sigselector.JavaSelectEvent(this.TCPeer);
            notify(this,'TreeChangeEvent',eventdata);
        end
        function addCallbackListener(this,cb,fcn)
            lsnr=handle.listener(handle(cb),'delayed',{@cbBridge,fcn});
            this.GUIListeners=[this.GUIListeners;lsnr];
        end
        function selectIDs(this,ids)
            peer=this.getPeer;
            actualsel=peer.selectIDs(ids);
            this.TCPeer.applyTreeSelections(actualsel);

            eventdata=Simulink.sigselector.JavaSelectEvent(this.TCPeer);
            notify(this,'TreeChangeEvent',eventdata);
        end
    end
    methods(Access=private)
        function updateItems(this,hidebusroot,es)
            this.JavaItems=LocalCreateJavaTreeItems(es.getRawItems(),hidebusroot);
        end
    end
end



function cbBridge(es,ed,fcn)
    feval(fcn{1},java(es),ed.JavaEvent,fcn{2:end});
end

function LocalApplySelection(~,selectedids,this)


    this.TCPeer.applyTreeSelections(selectedids);

    eventdata=Simulink.sigselector.JavaSelectEvent(this.TCPeer);
    notify(this,'TreeChangeEvent',eventdata);

    eventdata=Simulink.sigselector.JavaSelectEvent(this.TCPeer);
    notify(this,'UserInteractionEvent',eventdata);
end

function LocalApplyFilter(~,filterquery,this)
    tc=this.TCPeer;
    peer=this.getPeer;
    if isempty(filterquery)
        peer.clearFilter(tc.getSelectedTreeIDs());
        return;
    end
    opts=tc.getOptions;
    tc.applyFilterText(filterquery);

    previoussel=tc.getSelectedTreeIDs();

    [matchingids,~,filtitems]=tc.executeFilter();
    treeitems=[];
    listitems=[];

    if tc.getFlatList()

        listitems=LocalCreateJavaListItems(filtitems,matchingids,tc.FullItemNames);
    else

        treeitems=LocalCreateJavaTreeItems(filtitems,opts.HideBusRoot);
    end
    peer.filter(treeitems,listitems,previoussel);

    eventdata=Simulink.sigselector.JavaSelectEvent(this.TCPeer);
    notify(this,'UserInteractionEvent',eventdata);
end

function LocalApplyRegExp(~,isregexp,this)
    this.TCPeer.setRegularExpression(isregexp);
    this.TCPeer.update();

    eventdata=Simulink.sigselector.JavaSelectEvent(this.TCPeer);
    notify(this,'UserInteractionEvent',eventdata);
end

function LocalApplyFlatList(~,isflatlist,this)
    this.TCPeer.setFlatList(isflatlist);
    this.TCPeer.update();

    eventdata=Simulink.sigselector.JavaSelectEvent(this.TCPeer);
    notify(this,'UserInteractionEvent',eventdata);
end

function LocalClearFilterWithoutUpdate(~,~,this)
    peer=this.getPeer;
    tc=this.TCPeer;
    tc.applyFilterText('');

    peer.clearFilter(tc.getSelectedTreeIDs());

    eventdata=Simulink.sigselector.JavaSelectEvent(this.TCPeer);
    notify(this,'UserInteractionEvent',eventdata);
end

function LocalKeyPressed(~,ed,this)
    eventdata=Simulink.sigselector.KeyboardEventData(ed);
    notify(this,'KeyboardEvent',eventdata);
end





function listitems=LocalCreateJavaListItems(sigs,matchingids,fullnames)

    if isempty(sigs)||isempty(matchingids)
        listitems=[];
        return;
    end

    listitems=javaArray('com.mathworks.toolbox.simulink.sigselector.ListItem',numel(matchingids));
    listindex=1;
    for ct=1:numel(sigs)
        if isa(sigs{ct},'Simulink.sigselector.BusItem')

            for ctb=1:numel(sigs{ct}.Hierarchy)

                id=sigs{ct}.Hierarchy(ctb).TreeID;
                if any(id==matchingids)
                    listitems(listindex)=javaObject('com.mathworks.toolbox.simulink.sigselector.ListItem',...
                    fullnames(id),id,javax.swing.ImageIcon(sigs{ct}.Hierarchy(ctb).Icon));
                    listindex=listindex+1;
                end
                [listitems,listindex]=LocalProcessBusForList(listitems,sigs{ct}.Hierarchy(ctb),listindex,matchingids,fullnames);
            end
        else

            id=sigs{ct}.TreeID;
            if any(id==matchingids)

                listitems(listindex)=javaObject('com.mathworks.toolbox.simulink.sigselector.ListItem',...
                fullnames(id),id,javax.swing.ImageIcon(sigs{ct}.Icon));
                listindex=listindex+1;
            end
        end
    end
end

function[listitems,index]=LocalProcessBusForList(listitems,bushier,index,matchingids,fullnames)
    if isempty(bushier.Children)
        return
    end
    for ct=1:numel(bushier.Children)
        if any(bushier.Children(ct).TreeID==matchingids)
            id=bushier.Children(ct).TreeID;
            listitems(index)=javaObject('com.mathworks.toolbox.simulink.sigselector.ListItem',...
            fullnames(id),id,javax.swing.ImageIcon(bushier.Children(ct).Icon));
            index=index+1;
        end
        [listitems,index]=LocalProcessBusForList(listitems,bushier.Children(ct),index,matchingids,fullnames);
    end
end

function treeitems=LocalCreateJavaTreeItems(sigs,hidebusroot)

    if isempty(sigs)
        treeitems=[];
        return;
    end

    treeitems=javaArray('com.mathworks.toolbox.simulink.sigselector.AbstractItem',numel(sigs));
    for ct=1:numel(sigs)
        if strcmp(class(sigs{ct}),'Simulink.sigselector.BusItem')
            thisitem=javaObject('com.mathworks.toolbox.simulink.sigselector.BusItem');
            thisitem.Name=sigs{ct}.Name;

            thisitem.Hierarchy=javaArray('com.mathworks.toolbox.simulink.sigselector.BusHierarchy',numel(sigs{ct}.Hierarchy));
            for ctb=1:numel(sigs{ct}.Hierarchy)
                thisitem.Hierarchy(ctb)=LocalCreateBusHierarchy(sigs{ct}.Hierarchy(ctb));


                if~hidebusroot
                    thisitem.Hierarchy(ctb).SignalName=thisitem.Name;
                end
            end

            treeitems(ct)=thisitem;
        else
            treeitems(ct)=javaObject('com.mathworks.toolbox.simulink.sigselector.SignalItem',...
            sigs{ct}.Name,sigs{ct}.TreeID,javax.swing.ImageIcon(sigs{ct}.Icon));
        end

    end
end

function hierarchy=LocalCreateBusHierarchy(bushier)

    hierarchy=javaObject('com.mathworks.toolbox.simulink.sigselector.BusHierarchy',...
    bushier.SignalName,bushier.TreeID,javax.swing.ImageIcon(bushier.Icon));

    if~isempty(bushier.Children)
        hierarchy.Children=javaArray('com.mathworks.toolbox.simulink.sigselector.BusHierarchy',numel(bushier.Children));
        for ctc=1:numel(bushier.Children)
            hierarchy.Children(ctc)=LocalCreateBusHierarchy(bushier.Children(ctc));

            hierarchy.Children(ctc).Parent=hierarchy;
        end
    end
end


