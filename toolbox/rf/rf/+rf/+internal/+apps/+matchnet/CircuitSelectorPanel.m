classdef CircuitSelectorPanel<matlab.ui.internal.FigurePanel




    properties(Access=public)
        myGrid matlab.ui.container.GridLayout
        myCircuitTree matlab.ui.container.Tree

        ImpedanceGrid matlab.ui.container.GridLayout
        SourceLabel matlab.ui.control.Label
        LoadLabel matlab.ui.control.Label
    end

    events
SelectedCircuitsChanged
SelectedCircuitsChangedView
    end

    methods(Access=public)
        function this=CircuitSelectorPanel(varargin)
            this@matlab.ui.internal.FigurePanel(varargin{:});

            this.myGrid=uigridlayout(this.Figure,[2,1],'RowHeight',{'1x','fit'});


            this.myCircuitTree=uitree(this.myGrid,'Multiselect','on',...
            'Tooltip',...
            getString(message('rf:matchingnetworkgenerator:UITreeSelected')),...
            'SelectionChangedFcn',...
            @(h,e)this.selectionChangedCBK_internal);
            this.myCircuitTree.Layout.Row=1;
        end
    end


    methods(Access=public)

        function newNetworksAvailable(this,evtdata)

            this.addNewNetworks(evtdata.data.CircuitGroupName,...
            evtdata.data.CircuitNames,evtdata.data.Performance);
        end

        function selectionChangedCBK_internal(this)
            nodeList=this.myCircuitTree.SelectedNodes;


            leafList=nodeList(arrayfun(@(node)(isempty(node.Children)),nodeList));
            if(isempty(leafList))
                cktNames={};
            else
                cktNames={leafList.Text};
            end
            data.CircuitNames=cktNames;
            data.Busy=true;
            data.AnyUserCreated=any(arrayfun(@(x)strcmp(x.Parent.Text,...
            'User-Created Circuits'),leafList));
            this.notify('SelectedCircuitsChangedView',rf.internal.apps.matchnet.ArbitraryEventData(data));
            this.notify('SelectedCircuitsChanged',rf.internal.apps.matchnet.ArbitraryEventData(data));
            data.Busy=false;
            this.notify('SelectedCircuitsChangedView',rf.internal.apps.matchnet.ArbitraryEventData(data));
        end

        function impedanceDisplay(this,sourcetext,loadtext)
            this.ImpedanceGrid=uigridlayout(this.myGrid,[2,1]);
            this.ImpedanceGrid.Layout.Row=2;

            this.SourceLabel=uilabel(this.ImpedanceGrid,'Text',...
            replace(sourcetext(1:end-2),'Zsource','Source Impedance'));
            this.LoadLabel=uilabel(this.ImpedanceGrid,'Text',...
            replace(loadtext,'Zload','Load Impedance'));
        end
    end


    methods(Access=protected)



        function addNewNetworks(this,topNodeName,names,performance)
            parentNode=[];
            if(~isempty(this.myCircuitTree.Children))
                parentNode=this.myCircuitTree.Children(strcmp(topNodeName,{this.myCircuitTree.Children.Text}));
            end
            if(isempty(parentNode))
                parentNode=uitreenode(this.myCircuitTree,'Text',topNodeName);
                toSelect=parentNode;
            else
                toSelect=arrayfun(@(x)x.Text,...
                this.myCircuitTree.SelectedNodes,'UniformOutput',false);
                delete(parentNode.Children);
            end
            layer=cellfun(@(x)~isempty(x),performance);
            IconRoot=fullfile(matlabroot,...
            'toolbox','rf','rf','+rf','+internal','+apps','+matchnet','Resources');
            StatusIcon=repmat({fullfile(IconRoot,'pass.png')},length(names),1);
            StatusIcon(layer)={fullfile(IconRoot,'fail.png')};

            for j=1:length(names)
                uitreenode(parentNode,'Text',names{j},'Icon',StatusIcon{j});
            end

            expand(this.myCircuitTree)

            if isa(toSelect,'matlab.ui.container.TreeNode')

            else
                allNodes=arrayfun(@(x)x.Text,parentNode.Children,...
                'UniformOutput',false);
                [~,index]=intersect(allNodes,toSelect);
                if~isempty(index)
                    this.myCircuitTree.SelectedNodes=parentNode.Children(index);
                end
            end
            selectionChangedCBK_internal(this)
        end
    end
end
