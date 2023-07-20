classdef SigSelectorTC<toolpack.AtomicComponent









    properties(GetAccess=public,SetAccess=private)
ItemNames
FullItemNames
ParentHash
ChildrenHash
SelectedIDs
    end
    properties(GetAccess=private,SetAccess=private)
Options
FilterText
Items
RegularExpression
FlatListEnabled
ModelObject
ModelListeners
    end
    events
ItemsChanged
    end
    methods(Access=private)
        sigs=addSelectedFlagsAndIDs(this,insigs);
        sigs=resetSelectedFlags(this,insigs);
        [parenthash,childrenhash]=constructHashTables(this,sigs);
        [itemnames,fullnames]=constructItemNames(this,sigs,hidebusroot);
        items=getSelectionOnModel(this,initial);
        writeSelections(this);
    end
    methods

        function this=SigSelectorTC(opts)
            this=this@toolpack.AtomicComponent();

            this.FilterText='';
            this.Items=[];
            this.RegularExpression=true;
            this.FlatListEnabled=false;

            if~isa(opts,'Simulink.sigselector.Options')
                DAStudio.error('Simulink:sigselector:TCInvalidConstruction');
            else
                this.Options=opts;
            end


            if opts.InteractiveSelection

                try
                    this.ModelObject=get_param(opts.Model,'Object');
                catch Me

                    DAStudio.error('Simulink:sigselector:InteractiveRequiresModel');
                end

                this.ModelListeners(1).Model=this.ModelObject;
                this.ModelListeners(1).Listener=...
                Simulink.listener(this.ModelObject,'SelectionChangeEvent',...
                @(h,ev)updateSelection(this,false));

                mdlrefsup=opts.MdlrefSupport;
                if~strcmp(mdlrefsup,'none')



                    [mdls,blks]=find_mdlrefs(opts.Model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);

                    mdls(strcmp(opts.Model,mdls))=[];
                    for ct=1:numel(mdls)
                        load_system(mdls{ct});
                    end
                    if strcmp(mdlrefsup,'all')
                        for ct=1:numel(mdls)

                            mdlobj=get_param(mdls{ct},'Object');
                            this.ModelListeners(ct+1).Model=mdlobj;
                            this.ModelListeners(ct+1).Listener=...
                            Simulink.listener(mdlobj,'SelectionChangeEvent',...
                            @(h,ev)updateSelection(this,false));
                        end
                    else
                        normalmdls={};
                        for ct=1:numel(blks)
                            if strcmp(get_param(blks{ct},'SimulationMode'),'Normal')
                                normalmdls{end+1}=get_param(blks{ct},'ModelName');%#ok<AGROW>
                            end
                        end
                        normalmdls=unique(normalmdls);
                        for ct=1:numel(normalmdls)

                            mdlobj=get_param(normalmdls{ct},'Object');
                            this.ModelListeners(ct+1).Model=mdlobj;
                            this.ModelListeners(ct+1).Listener=...
                            Simulink.listener(mdlobj,'SelectionChangeEvent',...
                            @(h,ev)updateSelection(this,false));
                        end
                    end
                end

                items=getSelectionOnModel(this,true);

                this.setItems(items);
            end

            update(this);
        end
        function delete(this)

            listeners=this.ModelListeners;
            for ct=1:numel(listeners)
                delete(listeners(ct).Listener);
            end
        end

        function val=getOptions(this)
            val=this.Options;
        end

        function val=getFilterText(this)
            val=this.FilterText;
        end
        function setFilterText(this,val)
            if ischar(val)
                setChangeSetProperty(this,'FilterText',val);
            else
                DAStudio.error('Simulink:sigselector:TCInvalidFilterText');
            end
        end
        function applyFilterText(this,val)
            this.FilterText=val;
        end

        function val=getRegularExpression(this)
            val=this.RegularExpression;
        end
        function setRegularExpression(this,val)
            if islogical(val)
                setChangeSetProperty(this,'RegularExpression',val);
            else
                DAStudio.error('Simulink:sigselector:TCInvalidRegularExpression');
            end
        end

        function val=getFlatList(this)
            val=this.FlatListEnabled;
        end
        function setFlatList(this,val)
            if islogical(val)
                setChangeSetProperty(this,'FlatListEnabled',val);
            else
                DAStudio.error('Simulink:sigselector:TCInvalidFlatListEnabled');
            end
        end

        function val=getItems(this)

            writeSelections(this);
            val=this.Items;
        end
        function setItems(this,val)

            if~isempty(val)&&~iscell(val)
                DAStudio.error('Simulink:sigselector:TCInvalidSignals');
            else
                opts=this.getOptions;

                if opts.HideBusRoot


                    if strcmp(opts.ViewType,'DDG')
                        if~isempty(val)&&~(numel(val)==1&&isa(val{1},'Simulink.sigselector.BusItem'))
                            DAStudio.error('Simulink:sigselector:TCInvalidItemsWithHideBusRootTrue');
                        end
                    end
                else


                    for ct=1:numel(val)
                        if isa(val{ct},'Simulink.sigselector.BusItem')&&isempty(val{ct}.Name)
                            DAStudio.error('Simulink:sigselector:TCInvalidItemsWithHideBusRootFalse');
                        end
                    end
                end

                val=this.addSelectedFlagsAndIDs(val);


                if strcmp(opts.ViewType,'DDG')
                    val=this.resetSelectedFlags(val);
                end
                setChangeSetProperty(this,'Items',val);
            end
        end

        function view=createView(this,varargin)

            opts=this.getOptions;
            if strcmp(opts.ViewType,'DDG')

                view=Simulink.SigSelectorDDGGC(this);
            else

                view=Simulink.sigselector.JavaGC(this);
            end
        end

        function disableModelListeners(this)
            for ct=1:numel(this.ModelListeners)
                this.ModelListeners(ct).Listener.Enabled=false;
            end
        end
        function enableModelListeners(this)
            for ct=1:numel(this.ModelListeners)
                this.ModelListeners(ct).Listener.Enabled=true;
            end
        end
        function bool=isAnyTreeSelection(this)
            bool=~isempty(getSelectedTreeIDs(this));
        end
        function applyTreeSelections(this,selectedids)
            this.SelectedIDs=selectedids;
        end
        function val=getRawItems(this)

            val=this.Items;
        end


        [matchingIDs,treeids,filtitems]=executeFilter(this);
        treeids=getSelectedTreeIDs(this);
    end
    methods(Access=protected)
        function updateSelection(this,initial)
            try
                getSelectionOnModel(this,initial);
            catch Ex
                opts=struct('WindowStyle','modal','Interpreter','none');
                title=getString(message('Simulink:sigselector:UnableToGetHierarchyTitle'));
                switch Ex.identifier
                case 'Simulink:sigselector:InteractiveBusRequirements'
                    msg=getString(message('Simulink:sigselector:UnableToGetHierarchy'));
                case 'Simulink:Bus:EditTimeBusPropFailureOutputPort'
                    msg=sprintf('%s\n%s',Ex.message,Ex.cause{1}.message);
                otherwise
                    msg=Ex.message;
                end
                errordlg(msg,title,opts);
            end
        end
        function props=getIndependentVariables(this)%#ok<MANU>


            props={'FilterText','Items','RegularExpression','FlatListEnabled'};
        end
        function mUpdate(this)

            props=this.getIndependentVariables;
            changeditems=fieldnames(this.ChangeSet);
            for k=1:length(props)
                p=props{k};
                if any(strcmp(p,changeditems))
                    this.(p)=this.ChangeSet.(p);


                    if strcmp(p,'Items')
                        opts=this.getOptions;

                        [this.ItemNames,this.FullItemNames]=...
                        this.constructItemNames(this.Items,opts.HideBusRoot);
                        [this.ParentHash,this.ChildrenHash]=this.constructHashTables(this.Items);
                        if strcmp(opts.ViewType,'DDG')

                            this.SelectedIDs=[];
                        else
                            initSelectedIDs(this);
                        end
                        notify(this,'ItemsChanged');
                    end
                end
            end
        end
    end
    methods(Sealed,Access=protected)
        function setChangeSetProperty(this,varname,varvalue)
            props=this.getIndependentVariables;
            if isempty(props)||~any(strcmp(varname,props))
                ctrlMsgUtils.error('Controllib:toolpack:NotAnIndependentProperty',varname)
            end
            this.ChangeSet.(varname)=varvalue;
        end
    end
end




