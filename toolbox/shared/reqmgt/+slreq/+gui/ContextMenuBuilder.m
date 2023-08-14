classdef ContextMenuBuilder<handle





    properties(Access=private)
        view;
    end

    properties(Constant,Hidden)

        ContextMenuTagsAlwaysEnabled={'ReqLink:BaseShowComment','ReqLink:BaseShowImplementationStatus',...
        'ReqLink:BaseShowVerificationStatus','ReqLink:BaseShowChangeInformation','ReqLink:BaseColumnSelector'};
    end

    methods(Static)
        function actionStruct=createAction(item)
            if strcmp(item.name,'empty')
                actionStruct=struct('label',{},'enabled',{},'visible',{},'icon',{}...
                ,'accel',{},'checkable',{},'checked',{},'command',{});
            elseif strcmp(item.name,'separator')
                actionStruct=struct('label','separator','enabled',true,'visible',true,...
                'icon','','accel','','checkable',false,'checked',false,'command','');
            else
                if isfield(item,'enabled')&&strcmp(item.enabled,'on')
                    enabled=true;
                else
                    enabled=false;
                end


                if isfield(item,'visible')&&strcmp(item.visible,'off')
                    visible=false;
                else

                    visible=true;
                end

                if isfield(item,'toggleaction')&&strcmp(item.toggleaction,'on')
                    checkable=true;
                    if strcmp(item.on,'on')
                        checked=true;
                    else
                        checked=false;
                    end
                else
                    checkable=false;
                    checked=false;
                end

                if isfield(item,'accel')
                    accel=item.accel;
                else
                    accel='';
                end
                actionStruct=struct('label',item.name,'enabled',enabled,...
                'visible',visible,'icon','','accel',accel,'checkable',checkable,...
                'checked',checked,'command',item.callback);
            end
        end

        function actionStructs=createActions(menuItem)
            actionStructs=slreq.gui.ContextMenuBuilder.createAction(struct('name','empty'));
            for n=1:length(menuItem)
                for m=1:length(menuItem{n})
                    if isfield(menuItem{n}(m),'items')&&~isempty(menuItem{n}(m).items)
                        subs=slreq.gui.ContextMenuBuilder.createAction(struct('name','empty'));
                        for s=1:length(menuItem{n}(m).items)
                            subs(end+1)=slreq.gui.ContextMenuBuilder.createAction(menuItem{n}(m).items(s));
                        end
                        subAction=slreq.gui.ContextMenuBuilder.createAction(menuItem{n}(m));
                        subAction.command=subs;
                        actionStructs(end+1)=subAction;
                    else
                        actionStructs(end+1)=slreq.gui.ContextMenuBuilder.createAction(menuItem{n}(m));
                    end
                end
                actionStructs(end+1)=slreq.gui.ContextMenuBuilder.createAction(struct('name','separator'));
            end
        end

    end

    methods
        function this=ContextMenuBuilder(caller)
            this.view=slreq.utils.getCallerView(caller,true);
        end

        function items=adjustMenuEnabledStateBySelection(this,items,enabledTagsOnMultiSelection)
            if isempty(this.view)
                return;
            elseif isempty(this.view.getCurrentSelection)


                items=this.disableMenuItems(items,{});
            elseif numel(this.view.getCurrentSelection)>1


                items=this.disableMenuItems(items,enabledTagsOnMultiSelection);
            end
        end
    end

    methods(Access=private)
        function items=disableMenuItems(this,items,enabledTagsOnMultiSelection)
            isCell=iscell(items);
            isStuct=isstruct(items);
            for n=1:length(items)
                if isCell
                    items{n}=this.disableElement(items{n},enabledTagsOnMultiSelection);
                elseif isStuct
                    items(n)=this.disableElement(items(n),enabledTagsOnMultiSelection);
                end
            end
        end
        function s=disableElement(this,s,skipTags)
            for m=1:length(s)
                if isstruct(s(m))
                    if any(strcmp(s(m).tag,skipTags))...
                        ||any(strcmp(s(m).tag,this.ContextMenuTagsAlwaysEnabled))

                    else
                        s(m).enabled='off';
                    end
                    if isfield(s(m),'items')
                        s(m).items=this.disableMenuItems(s(m).items,skipTags);
                    end
                elseif iscell(s)
                    s(m)=this.disableMenuItems(s(m),skipTags);
                end
            end
        end
    end
end

