classdef ConnectorsSource<handle




    properties
        mModelName;
        mTopModelName;
        mUDD;
        mTabs;
        mComponentName;
        mComponent;
        mResolvedRows;






        isHierarchy;
        mPropertyList;
        studio;
        type='sourceObj';
        currentSelection;

        mConnectorData;

    end

    methods
        function this=ConnectorsSource(currentModelName,topMdlName,ssComp,studio)

            this.mComponent=ssComp;
            ssComp.setConfig('{"hidecolumns":false, "enablemultiselect":false}');
            this.studio=studio;
            this.mPropertyList={'',DAStudio.message('Simulink:studio:GeneralConnectors'),'Color'};


            ssComp.setColumns(this.mPropertyList,'','',false);
            this.mComponent.setConfig(['{"columns": {"name": "','','", "minsize": 25, "maxsize": 25}}']);

            this.mComponent.setConfig(['{"columns": {"name": "',DAStudio.message('Simulink:studio:GeneralConnectors')...
            ,'", "minsize": 170, "maxsize": 170}}']);

            this.isHierarchy=false;
            ssComp.enableHierarchicalView(false);


            this.mModelName=currentModelName;
            this.mTopModelName=topMdlName;
            this.mComponentName=sprintf('GLUE2:SpreadSheet/%s',ssComp.getName);

            this.currentSelection=this;
            this.mConnectorData=[];

            this.mComponent.setTitleViewSource(this);
            this.mComponent.onHelpClicked=@(ss_src)Simulink.STOSpreadSheet.SortedOrder.SortedOrderSource.handleHelpClicked(ss_src,this);



            connectorSet{1}=getConnectorInfo(this,...
            DAStudio.message('Simulink:studio:FunctionConnectors'),[0.6392,0.8118,0.8196]);
            connectorSet{2}=getConnectorInfo(this,...
            DAStudio.message('Simulink:studio:StateConnectors'),[0.7843,0.7490,0.9059]);
            connectorSet{3}=getConnectorInfo(this,...
            DAStudio.message('Simulink:studio:ParameterConnectors'),[0.8,0.8,0]);
            connectorSet{4}=getConnectorInfo(this,...
            DAStudio.message('Simulink:studio:DataStoreConnectors'),[0.9529,0.5686,0.5686]);
            connectorSet{5}=getConnectorInfo(this,...
            DAStudio.message('Simulink:studio:ScheduleConnectors'),[0,0.5,0.5]);



            for count=1:length(connectorSet)
                currentConnectorNode=Simulink.STOSpreadSheet.Connectors.connectorNode(this,this.mModelName,connectorSet{count});
                this.mConnectorData=[this.mConnectorData,currentConnectorNode];
            end


            this.mComponent.onCloseClicked=@(comp)Simulink.STOSpreadSheet.Connectors.ConnectorsSource.onCloseClicked(comp);
            ssComp.setComponentUserData(this);
            this.mComponent.update();

        end


        function this=update(this,currentModelName,topMdlName,ssComp,studio)
            len=length(this.mConnectorData);
            for index=1:len
                this.mConnectorData(index).mModelName=currentModelName;
                this.mConnectorData(index).update();
            end
            this.mComponent.update();
        end





        function b=isHierarchical(this)
            b=this.isHierarchy;
        end

        function children=getChildren(this,~)
            children=this.mConnectorData;
        end

        function children=getHierarchicalChildren(this)
            children=this.mConnectorData;
        end


        function retVal=resolveSourceSelection(obj,selections,~,~)
            retVal={};
        end




        function dlgStruct=getDialogSchema(obj,~)

            maxItemsInPanel=12;


            helpText.Name="Check expected connectors to display corresponding connections.";

            helpText.Bold=false;
            helpText.Type='text';
            helpText.RowSpan=[1,1];
            helpText.WordWrap=true;
            helpText.ColSpan=[1,maxItemsInPanel];

            helpTextPane.Type='panel';
            helpTextPane.Tag='TaskHelpMessage';
            helpTextPane.Items={helpText};

            helpTextPane.ColSpan=[1,maxItemsInPanel-1];
            helpTextPane.RowSpan=[1,1];
            helpTextPane.Visible=true;

            titlePanel.Type='panel';
            titlePanel.Items={helpTextPane};
            titlePanel.LayoutGrid=[5,maxItemsInPanel];
            titlePanel.ColStretch=[0,0,0,1,0,0,0,0,0,0,1,0];

            titlePanel.RowSpan=[1,1];
            titlePanel.ColSpan=[1,1];

            dlgStruct.LayoutGrid=[1,1];
            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={titlePanel};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};

        end

    end

    methods(Static)


        function handleClick(comp,sel,prop)
            Simulink.STOSpreadSheet.SortedOrder.SortedOrderSource.handleSelectionChange(comp,sel);
        end




        function out=getPropertySchema(this)
            out=this;
        end



        function handleHelpClicked(~,obj)
            helpview(fullfile(docroot,'simulink','helptargets.map'),'controlling_and_displaying_the_sorted_order');
        end



        function onCloseClicked(comp)
            sel=comp.getComponentUserData;

            if(isequal(sel.type,'sourceObj'))
                sourceObj=sel;
            else
                sourceObj=sel.sourceObj;
            end
            set_param(sourceObj.mTopModelName,'GeneralConnectorDisplay','off');

        end

    end

    methods

        function handleRefresh(obj)
            st=obj.mComponent;
            st.update();
        end

    end

    methods(Access=protected)

        function connectorData=getConnectorInfo(~,name,rgb)
            connectorData.name=name;
            connectorData.rgb=rgb;
        end
    end

end
