classdef DataTipsDialog<handle






    properties(Access=?tDataTip)
        AppFigure matlab.ui.Figure
        RightArrowButton matlab.ui.control.Button
        LeftArrowButton matlab.ui.control.Button
        Available matlab.ui.control.ListBox
        OKButton matlab.ui.control.Button
        CancelButton matlab.ui.control.Button
        Selected matlab.ui.control.ListBox
        AvailableColumnsLabel matlab.ui.control.Label
        SelectedColumnsLabel matlab.ui.control.Label
        UpButton matlab.ui.control.Button
        DownButton matlab.ui.control.Button
ParentFigure
ParentChart
    end

    properties(Access=?tDataTip,Constant)
        DIALOG_WIDTH=438
        DIALOG_HEIGHT=292
    end

    methods
        function this=DataTipsDialog(parentChart)
            this.ParentChart=parentChart;
            this.ParentFigure=ancestor(parentChart,'figure');

            this.createComponents();


            addlistener(this.ParentFigure,'ObjectBeingDestroyed',@(e,d)this.delete());
        end







        function close(this)
            set(this.AppFigure,'Visible','off');
        end

        function delete(this)
            delete(this.AppFigure);
        end


        function bringToFront(this)
            this.updateOptions();
            set(this.AppFigure,'Visible','on');
        end




        function updateOptions(this)
            tbl=this.ParentChart.SourceTable;
            totalOptions=[tbl.Properties.VariableNames,tbl.Properties.DimensionNames{1}];
            selectedOptions=this.ParentChart.getDataTipVariables();



            unSelectedOptions=sort(setdiff(totalOptions,selectedOptions));


            this.Available.Items=unSelectedOptions;
            if~isempty(unSelectedOptions)
                this.Available.Value=unSelectedOptions{1};
            end


            this.Selected.Items=selectedOptions;
            if~isempty(selectedOptions)
                this.Selected.Value=selectedOptions{1};
            end
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


            this.Available=uilistbox(u13);
            this.Available.Multiselect='on';

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


            this.Selected=uilistbox(u14);
            this.Selected.Multiselect='on';


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
            this.OKButton.ButtonPushedFcn=@(e,d)this.updateDataTipConfigurationAndClose();


            this.CancelButton=uibutton(u2,'push');
            this.CancelButton.ButtonPushedFcn=@(e,d)this.close();
            this.CancelButton.Text=getString(message('MATLAB:graphics:datatip:CancelLabel'));


            this.AppFigure.Visible='on';
            this.updateOptions();
        end



        function moveUp(this)
            selectedValues=this.Selected.Value;

            for i=1:numel(selectedValues)
                selectedIndex=find(strcmpi(this.Selected.Items,selectedValues{i}));
                if selectedIndex==1
                    continue;
                end
                prevValue=this.Selected.Items{selectedIndex-1};
                currValue=selectedValues{i};
                this.Selected.Items{selectedIndex-1}=currValue;
                this.Selected.Items{selectedIndex}=prevValue;
            end
        end



        function moveDown(this)
            selectedValues=this.Selected.Value;

            for i=1:numel(selectedValues)
                selectedIndex=find(strcmpi(this.Selected.Items,selectedValues{i}));
                if selectedIndex==numel(this.Selected.Items)
                    continue;
                end
                nextValue=this.Selected.Items{selectedIndex+1};
                currValue=selectedValues{i};
                this.Selected.Items{selectedIndex+1}=currValue;
                this.Selected.Items{selectedIndex}=nextValue;
            end
        end



        function updateDataTipConfigurationAndClose(this)
            this.ParentChart.setConfiguration(string(this.Selected.Items)');
            this.close();
        end


        function rightArrowButtonPushed(this)
            selectedVal=this.Available.Value;

            this.Available.Items=this.Available.Items(~ismember(this.Available.Items,selectedVal));
            this.Selected.Items=[this.Selected.Items,selectedVal];
        end


        function leftArrowButtonPushed(this)
            selectedVal=this.Selected.Value;

            this.Selected.Items=this.Selected.Items(~ismember(this.Selected.Items,selectedVal));
            this.Available.Items=[this.Available.Items,selectedVal];
        end
    end
end