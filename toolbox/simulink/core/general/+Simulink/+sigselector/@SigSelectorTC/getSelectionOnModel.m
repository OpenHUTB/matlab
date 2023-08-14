function items=getSelectionOnModel(this,initial)










    curports=LocalGetCurrentPorts();

    items=[];

    if isempty(curports)

        nothingtodo=true;
    else

        model=bdroot(get_param(curports(1),'Parent'));
        nothingtodo=~LocalIsSelectionInHierarchy(model,LocalGetModels(this));



        Simulink.BusHierarchyViewerWindowMgr.updateCurrentPorts(model,curports);
    end

    if~nothingtodo
        opts=this.getOptions;
        for ct=numel(curports):-1:1
            curport=curports(ct);

            source.Block=get_param(curport,'Parent');
            source.PortNumber=get_param(curport,'PortNumber');
            source.SignalName=get_param(curport,'Name');
            source.PortType='outport';

            if strcmp(opts.BusSupport,'wholeonly')


                items{ct}=LocalCreateSignalItem(source);
            else




                model=get_param(bdroot(source.Block),'Object');
                if any(strcmpi(get(model,'StrictBusMsg'),{'none','warning'}))
                    DAStudio.error('Simulink:sigselector:InteractiveBusRequirements');
                end
                try
                    businfo=get_param(curport,'SignalHierarchy');
                catch Ex
                    msg=message('Simulink:Bus:EditTimeBusPropFailureOutputPort',...
                    source.PortNumber,source.Block);
                    err=MSLException(msg);
                    err=addCause(err,Ex);
                    err.throwAsCaller();
                end

                isbus=~isempty(businfo)&&~isempty(businfo.Children);
                if isbus
                    if strcmp(opts.BusSupport,'none')


                        items{ct}=[];
                    else

                        items{ct}=Simulink.sigselector.BusItem;
                        items{ct}.Source=source;
                        items{ct}=setNameFromSource(items{ct});
                        items{ct}.Hierarchy=businfo;
                    end
                else

                    items{ct}=LocalCreateSignalItem(source);
                end
            end
        end

        items(cellfun(@isempty,items))=[];
    end


    if(numel(items)>0)&&strcmp(opts.ViewType,'Java')&&opts.AutoSelect
        for ct=numel(items):-1:1
            if isa(items{ct},'Simulink.sigselector.SignalItem')
                items{ct}.Selected=true;
            else

                for cth=1:numel(items{ct}.Hierarchy)
                    items{ct}.Hierarchy(cth).Selected=true;
                end
            end
        end
    end


    if~initial

        opts=this.getOptions;
        if(numel(items)==1)&&opts.HideBusRoot&&strcmp(opts.ViewType,'Java')&&isa(items{1},'Simulink.sigselector.BusItem')
            items{1}.Name='';
            items{1}.Hierarchy=items{1}.Hierarchy.Children;
        end

        mergeditems=LocalMergeItems(items,getItems(this));
        this.setItems(mergeditems);
        this.update;
    end
end

function mergeditems=LocalMergeItems(items,olditems)


    newitems={};
    for ct=1:numel(items)
        found=false;
        for ctold=1:numel(olditems)
            if LocalIsSameItem(items{ct},olditems{ctold})
                found=true;
                break;
            end

        end
        if~found
            newitems{end+1}=items{ct};
        end
    end

    ind=[];
    for ctold=1:numel(olditems)
        found=false;
        for ct=1:numel(items)
            if LocalIsSameItem(items{ct},olditems{ctold})
                found=true;
                break;
            end
        end
        if found
            ind(end+1)=ctold;
        end
    end
    if isempty(ind)
        mergeditems=items;
    else
        items2keep=olditems(ind);
        if isempty(newitems)
            mergeditems=items2keep;
        else
            mergeditems=vertcat(newitems(:),items2keep(:));
        end
    end
end
function bool=LocalIsSameItem(item1,item2)
    bool=false;
    if~strcmp(class(item1),class(item2))
        return;
    end
    if~strcmp(item1.Source.Block,item2.Source.Block)
        return;
    end
    if item1.Source.PortNumber~=item2.Source.PortNumber
        return;
    end
    bool=true;
end

function item=LocalCreateSignalItem(source)

    item=Simulink.sigselector.SignalItem;
    item.Source=source;

    item=setNameFromSource(item);
end

function allmodels=LocalGetModels(this)
    allmodels=[];
    for ct=numel(this.ModelListeners):-1:1
        allmodels{ct}=get(this.ModelListeners(ct).Model,'Name');
    end
end

function bool=LocalIsSelectionInHierarchy(thismodel,allmodels)
    bool=any(strcmp(thismodel,allmodels));
end

function curport=LocalGetCurrentPorts()
    lines=find_system(gcs,'findAll','on','FollowLinks','on','LookUnderMasks','on','SearchDepth',1,'type','line','selected','on');
    curport=get(lines,'SrcPortHandle');
    if iscell(curport)
        curport=unique(cell2mat(curport));
    end

    curport=curport(ishandle(curport));

    curport(strcmp(get(curport,'PortType'),'connection'))=[];
end


