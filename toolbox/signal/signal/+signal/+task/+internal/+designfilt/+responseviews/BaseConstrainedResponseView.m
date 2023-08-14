classdef(Abstract)BaseConstrainedResponseView<signal.task.internal.designfilt.responseviews.BaseResponseView




    properties(Transient)

        SpecificationsPanel=[];
        FrequencyConstraintsPanel=[];
        MagnitudeConstraintsPanel=[];
        AlgorithmPanel=[];
        DesingOptionsPanelParent=[];
        DesignOptionsPanel=[];


        SpecificationsGrid=[];
        OrderModeLabel=[];
        OrderModeDropDown=[];
        OrderLabel=[];
        OrderSpinner=[];
        DenominatorOrderCheckBox=[];
        DenominatorOrderSpinner=[];


        FrequencyContraintsGrid=[];
        FrequencyContraintsSubGrid=[];
        FrequencyUnitsAndSpecsSubGrid=[];

        FrequencyConstraintsLabel=[];
        FrequencyConstraintsDropDown=[];
        FrequencyUnitsLabel=[];
        FrequencyUnitsDropDown=[];
        SampleRateLabel=[];
        SampleRateDropDown=[];
        F1Label=[];
        F1EditField=[];
        F2Label=[];
        F2EditField=[];
        F3Label=[];
        F3EditField=[];
        F4Label=[];
        F4EditField=[];


        MagnitudeConstraintsGrid=[];
        MagnitudeConstraintsSubGrid=[];
        MagnitudeSpecsSubGrid=[];
        MagnitudeConstraintsLabel=[];
        MagnitudeConstraintsDropDown=[];
        Mag1Label=[];
        Mag1EditField=[];
        Mag2Label=[];
        Mag2EditField=[];
        Mag3Label=[];
        Mag3EditField=[];
        Mag4Label=[];
        Mag4EditField=[];


        AlgorithmGrid=[];
        AlgorithmSubGrid=[];
        DesignMethodSubGrid=[];
        DesignOptionsSubGrid=[];
        DesignMethodLabel=[];
        DesignMethodDropDown=[];
        DesignOptionsGrid=[];
    end

    properties(Access=protected,Transient)




        ControlList=[...
        "OrderModeDropDown","OrderMode";
        "OrderSpinner","Order";
        "DenominatorOrderCheckBox","SpecifyDenominator";
        "DenominatorOrderSpinner","DenominatorOrder";
        "FrequencyConstraintsDropDown","FrequencyConstraints";
        "FrequencyUnitsDropDown","FrequencyUnits";
        "SampleRateDropDown","InputSampleRate";
        "F1EditField","F1";
        "F2EditField","F2";
        "F3EditField","F3";
        "F4EditField","F4";
        "MagnitudeConstraintsDropDown","MagnitudeConstraints";
        "Mag1EditField","Mag1";
        "Mag2EditField","Mag2";
        "Mag3EditField","Mag3";
        "Mag4EditField","Mag4";
        "DesignMethodDropDown","DesignMethod";];
    end




    methods
        function updateGroups(this,viewSettings)


            drawnow nocallbacks;




            if~isGroupsRendered(this)
                createGroupSections(this);
                addControlsToGroups(this);
                addControlsCallbacks(this,this.ControlList);
            end
            updateSettings(this,viewSettings);
        end

        function flag=isGroupsRendered(this)


            flag=~isempty(this.SpecificationsPanel)&&...
            ~isempty(this.FrequencyConstraintsPanel)&&...
            ~isempty(this.MagnitudeConstraintsPanel)&&...
            ~isempty(this.AlgorithmPanel);
        end

        function flag=isReadyForScript(this)
            flag=true;
            if~isGroupsRendered(this)
                flag=false;
                return;
            end
            fUnits=this.FrequencyUnitsDropDown.Value;
            sr=this.SampleRateDropDown.Value;
            if strcmp(fUnits,'Hz')&&ischar(sr)&&strcmp(sr,'select variable')
                flag=false;
            end
        end

        function value=getControlValue(this,propName)
            idx=ismember(this.ControlList(:,2),propName);
            controlName=this.ControlList(idx,1);
            value=this.(controlName).Value;
        end
    end

    methods(Access=protected)

        function createGroupSections(this)





            this.SpecificationsPanel=addSpecificationsGroup(this);
            this.FrequencyConstraintsPanel=addFrequencyConstraintsGroup(this);
            this.MagnitudeConstraintsPanel=addMagnitudeConstraintsGroup(this);
            this.AlgorithmPanel=addAlgorithmGroup(this);
        end

        function addControlsToGroups(this)


            addSpecificationsControls(this);
            addFrequencyConstraintsControls(this);
            addMagnitudeConstraintsControls(this);
            addAlgorithmControls(this);
        end

        function updateSettings(this,viewSettings)
            drawnow nocallbacks;

            if isfield(viewSettings,'specificationSettings')
                updateSpecificationSettings(this,viewSettings.specificationSettings);
            end
            if isfield(viewSettings,'frequencyConstraintsSettings')&&~isempty(viewSettings.frequencyConstraintsSettings)
                updateFrequencyConstraintsSettings(this,viewSettings.frequencyConstraintsSettings);
            end
            if isfield(viewSettings,'magnitudeConstraintsSettings')&&~isempty(viewSettings.magnitudeConstraintsSettings)
                updateMagnitudeConstraintsSettings(this,viewSettings.magnitudeConstraintsSettings);
            end
            if isfield(viewSettings,'algorithmSettings')
                updateAlgorithmsSettings(this,viewSettings.algorithmSettings);
            end
            manageEnableStateOfControls(this);
        end

        function manageEnableStateOfControls(this)


            if this.FrequencyUnitsDropDown.Value=="Hz"
                if strcmp(this.SampleRateDropDown.Value,'select variable')
                    enableControlsWhenSampleRateNotReady(this,false);
                else
                    enableControlsWhenSampleRateNotReady(this,true);
                end
            else
                enableControlsWhenSampleRateNotReady(this,true);
            end
        end

        function accordionPanel=addFrequencyConstraintsGroup(this)

            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt



            accordionPanel=BaseTask.createAccordionPanel(...
            this.ParentAccordion,msgid2txt('FrequencyConstraintsHeader'),...
            'FrequencyContraints');
        end

        function accordionPanel=addMagnitudeConstraintsGroup(this)

            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt



            accordionPanel=BaseTask.createAccordionPanel(this.ParentAccordion,...
            msgid2txt('MagnitudeConstraintsHeader'),'MagnitudeContraints');
        end

        function addSpecificationsControls(this)

            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt








            grid=BaseTask.createAccordionPanelSubGrid(this.SpecificationsPanel,1,6,'SpecificationsGrid');
            grid.RowHeight={'fit'};
            grid.ColumnWidth={'fit','fit',0,0,0,0};
            this.SpecificationsGrid=grid;

            rowIdx=1;

            this.OrderModeLabel=BaseTask.createLabel(grid,...
            msgid2txt('OrderModeLabel'),'OrderModeLabel',rowIdx,1);


            orderModeMappings=signal.task.internal.designfilt.responsemodels.BaseResponseModel.OrderModeMappings;
            this.OrderModeDropDown=uidropdown(grid,...
            'Tooltip',msgid2txt('OrderModeDropDownTooltip'),...
            'Items',orderModeMappings(:,2),...
            'ItemsData',orderModeMappings(:,1),...
            'Value',orderModeMappings(1,1),...
            'Editable',false,'Tag','OrderModeDropDown');
            this.setLayout(this.OrderModeDropDown,rowIdx,2);


            this.OrderLabel=BaseTask.createLabel(grid,...
            msgid2txt('OrderLabel'),'OrderLabel',rowIdx,3);


            this.OrderSpinner=uispinner(grid,'Limits',[1,Inf],'Value',20,...
            'UpperLimitInclusive','off','RoundFractionalValues','on',...
            'Tooltip',msgid2txt('OrderTooltip'),'Tag','Order');
            this.setLayout(this.OrderSpinner,rowIdx,4);


            this.DenominatorOrderCheckBox=uicheckbox(grid,...
            'Text',msgid2txt('OrderLabelDen'),'Tag','OrderLabelDen');
            this.setLayout(this.DenominatorOrderCheckBox,rowIdx,5);


            this.DenominatorOrderSpinner=uispinner(grid,'Limits',[1,Inf],'Value',20,...
            'UpperLimitInclusive','off','RoundFractionalValues','on',...
            'Tooltip',msgid2txt('OrderTooltipDen'),'Tag','DenominatorOrder');
            this.setLayout(this.DenominatorOrderSpinner,rowIdx,6);
            this.DenominatorOrderSpinner.Visible='off';
        end

        function addFrequencyConstraintsControls(this)

            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt
            import matlab.ui.control.internal.*
            import matlab.ui.control.internal.model.*












            grid=BaseTask.createAccordionPanelSubGrid(this.FrequencyConstraintsPanel,2,1,'FrequencyConstraintsGrid');
            grid.RowHeight={'fit','fit'};
            grid.ColumnWidth={'fit'};
            grid.RowSpacing=0;
            this.FrequencyContraintsGrid=grid;


            grid=BaseTask.createAccordionPanelSubGrid(this.FrequencyContraintsGrid,1,2,'FrequencyConstraintsSubGrid');
            grid.RowHeight={0};
            grid.ColumnWidth={'fit',this.CONSTRAINTS_DROPDOWN_WIDTH};
            grid.RowSpacing=0;
            grid.Padding=[0,6,0,0];
            this.FrequencyContraintsSubGrid=grid;

            rowIdx=1;

            this.FrequencyConstraintsLabel=BaseTask.createLabel(grid,...
            msgid2txt('FrequencyConstraintsLabel'),'FrequencyConstraintsLabel',rowIdx,1);



            this.FrequencyConstraintsDropDown=uidropdown(grid,...
            'Tooltip',msgid2txt('FrequencyConstraintsDropDownTooltip'),...
            'Editable',false,'Tag','FrequencyConstraintsDropDown');
            this.setLayout(this.FrequencyConstraintsDropDown,rowIdx,2);


            grid=BaseTask.createAccordionPanelSubGrid(this.FrequencyContraintsGrid,3,4,'FrequencyUnitsAndSpecsSubGrid');
            grid.RowHeight={'fit','fit',0};
            grid.ColumnWidth={'fit',this.UIEDITFIELD_WIDTH,'fit',this.UIEDITFIELD_WIDTH};
            grid.Padding=[0,0,0,0];
            this.FrequencyUnitsAndSpecsSubGrid=grid;

            rowIdx=1;

            this.FrequencyUnitsLabel=BaseTask.createLabel(grid,...
            msgid2txt('FrequencyUnitsLabel'),'FrequencyUnitsLabel',rowIdx,1);


            freqUnitsMappings=signal.task.internal.designfilt.responsemodels.BaseResponseModel.FrequencyUnitsMappings;

            this.FrequencyUnitsDropDown=uidropdown(grid,...
            'Tooltip',msgid2txt('FrequencyUnitsDropDownTooltip'),...
            'Items',freqUnitsMappings(:,2),...
            'ItemsData',freqUnitsMappings(:,1),...
            'Value',freqUnitsMappings(1,1),...
            'Editable',false,'Tag','FrequencyConstraintsDropDown');
            this.setLayout(this.FrequencyUnitsDropDown,rowIdx,2);


            this.SampleRateLabel=BaseTask.createLabel(grid,...
            msgid2txt('SampleRateLabel'),'SampleRateLabel',rowIdx,3);


            filterFcn=@(x)signal.task.internal.designfilt.responseviews.BaseResponseView.isPositiveFiniteNumber(x);

            this.SampleRateDropDown=WorkspaceDropDown('Parent',grid,...
            'Editable','on','Tag','SampleRateDropDown',...
            'Tooltip',msgid2txt('SampleRateDropDownTooltip'));
            this.SampleRateDropDown.FilterVariablesFcn=filterFcn;
            this.setLayout(this.SampleRateDropDown,rowIdx,4);

            rowIdx=2;

            this.F1Label=BaseTask.createLabel(grid,...
            msgid2txt('Fpass'),'F1Label',rowIdx,1);


            this.F1EditField=uieditfield(grid,'numeric','Limits',[0,1],...
            'LowerLimitInclusive','off','UpperLimitInclusive','off',...
            'ValueDisplayFormat',this.UIEDITFIELD_PRECISION,...
            'Tag','F1EditField');
            this.setLayout(this.F1EditField,rowIdx,2);


            this.F2Label=BaseTask.createLabel(grid,...
            msgid2txt('Fstop'),'F2Label',rowIdx,3);


            this.F2EditField=uieditfield(grid,'numeric','Limits',[0,1],...
            'LowerLimitInclusive','off','UpperLimitInclusive','off',...
            'ValueDisplayFormat',this.UIEDITFIELD_PRECISION,...
            'Tag','F2EditField');
            this.setLayout(this.F2EditField,rowIdx,4);

            rowIdx=3;

            this.F3Label=BaseTask.createLabel(grid,...
            '','F3Label',rowIdx,1);


            this.F3EditField=uieditfield(grid,'numeric','Limits',[0,1],...
            'LowerLimitInclusive','off','UpperLimitInclusive','off',...
            'ValueDisplayFormat',this.UIEDITFIELD_PRECISION,...
            'Tag','F3EditField');
            this.setLayout(this.F3EditField,rowIdx,2);


            this.F4Label=BaseTask.createLabel(grid,...
            '','F4Label',rowIdx,3);


            this.F4EditField=uieditfield(grid,'numeric','Limits',[0,Inf],...
            'LowerLimitInclusive','off','UpperLimitInclusive','off',...
            'ValueDisplayFormat',this.UIEDITFIELD_PRECISION,...
            'Tag','F4EditField');
            this.setLayout(this.F4EditField,rowIdx,4);
        end

        function addMagnitudeConstraintsControls(this)








            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt


            grid=BaseTask.createAccordionPanelSubGrid(this.MagnitudeConstraintsPanel,2,1,'MagnitudeConstraintsGrid');
            grid.RowHeight={'fit','fit'};
            grid.ColumnWidth={'fit'};
            grid.RowSpacing=0;
            this.MagnitudeConstraintsGrid=grid;


            grid=BaseTask.createAccordionPanelSubGrid(this.MagnitudeConstraintsGrid,1,2,'MagnitudeConstraintsSubGrid');
            grid.RowHeight={0};
            grid.ColumnWidth={'fit',this.CONSTRAINTS_DROPDOWN_WIDTH};
            grid.RowSpacing=0;
            grid.Padding=[0,6,0,0];
            this.MagnitudeConstraintsSubGrid=grid;

            rowIdx=1;

            this.MagnitudeConstraintsLabel=BaseTask.createLabel(grid,...
            msgid2txt('MagnitudeConstraintsLabel'),'MagnitudeConstraintsLabel',rowIdx,1);



            this.MagnitudeConstraintsDropDown=uidropdown(grid,...
            'Tooltip',msgid2txt('MagnitudeConstraintsDropDownTooltip'),...
            'Editable',false,'Tag','MagnitudeConstraintsDropDown');
            this.setLayout(this.MagnitudeConstraintsDropDown,rowIdx,2);


            grid=BaseTask.createAccordionPanelSubGrid(this.MagnitudeConstraintsGrid,2,4,'MagnitudeSpecsSubGrid');
            grid.RowHeight={'fit',0};
            grid.ColumnWidth={'fit',this.UIEDITFIELD_WIDTH,'fit',this.UIEDITFIELD_WIDTH};
            grid.Padding=[0,0,0,0];
            this.MagnitudeSpecsSubGrid=grid;

            rowIdx=1;

            this.Mag1Label=BaseTask.createLabel(grid,...
            msgid2txt('Apass'),'Mag1Label',rowIdx,1);


            this.Mag1EditField=uieditfield(grid,'numeric','Limits',[0,Inf],...
            'LowerLimitInclusive','off','UpperLimitInclusive','off',...
            'Tag','Mag1EditField','Value',1);
            this.setLayout(this.Mag1EditField,rowIdx,2);


            this.Mag2Label=BaseTask.createLabel(grid,...
            msgid2txt('Astop'),'Mag2Label',rowIdx,3);


            this.Mag2EditField=uieditfield(grid,'numeric','Limits',[0,Inf],...
            'LowerLimitInclusive','off','UpperLimitInclusive','off',...
            'Tag','Mag2EditField');
            this.setLayout(this.Mag2EditField,rowIdx,4);

            rowIdx=2;

            this.Mag3Label=BaseTask.createLabel(grid,...
            '','Mag3Label',rowIdx,1);


            this.Mag3EditField=uieditfield(grid,'numeric','Limits',[0,Inf],...
            'LowerLimitInclusive','off','UpperLimitInclusive','off',...
            'Tag','Mag3EditField');
            this.setLayout(this.Mag3EditField,rowIdx,2);


            this.Mag4Label=BaseTask.createLabel(grid,...
            '','Mag4Label',rowIdx,3);


            this.Mag4EditField=uieditfield(grid,'numeric','Limits',[0,Inf],...
            'LowerLimitInclusive','off','UpperLimitInclusive','off',...
            'Tag','Mag4EditField','Value',60);
            this.setLayout(this.Mag4EditField,rowIdx,4);
        end

        function addAlgorithmControls(this)








            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt


            grid=BaseTask.createAccordionPanelSubGrid(this.AlgorithmPanel,2,1,'AlgorithmGrid');
            grid.RowHeight={'fit','fit'};
            grid.ColumnWidth={'fit'};
            grid.RowSpacing=5;
            this.AlgorithmGrid=grid;


            grid=BaseTask.createAccordionPanelSubGrid(this.AlgorithmGrid,1,2,'AlgorithmSubGrid');
            grid.RowHeight={'fit'};
            grid.ColumnWidth={'fit','fit'};
            grid.RowSpacing=0;
            grid.Padding=[0,0,0,0];
            this.AlgorithmSubGrid=grid;

            rowIdx=1;

            this.DesignMethodLabel=BaseTask.createLabel(grid,...
            msgid2txt('DesignMethodLabel'),'DesignMethodLabel',rowIdx,1);



            this.DesignMethodDropDown=uidropdown(grid,...
            'Tooltip',msgid2txt('DesignMethodDropDownTooltip'),...
            'Editable',false,'Tag','DesignMethodDropDown');
            this.setLayout(this.DesignMethodDropDown,rowIdx,2);
        end
    end



    methods(Access=protected)

        function setControlValue(this,propName,value)
            idx=ismember(this.ControlList(:,2),propName);
            controlName=this.ControlList(idx,1);
            this.(controlName).Value=value;
        end

        function setPopupItems(this,propName,items,itemsData,value)
            idx=ismember(this.ControlList(:,2),propName);
            controlName=this.ControlList(idx,1);
            this.(controlName).Items=items;
            this.(controlName).ItemsData=itemsData;
            if nargin>4
                this.(controlName).Value=value;
            end
        end

        function setSampleRateValue(this,value,source)
            if isempty(value)
                this.SampleRateDropDown.Value='select variable';
            else
                if strcmp(source,'workspaceVariable')
                    this.SampleRateDropDown.populateVariables();
                    items=this.SampleRateDropDown.ItemsData;
                    if~ismember(value,items)
                        this.SampleRateDropDown.ItemsData=[this.SampleRateDropDown.ItemsData,{value}];
                        this.SampleRateDropDown.Items=[this.SampleRateDropDown.Items,{value}];
                    end
                end
                this.SampleRateDropDown.Value=value;
            end
        end

        function enableControlsWhenSampleRateNotReady(this,enableFlag)




            this.F1EditField.Enable=enableFlag;
            this.F2EditField.Enable=enableFlag;
            this.F3EditField.Enable=enableFlag;
            this.F4EditField.Enable=enableFlag;

            this.Mag1EditField.Enable=enableFlag;
            this.Mag2EditField.Enable=enableFlag;
            this.Mag3EditField.Enable=enableFlag;
            this.Mag4EditField.Enable=enableFlag;

            this.FrequencyConstraintsLabel.Enable=enableFlag;
            this.F1Label.Enable=enableFlag;
            this.F2Label.Enable=enableFlag;
            this.F3Label.Enable=enableFlag;
            this.F4Label.Enable=enableFlag;
            this.MagnitudeConstraintsLabel.Enable=enableFlag;
            this.MagnitudeConstraintsDropDown.Enable=enableFlag;
            this.Mag1Label.Enable=enableFlag;
            this.Mag2Label.Enable=enableFlag;
            this.Mag3Label.Enable=enableFlag;
            this.Mag4Label.Enable=enableFlag;

            this.DesignMethodLabel.Enable=enableFlag;
            this.DesignMethodDropDown.Enable=enableFlag;


            if~isempty(this.DesignOptionsPanel)&&~isempty(this.DesignOptionsPanel.Parent)
                grid=this.DesignOptionsPanel.Children;
                if~isempty(grid)
                    controls=grid.Children;
                    for idx=1:numel(controls)
                        controls(idx).Enable=enableFlag;
                    end
                end
            end
        end






        function setOrderVisible(this,makeVisibleFlag)
            if makeVisibleFlag
                this.SpecificationsGrid.ColumnWidth(3:4)={'fit',this.ORDER_SPINNER_WIDTH};
            else
                this.SpecificationsGrid.ColumnWidth(3:4)={0,0};
            end
        end

        function setOrderModeVisible(this,makeVisibleFlag)
            if makeVisibleFlag
                this.SpecificationsGrid.ColumnWidth(1:2)={'fit','fit'};
            else
                this.SpecificationsGrid.ColumnWidth(1:2)={0,0};
            end
        end

        function updateOrderSpinnerBasedOnOrderRestriction(this,restriction)
            import signal.task.internal.designfilt.msgid2txt
            if strcmp(restriction,'none')
                this.OrderSpinner.Step=1;
                this.OrderSpinner.Tooltip=msgid2txt('OrderTooltip');
            else
                this.OrderSpinner.Step=2;
                if strcmp(restriction,'even')
                    this.OrderSpinner.Tooltip=msgid2txt('OrderTooltipEven');
                else
                    this.OrderSpinner.Tooltip=msgid2txt('OrderTooltipOdd');
                end
            end
        end


        function setDenominatorOrderCheckBoxVisible(this,makeVisibleFlag)



            this.DenominatorOrderCheckBox.Visible=makeVisibleFlag;
            if makeVisibleFlag
                this.SpecificationsGrid.ColumnWidth(5)={'fit'};
            else
                this.SpecificationsGrid.ColumnWidth(5)={0};
            end
        end

        function setDenominatorOrderVisible(this,makeVisibleFlag)




            import signal.task.internal.designfilt.msgid2txt

            if makeVisibleFlag
                this.OrderLabel.Text=msgid2txt('OrderLabelNum');
                this.OrderSpinner.Tooltip=msgid2txt('OrderTooltipNum');
                this.SpecificationsGrid.ColumnWidth(6)={this.ORDER_SPINNER_WIDTH};
            else
                this.OrderLabel.Text=msgid2txt('OrderLabel');
                this.OrderSpinner.Tooltip=msgid2txt('OrderTooltip');
                this.SpecificationsGrid.ColumnWidth(6)={0};
            end
            this.DenominatorOrderSpinner.Visible=makeVisibleFlag;
        end


        function setFrequencyConstraintsVisible(this,makeVisibleFlag)
            if makeVisibleFlag
                this.FrequencyContraintsSubGrid.RowHeight={'fit'};
            else
                this.FrequencyContraintsSubGrid.RowHeight={0};
            end
        end


        function setSampleRateVisible(this,makeVisibleFlag)
            this.SampleRateLabel.Visible=makeVisibleFlag;
            this.SampleRateDropDown.Visible=makeVisibleFlag;
        end


        function updateFrequencySpecsControls(this,settings,FNyquist)


            import signal.task.internal.designfilt.msgid2txt

            F1Flag=false;
            F2Flag=false;
            F3Flag=false;
            F4Flag=false;



            this.F1EditField.Limits=[0,Inf];
            this.F2EditField.Limits=[0,Inf];
            this.F3EditField.Limits=[0,Inf];
            this.F4EditField.Limits=[0,Inf];

            if nargin>1
                F1Flag=isfield(settings,'F1');
                F2Flag=isfield(settings,'F2');
                F3Flag=isfield(settings,'F3');
                F4Flag=isfield(settings,'F4');
            end

            if F1Flag
                F1Name=settings.F1Name;
                v1=settings.F1;

                this.F1Label.Text=msgid2txt(F1Name);
                this.F1EditField.UserData=F1Name;
                this.F1Label.Visible=F1Flag;
                this.F1EditField.Value=v1;
                this.F1EditField.Visible=F1Flag;
                this.FrequencyUnitsAndSpecsSubGrid.RowHeight(2)={'fit'};
            else

                this.FrequencyUnitsAndSpecsSubGrid.RowHeight([2,3])={0,0};
                this.F1EditField.UserData=[];
                this.F2EditField.UserData=[];
                this.F3EditField.UserData=[];
                this.F4EditField.UserData=[];
                this.F1Label.Text='';
                this.F2Label.Text='';
                this.F3Label.Text='';
                this.F4Label.Text='';
                return;
            end

            f2Limits=[];


            if F2Flag
                F2Name=settings.F2Name;
                v2=settings.F2;

                this.F2EditField.UserData=F2Name;
                this.F2EditField.Value=v2;
                this.F2Label.Text=msgid2txt(F2Name);

                f1Limits=[0,settings.F2];
                f1LimitsNames=["0",string(settings.F2Name)];
                f2Limits=[settings.F1,FNyquist];
                f2LimitsNames=[string(settings.F1Name),string(FNyquist)];
            else
                this.F2EditField.UserData=[];
                this.F2Label.Text='';

                f1Limits=[0,FNyquist];
                f1LimitsNames=["0",string(FNyquist)];
            end
            this.F2Label.Visible=F2Flag;
            this.F2EditField.Visible=F2Flag;

            if~isempty(FNyquist)
                this.F1EditField.Limits=f1Limits;
                this.F1EditField.Tooltip=msgid2txt('LimitsTooltip',f1LimitsNames(1),F1Name,f1LimitsNames(2));

                if~isempty(f2Limits)
                    this.F2EditField.Limits=f2Limits;
                    this.F2EditField.Tooltip=msgid2txt('LimitsTooltip',f2LimitsNames(1),F2Name,f2LimitsNames(2));
                end
            end

            if F3Flag
                F3Name=settings.F3Name;
                v3=settings.F3;

                this.F3Label.Text=msgid2txt(F3Name);
                this.F3EditField.UserData=F3Name;
                this.F3Label.Visible=F3Flag;
                this.F3EditField.Value=v3;
                this.F3EditField.Visible=F3Flag;
                this.FrequencyUnitsAndSpecsSubGrid.RowHeight(3)={'fit'};
            else


                this.FrequencyUnitsAndSpecsSubGrid.RowHeight(3)={0};
                this.F3EditField.UserData=[];
                this.F3Label.Text='';
                return;
            end



            if F4Flag
                F4Name=settings.F4Name;
                v4=settings.F4;

                this.F4EditField.UserData=F4Name;
                this.F4EditField.Value=v4;
                this.F4Label.Text=msgid2txt(F4Name);
            else
                this.F4EditField.UserData=[];
            end
            this.F4Label.Visible=F4Flag;
            this.F4EditField.Visible=F4Flag;


            if F3Flag&&F4Flag&&~isempty(FNyquist)
                f1Limits=[0,settings.F2];
                f1LimitsNames=["0",string(settings.F2Name)];
                f2Limits=[settings.F1,settings.F3];
                f2LimitsNames=[string(settings.F1Name),string(settings.F3Name)];
                f3Limits=[settings.F2,settings.F4];
                f3LimitsNames=[string(settings.F2Name),string(settings.F4Name)];
                f4Limits=[settings.F3,FNyquist];
                f4LimitsNames=[string(settings.F3Name),string(FNyquist)];

                this.F1EditField.Limits=f1Limits;
                this.F1EditField.Tooltip=msgid2txt('LimitsTooltip',f1LimitsNames(1),F1Name,f1LimitsNames(2));

                this.F2EditField.Limits=f2Limits;
                this.F2EditField.Tooltip=msgid2txt('LimitsTooltip',f2LimitsNames(1),F2Name,f2LimitsNames(2));

                this.F3EditField.Limits=f3Limits;
                this.F3EditField.Tooltip=msgid2txt('LimitsTooltip',f3LimitsNames(1),F3Name,f3LimitsNames(2));

                this.F4EditField.Limits=f4Limits;
                this.F4EditField.Tooltip=msgid2txt('LimitsTooltip',f4LimitsNames(1),F4Name,f4LimitsNames(2));
            end
        end


        function setMagnitudeConstraintsVisible(this,makeVisibleFlag)
            if makeVisibleFlag
                this.MagnitudeConstraintsSubGrid.RowHeight={'fit'};
            else
                this.MagnitudeConstraintsSubGrid.RowHeight={0};
            end
        end

        function updateMagnitudeSpecsControls(this,settings)






            import signal.task.internal.designfilt.msgid2txt

            Mag1Flag=isfield(settings,'Mag1');
            Mag2Flag=isfield(settings,'Mag2');
            Mag3Flag=isfield(settings,'Mag3');
            Mag4Flag=isfield(settings,'Mag4');

            if Mag1Flag
                Mag1Name=settings.Mag1Name;
                v1=settings.Mag1;

                this.Mag1Label.Text=msgid2txt(Mag1Name);
                this.Mag1EditField.UserData=Mag1Name;
                this.Mag1EditField.Value=v1;
                this.Mag1Label.Visible=Mag1Flag;
                this.Mag1EditField.Visible=Mag1Flag;
                this.MagnitudeSpecsSubGrid.RowHeight(1)={'fit'};
            else

                this.MagnitudeSpecsSubGrid.RowHeight([1,2])={0,0};
                this.Mag1EditField.UserData=[];
                this.Mag2EditField.UserData=[];
                this.Mag3EditField.UserData=[];
                this.Mag4EditField.UserData=[];
                return;
            end



            if Mag2Flag
                Mag2Name=settings.Mag2Name;
                v2=settings.Mag2;

                this.Mag2EditField.UserData=Mag2Name;
                this.Mag2EditField.Value=v2;
                this.Mag2Label.Text=msgid2txt(Mag2Name);
            else
                this.Mag2EditField.UserData=[];
            end
            this.Mag2Label.Visible=Mag2Flag;
            this.Mag2EditField.Visible=Mag2Flag;

            if Mag3Flag
                Mag3Name=settings.Mag3Name;
                v3=settings.Mag3;

                this.Mag3Label.Text=msgid2txt(Mag3Name);
                this.Mag3EditField.UserData=Mag3Name;
                this.Mag3EditField.Value=v3;
                this.Mag3Label.Visible=Mag3Flag;
                this.Mag3EditField.Visible=Mag3Flag;
                this.MagnitudeSpecsSubGrid.RowHeight(2)={'fit'};
            else


                this.MagnitudeSpecsSubGrid.RowHeight(2)={0};
                this.Mag3EditField.UserData=[];
                return;
            end



            if Mag4Flag
                Mag4Name=settings.Mag4Name;
                v4=settings.Mag4;

                this.Mag4EditField.UserData=Mag4Name;
                this.Mag4EditField.Value=v4;
                this.Mag4Label.Text=msgid2txt(Mag4Name);
            else
                this.Mag4EditField.UserData=[];
            end
            this.Mag4Label.Visible=Mag4Flag;
            this.Mag4EditField.Visible=Mag4Flag;
        end
    end




    methods(Access=protected)

        function updateSpecificationSettings(this,settings)

            setDenominatorOrderCheckBoxVisible(this,false);
            setDenominatorOrderVisible(this,false);
            if isfield(settings,'OrderMode')
                specifyFlag=string(settings.OrderMode)=="Specify";
                if specifyFlag
                    setControlValue(this,'Order',settings.Order);
                    setControlValue(this,'OrderMode','specify');


                    updateOrderSpinnerBasedOnOrderRestriction(this,settings.OrderRestriction);
                else
                    setControlValue(this,'OrderMode','minimum');
                end
                setOrderVisible(this,specifyFlag);
            end
        end

        function updateFrequencyConstraintsSettings(this,settings)


            isNormalized=settings.FrequencyUnitsValue=="normalized";
            if isNormalized
                fNyquist=1;
            else
                fNyquist=settings.SampleRateNumericValue/2;
            end

            if settings.OrderMode=="minimum"
                setFrequencyConstraintsVisible(this,false);
            else

                setFrequencyConstraintsVisible(this,true);


                if isfield(settings,'PopupItems')
                    setPopupItems(this,'FrequencyConstraints',settings.PopupItems,...
                    settings.PopupItemsData,settings.PopupValue);
                end
            end
            updateFrequencySpecsControls(this,settings,fNyquist);

            if settings.FrequencyUnitsValue=="Hz"
                setSampleRateValue(this,settings.SampleRate,settings.SampleRateSource);
                setSampleRateVisible(this,true);
            else
                setSampleRateVisible(this,false);
            end
            setControlValue(this,'FrequencyUnits',settings.FrequencyUnitsValue);
        end

        function updateMagnitudeConstraintsSettings(this,settings)


            if settings.OrderMode=="minimum"
                setMagnitudeConstraintsVisible(this,false);
            else
                setMagnitudeConstraintsVisible(this,true);
                setPopupItems(this,'MagnitudeConstraints',settings.PopupItems,...
                settings.PopupItemsData,settings.PopupValue);
            end
            updateMagnitudeSpecsControls(this,settings);
        end

        function updateAlgorithmsSettings(this,settings)
            import signal.task.internal.designfilt.msgid2txt


            m=strrep(settings.MethodPopupItems,' ','');
            m=strrep(m,'-','');
            for idx=1:numel(m)
                m{idx}=msgid2txt(m{idx});
            end

            setPopupItems(this,'DesignMethod',m,settings.MethodPopupItemsData,...
            settings.MethodPopupValue);

            updateDesignOptionsSettings(this,settings);
        end

        function updateDesignOptionsSettings(this,settings)
            import signal.task.internal.BaseTask

            designOpts=settings.DesignOptions;

            if isempty(this.DesignOptionsPanel)&&~isempty(designOpts)
                [this.DesingOptionsPanelParent,this.DesignOptionsPanel]=addDesignOptionsGroup(this,this.AlgorithmGrid);
            end



            if~isfield(settings,'DesignOptionsUpdateOnly')||~settings.DesignOptionsUpdateOnly


                if~isempty(this.DesignOptionsPanel)
                    grid=this.DesignOptionsPanel.Children;
                    if~isempty(grid)
                        controls=grid.Children;
                        for idx=1:numel(controls)
                            controls(idx).Parent=[];
                        end
                        grid.Parent=[];
                    end
                end
            end




            if isempty(designOpts)
                if~isempty(this.DesignOptionsPanel)
                    this.DesignOptionsPanel.Parent=[];
                end
            else
                if isempty(this.DesignOptionsPanel.Parent)
                    this.DesignOptionsPanel.Parent=this.DesingOptionsPanelParent;
                end
                designMethod=settings.MethodPopupValue;
                addDesignOptionsControlsAndUpdateSettings(this,designOpts,designMethod);
            end
        end

        function addDesignOptionsControlsAndUpdateSettings(this,designOpts,designMethod)


            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt

            numOptions=numel(designOpts)/2;

            if isempty(this.DesignOptionsGrid)
                grid=BaseTask.createAccordionPanelSubGrid(this.DesignOptionsPanel,numOptions,4,'DesignOptionsGrid');
                grid.RowHeight=repmat({'fit'},1,numOptions);
                grid.ColumnWidth={'fit',this.UIEDITFIELD_WIDTH,0,0};
                grid.Padding=[0,0,0,10];
                this.DesignOptionsGrid=grid;
            elseif isempty(this.DesignOptionsGrid.Parent)
                this.DesignOptionsGrid.Parent=this.DesignOptionsPanel;
            end
            grid=this.DesignOptionsGrid;

            for idx=1:numOptions
                option=designOpts(2*idx-1);
                value=designOpts(2*idx);
                rowIdx=idx;
                ctrl=[];
                switch option
                case "MinOrder"

                    BaseTask.createLabel(grid,msgid2txt('MinOrderLabel'),'MinOrderLabel',rowIdx,1);

                    ctrl=uidropdown(grid,...
                    'Tooltip',msgid2txt('MinOrderDropDownTooltip'),...
                    'Items',{msgid2txt('Any'),msgid2txt('Even')},...
                    'ItemsData',{'Any','Even'},...
                    'Value',value,...
                    'Editable',false,'Tag','MinOrderDropDown');
                    this.setLayout(ctrl,rowIdx,2);

                case{"ScalePassband","Zerophase"}






                    ctrl=findall(this.DesignOptionsPanel,'Tag',string(option)+"checkbox");
                    if isempty(ctrl)
                        ctrl=uicheckbox(grid,...
                        'Text',msgid2txt(option),...
                        'Tag',string(option)+"checkbox",...
                        'Value',value=="true");
                        this.setLayout(ctrl,rowIdx,1);
                    end

                case{"Wpass","Wstop","Wpass1","Wstop1","Wpass2","Wstop2"}

                    BaseTask.createLabel(grid,msgid2txt(option),option+"Label",rowIdx,1);

                    ctrl=uieditfield(grid,'numeric','Limits',[0,Inf],...
                    'LowerLimitInclusive','off','UpperLimitInclusive','off',...
                    'ValueDisplayFormat',this.UIEDITFIELD_PRECISION,...
                    'Tag',option+"EditField",'Value',str2double(value));
                    this.setLayout(ctrl,rowIdx,2);

                case{"PassbandOffset","PassbandOffset1","PassbandOffset2"}

                    BaseTask.createLabel(grid,msgid2txt(option),option+"Label",rowIdx,1);

                    ctrl=uieditfield(grid,'numeric','Limits',[0,Inf],...
                    'LowerLimitInclusive','on','UpperLimitInclusive','off',...
                    'ValueDisplayFormat',this.UIEDITFIELD_PRECISION,...
                    'Tag',option+"EditField",'Value',str2double(value));
                    this.setLayout(ctrl,rowIdx,2);

                case "Window"


                    value=char(value);
                    handleIdx=strfind(value,'@');
                    if isempty(handleIdx)
                        windowTypeValue=value;
                        windowParamValue=50;
                    else
                        commaIdx=strfind(value,',');
                        windowTypeValue=value(handleIdx+1:commaIdx-1);
                        bracketIdx=strfind(value,'}');
                        windowParamValue=str2double(value(commaIdx+1:bracketIdx-1));
                    end


                    ctrl=findall(this.DesignOptionsPanel,'Tag','WindowDropDown');
                    if isempty(ctrl)
                        BaseTask.createLabel(grid,msgid2txt(option),option+"Label",rowIdx,1);


                        windowItemsData={'hamming','hann','kaiser',...
                        'rectwin','chebwin','bartlett','blackman',...
                        'flattopwin','gausswin','nuttallwin','triang'};

                        windowItems={msgid2txt('hamming'),msgid2txt('hann'),...
                        msgid2txt('kaiser'),msgid2txt('rectwin'),...
                        msgid2txt('chebwin'),msgid2txt('bartlett'),...
                        msgid2txt('blackman'),msgid2txt('flattopwin'),...
                        msgid2txt('gausswin'),msgid2txt('nuttallwin'),...
                        msgid2txt('triang')};

                        ctrl=uidropdown(grid,...
                        'Tooltip',msgid2txt('WindowDropDownTooltip'),...
                        'Items',windowItems,...
                        'ItemsData',windowItemsData,...
                        'Value',windowTypeValue,...
                        'Editable',false,'Tag','WindowDropDown');
                        this.setLayout(ctrl,rowIdx,2);
                    end



                    winParamEditField=findall(this.DesignOptionsPanel,'Tag','WindowParamEditField');
                    if isempty(winParamEditField)
                        BaseTask.createLabel(grid,msgid2txt('WindowParam'),'WindowParamLabel',rowIdx,3);
                        winParamEditField=uieditfield(grid,'numeric','Limits',[0,Inf],...
                        'LowerLimitInclusive','on','UpperLimitInclusive','off',...
                        'ValueDisplayFormat',this.UIEDITFIELD_PRECISION,...
                        'Tag',"WindowParamEditField");
                        this.setLayout(winParamEditField,rowIdx,4);
                        cbFcn=@(src,evtData)onChange(this,evtData,'WindowParameter');
                        winParamEditField.ValueChangedFcn=cbFcn;
                    end


                    if any(strcmp(windowTypeValue,{'kaiser','chebwin'}))
                        grid.ColumnWidth(3:4)={'fit',this.UIEDITFIELD_WIDTH};
                    else
                        grid.ColumnWidth(3:4)={0,0};
                    end


                    winParamEditField.UserData=windowTypeValue;
                    winParamEditField.Value=windowParamValue;

                    ctrl.Value=windowTypeValue;

                case "MatchExactly"

                    BaseTask.createLabel(grid,msgid2txt('MatchExactlyLabel'),'MatchExactlyLabel',rowIdx,1);

                    if strcmp(designMethod,'Elliptic')
                        items={msgid2txt('Passband'),msgid2txt('Stopband'),msgid2txt('Both')};
                        itemsData={'Passband','Stopband','Both'};
                    else
                        items={msgid2txt('Passband'),msgid2txt('Stopband')};
                        itemsData={'Passband','Stopband'};
                    end
                    ctrl=uidropdown(grid,...
                    'Tooltip',msgid2txt('MatchExactlyDropDownTooltip'),...
                    'Items',items,...
                    'ItemsData',itemsData,...
                    'Value',value,...
                    'Editable',false,'Tag','MatchExactlyDropDown');
                    this.setLayout(ctrl,rowIdx,2);
                end

                if~isempty(ctrl)
                    cbFcn=@(src,evtData)onChange(this,evtData,option);
                    ctrl.ValueChangedFcn=cbFcn;
                end
            end
        end
    end





    methods(Access=protected)
        function addControlsCallbacks(this,controlList)



            for idx=1:size(controlList,1)
                cbFcn=@(src,evtData)onChange(this,evtData,controlList(idx,2));
                if~isempty(this.(controlList(idx,1)))
                    this.(controlList(idx,1)).ValueChangedFcn=cbFcn;
                end
            end
        end

        function onChange(this,evtData,whatChanged)
            sucessFlag=validateChange(this,evtData,whatChanged);
            if sucessFlag
                notifyChange(this,evtData,whatChanged)
            end
        end

        function notifyChange(this,evtData,whatChanged)
            import signal.task.internal.EventData
            data.EventData=evtData;
            data.WhatChanged=whatChanged;
            this.notify("responseViewChange",EventData(data));
        end

        function successFlag=validateChange(~,evtData,whatChanged)
            successFlag=true;
            if whatChanged=="InputSampleRate"






                if evtData.Edited
                    value=evtData.Source.WorkspaceValue;
                    successFlag=...
                    signal.task.internal.designfilt.responseviews.BaseResponseView.isPositiveFiniteNumber(value);
                    if~successFlag
                        evtData.Source.Value=evtData.PreviousValue;
                    end
                end
            end
        end
    end
end