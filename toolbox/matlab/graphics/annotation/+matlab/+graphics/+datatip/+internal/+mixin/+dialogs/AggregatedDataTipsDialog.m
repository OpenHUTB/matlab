classdef AggregatedDataTipsDialog<handle






    properties(Access=?tDataTip)
        AppFigure matlab.ui.Figure
        RightArrowButton matlab.ui.control.Button
        LeftArrowButton matlab.ui.control.Button
Available
        OKButton matlab.ui.control.Button
        CancelButton matlab.ui.control.Button
Selected
        AvailableColumnsLabel matlab.ui.control.Label
        SelectedColumnsLabel matlab.ui.control.Label
        UpButton matlab.ui.control.Button
        DownButton matlab.ui.control.Button
ParentFigure
ParentChart
        CurrentDataTipConfiguration=string.empty(0,2)
        AvailableVarOptions=string.empty(0,1)
    end

    properties(Access=?tDataTip,Constant)
        DIALOG_WIDTH=438
        DIALOG_HEIGHT=292
    end

    methods(Hidden)

        function delete(this)
            delete(this.AppFigure);
        end



        function updateOptions(this)

            delete(this.Selected.Children);
            delete(this.Available.Children);
            this.AvailableVarOptions=string.empty(0,1);


            [selectedVariables,selectedMethods,...
            unSelectedVariables,defaultAggregationMethods,...
            tableDimensionName,numericVarNames,availableOptions]=this.ParentChart.getOptionsToShow();

            this.CurrentDataTipConfiguration=this.ParentChart.getConfiguration();


            for i=1:numel(selectedVariables)
                uitreenode(this.Selected,...
                'Text',getTranslatedDataTipLabel(selectedVariables{i},selectedMethods{i}),...
                'Tag',selectedVariables{i},...
                'NodeData',[]);
            end
            if~isempty(this.Selected.Children)
                this.Selected.SelectedNodes=this.Selected.Children(1);
            end


            for i=1:numel(availableOptions)
                avOption=availableOptions(i);
                if strcmp(avOption,tableDimensionName)
                    if any(contains(unSelectedVariables,tableDimensionName))
                        translatedStr=matlab.graphics.datatip.internal.mixin.AggregatedDataTipMixin.getStringFromMessageCatalog('Count');
                        c1=uitreenode(this.Available,'Text',tableDimensionName,...
                        'NodeData',[]);
                        uitreenode(c1,'Text',translatedStr,'Tag','count','NodeData',[]);
                        this.AvailableVarOptions(end+1,1)=tableDimensionName;
                    end
                else
                    optionExists=ismember(selectedVariables,avOption);
                    sMethods=selectedMethods(optionExists);
                    aggMethods=setdiff(defaultAggregationMethods,sMethods);
                    if isempty(sMethods)||(~any(strcmp(sMethods,"none"))&&~isempty(aggMethods))
                        c1=uitreenode(this.Available,'Text',avOption,'NodeData',[]);
                        this.AvailableVarOptions(end+1,1)=avOption;

                        if any(contains(numericVarNames,avOption))
                            for num=1:numel(aggMethods)
                                translatedStr=matlab.graphics.datatip.internal.mixin.AggregatedDataTipMixin.getStringFromMessageCatalog(aggMethods{num});
                                uitreenode(c1,'Text',translatedStr,'Tag',aggMethods{num},'NodeData',[]);
                            end
                        end
                    end
                end
            end
        end
    end

    methods(Access=?matlab.graphics.datatip.internal.mixin.AggregatedDataTipMixin)
        function this=AggregatedDataTipsDialog(parentChart)
            this.ParentChart=parentChart;
            this.ParentFigure=ancestor(parentChart,'figure');

            this.createComponents();

            addlistener(this.ParentFigure,'ObjectBeingDestroyed',@(e,d)this.delete());
        end







        function close(this)
            set(this.AppFigure,'Visible','off');
        end


        function bringToFront(this)
            set(this.AppFigure,'Visible','on');
        end
    end

    methods(Access=private)



        function dialogPos=getDialogPosition(this)
            figPos=getpixelposition(this.ParentFigure);
            dialogPos=[figPos(1)+figPos(3)+5,figPos(2),this.DIALOG_WIDTH,this.DIALOG_HEIGHT];
            screenSize=get(0,'ScreenSize');
            if strcmpi(this.ParentFigure.WindowState,'maximized')


                dialogPos(1)=figPos(1)+figPos(3)-dialogPos(3);
                dialogPos(2)=figPos(2);
            elseif strcmpi(this.ParentFigure.WindowStyle,'docked')


                dialogPos(1)=screenSize(3)/3;
                dialogPos(2)=screenSize(4)/3;
            else
                xPos=abs(dialogPos(1));

                if xPos>screenSize(3)
                    xPos=xPos-screenSize(3);
                end



                if(xPos+dialogPos(3))>screenSize(3)
                    dialogPos(1)=figPos(1)-dialogPos(3)-5;
                    dialogPos(2)=figPos(2);
                end
            end
        end

        function createComponents(this)
            this.AppFigure=uifigure('Visible','off',...
            'Name',getString(message('MATLAB:graphics:datatip:ModifyOption')),...
            'Position',this.getDialogPosition(),...
            'CloseRequestFcn',@(e,d)this.close());

            u=uigridlayout(this.AppFigure,'ColumnWidth',{'1x'},'RowHeight',{'1x','fit'});

            u1=uigridlayout(u,'ColumnWidth',{'1x','fit','1x','fit'},'RowHeight',{'1x'});
            u2=uigridlayout(u,'ColumnWidth',{'1x','1x'},'Padding',[292,0,0,0],'RowHeight',{'fit'});


            u13=uigridlayout(u1,'ColumnWidth',{'1x'},'Padding',[0,5,0,0],'RowHeight',{'fit','1x'});
            this.AvailableColumnsLabel=uilabel(u13,'HorizontalAlignment','center');
            this.AvailableColumnsLabel.Text=getString(message('MATLAB:graphics:datatip:AvailableLabel'));

            this.Available=uitree(u13);


            u11=uigridlayout(u1,'ColumnWidth',{'1x'},'Padding',[0,50,0,80],'RowHeight',{20,20});
            this.RightArrowButton=uibutton(u11,'push',...
            'Tooltip',getString(message('MATLAB:graphics:datatip:AddOptionsToSelected')));
            this.RightArrowButton.ButtonPushedFcn=@(e,d)this.rightArrowButtonPushed();
            this.RightArrowButton.Text='>>';


            this.LeftArrowButton=uibutton(u11,'push',...
            'Tooltip',getString(message('MATLAB:graphics:datatip:RemoveOptionsFromSelected')));
            this.LeftArrowButton.ButtonPushedFcn=@(e,d)this.leftArrowButtonPushed();
            this.LeftArrowButton.Text='<<';


            u14=uigridlayout(u1,'ColumnWidth',{'1x'},'Padding',[0,5,0,0],'RowHeight',{'fit','1x'});
            this.SelectedColumnsLabel=uilabel(u14,'HorizontalAlignment','center');
            this.SelectedColumnsLabel.Text=getString(message('MATLAB:graphics:datatip:SelectedLabel'));


            this.Selected=uitree(u14);


            u12=uigridlayout(u1,'ColumnWidth',{'1x'},'Padding',[0,0,0,80],'RowHeight',{'fit','fit'});
            this.UpButton=uibutton(u12,'push');
            this.UpButton.ButtonPushedFcn=@(e,d)this.moveUp();
            this.UpButton.Text=getString(message('MATLAB:graphics:datatip:UpLabel'));
            this.UpButton.Tooltip=getString(message('MATLAB:graphics:datatip:UpTooltip'));

            this.DownButton=uibutton(u12,'push');
            this.DownButton.ButtonPushedFcn=@(e,d)this.moveDown();
            this.DownButton.Text=getString(message('MATLAB:graphics:datatip:DownLabel'));
            this.DownButton.Tooltip=getString(message('MATLAB:graphics:datatip:DownTooltip'));


            this.OKButton=uibutton(u2,'push');
            this.OKButton.Text=getString(message('MATLAB:graphics:datatip:OKLabel'));
            this.OKButton.ButtonPushedFcn=@(e,d)this.commitUpdatesAndClose();


            this.CancelButton=uibutton(u2,'push');
            this.CancelButton.ButtonPushedFcn=@(e,d)this.close();
            this.CancelButton.Text=getString(message('MATLAB:graphics:datatip:CancelLabel'));

            this.AppFigure.Visible='on';

            this.updateOptions();
        end


        function moveUp(this)
            selectedNodes=this.Selected.SelectedNodes;

            for i=1:numel(selectedNodes)
                if selectedNodes(i).Parent==this.Selected
                    selectedIndex=find(ismember(this.Selected.Children,selectedNodes(i)));

                    if selectedIndex==1
                        continue;
                    end
                    prevDTConfig=this.CurrentDataTipConfiguration(selectedIndex-1,:);
                    currDTConfig=this.CurrentDataTipConfiguration(selectedIndex,:);
                    prevNode=this.Selected.Children(selectedIndex-1);
                    currNode=selectedNodes(i);
                    move(currNode,prevNode,'before');
                    this.CurrentDataTipConfiguration(selectedIndex-1,:)=currDTConfig;
                    this.CurrentDataTipConfiguration(selectedIndex,:)=prevDTConfig;
                end
            end
        end


        function moveDown(this)
            selectedNodes=this.Selected.SelectedNodes;

            for i=1:numel(selectedNodes)
                if selectedNodes(i).Parent==this.Selected
                    selectedIndex=find(ismember(this.Selected.Children,selectedNodes(i)));


                    if selectedIndex==numel(this.Selected.Children)
                        continue;
                    end
                    nextDTConfig=this.CurrentDataTipConfiguration(selectedIndex+1,:);
                    currDTConfig=this.CurrentDataTipConfiguration(selectedIndex,:);
                    afterNode=this.Selected.Children(selectedIndex+1);
                    currNode=selectedNodes(i);
                    move(currNode,afterNode,'after');
                    this.CurrentDataTipConfiguration(selectedIndex+1,:)=currDTConfig;
                    this.CurrentDataTipConfiguration(selectedIndex,:)=nextDTConfig;
                end
            end
        end

        function commitUpdatesAndClose(this)


            this.ParentChart.setConfiguration(this.CurrentDataTipConfiguration);
            this.close();
        end



        function rightArrowButtonPushed(this)
            selectedNodes=this.Available.SelectedNodes;
            if~isempty(selectedNodes)
                for i=1:numel(selectedNodes)
                    sNode=selectedNodes(i);



                    if isempty(sNode.Children)


                        nodeText=sNode.Text;
                        if sNode.Parent~=this.Available


                            this.CurrentDataTipConfiguration(end+1,:)=[sNode.Parent.Text,string(sNode.Tag)];
                            nodeText=getTranslatedDataTipLabel(sNode.Parent.Text,sNode.Tag);
                        else

                            this.CurrentDataTipConfiguration(end+1,:)=[sNode.Text,"none"];
                        end
                        uitreenode(this.Selected,'Text',nodeText,'NodeData',[]);
                        if isequal(sNode.Parent,this.Available)
                            this.AvailableVarOptions(find(this.Available.Children==sNode))=[];
                        elseif numel(sNode.Parent.Children)==1
                            this.AvailableVarOptions(find(this.Available.Children==sNode.Parent))=[];
                            delete(sNode.Parent);
                        end
                    else




                        for iCh=1:numel(sNode.Children)
                            dtMethodNode=sNode.Children(iCh);
                            this.CurrentDataTipConfiguration(end+1,:)=[sNode.Text,string(dtMethodNode.Tag)];
                            uitreenode(this.Selected,'Text',getTranslatedDataTipLabel(sNode.Text,dtMethodNode.Tag),'NodeData',[]);
                        end
                        this.AvailableVarOptions(find(this.Available.Children==sNode))=[];
                    end
                end
                delete(selectedNodes);
            end
        end


        function leftArrowButtonPushed(this)
            selectedNodes=this.Selected.SelectedNodes;
            if~isempty(selectedNodes)
                sInd=find(this.Selected.Children==selectedNodes);
                dtVars=this.CurrentDataTipConfiguration(:,1);
                dtMethods=this.CurrentDataTipConfiguration(:,2);
                for i=1:numel(selectedNodes)
                    sVar=dtVars(sInd(1));
                    sMethod=dtMethods(sInd(1));
                    avInd=find(ismember(this.AvailableVarOptions,sVar));
                    if~isempty(avInd)
                        uitreenode(this.Available.Children(avInd),...
                        'Tag',sMethod,...
                        'Text',matlab.graphics.datatip.internal.mixin.AggregatedDataTipMixin.getStringFromMessageCatalog(sMethod),...
                        'NodeData',[]);
                    else
                        c=uitreenode(this.Available,'Text',sVar,'NodeData',[]);
                        if~strcmpi(sMethod,"none")
                            uitreenode(c,'Text',matlab.graphics.datatip.internal.mixin.AggregatedDataTipMixin.getStringFromMessageCatalog(sMethod),...
                            'Tag',sMethod,'NodeData',[]);
                        end
                        this.AvailableVarOptions(end+1)=sVar;
                    end
                end
                delete(selectedNodes);
                this.CurrentDataTipConfiguration(sInd,:)=[];
            end
        end
    end
end


function translatedLabel=getTranslatedDataTipLabel(dtVar,dtMethod)


    msgPrefix='MATLAB:graphics:datatip:';
    dtMethod(1)=upper(dtMethod(1));
    msgID=[msgPrefix,dtMethod,'Variable'];
    translatedLabel=getString(message(msgID,dtVar));
end