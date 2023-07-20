classdef(Hidden,Sealed)SubarrayConfigurationDialog<handle





    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners


GridLayoutLabel
GridLayoutPopup


GridSizeLabel
GridSizeEdit

GridSpacingLabel
GridSpacingEdit
GridSpacingUnits


SubarrayPositionLabel
SubarrayPositionEdit
SubarrayPositionUnits

SubarrayNormalLabel
SubarrayNormalEdit


SubarraySelectionLabel
SubarraySelectionEdit
    end

    properties(Dependent)


GridLayout
GridSize
GridSpacing

SubarrayPosition
SubarrayNormal


SubarraySelection
    end

    properties(Access=private)
Parent
Layout


        ValidGridLayout=getString(message('phased:apps:arrayapp:rectgrid'))
        ValidGridSize=[1,2]
        ValidGridSpacing=[0.5,2]
        ValidSubarrayPosition=[0,0;-0.5,0.5;0,0]
        ValidSubarrayNormal=[0,0;0,0]
        ValidSubarraySelection=[1,1,0,0;0,0,1,1]
    end

    properties(Hidden)
        SubarrayType=getString(message('phased:apps:arrayapp:replicatesubarray'))
    end

    methods
        function obj=SubarrayConfigurationDialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods




        function val=get.GridLayout(obj)
            if~isUIFigure(obj.Parent)
                val=obj.GridLayoutPopup.String{obj.GridLayoutPopup.Value};
            else
                val=obj.GridLayoutPopup.Value;
            end
        end

        function set.GridLayout(obj,str)
            if~isUIFigure(obj.Parent)
                switch str
                case getString(message('phased:apps:arrayapp:rectgrid'))
                    obj.GridLayoutPopup.Value=1;
                case getString(message('phased:apps:arrayapp:customgrid'))
                    obj.GridLayoutPopup.Value=2;
                end
            else
                switch str
                case getString(message('phased:apps:arrayapp:rectgrid'))
                    obj.GridLayoutPopup.Value=getString(message('phased:apps:arrayapp:rectgrid'));
                case getString(message('phased:apps:arrayapp:customgrid'))
                    obj.GridLayoutPopup.Value=getString(message('phased:apps:arrayapp:customgrid'));
                end
            end
        end


        function val=get.SubarrayPosition(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.SubarrayPositionEdit.String);
            else
                val=evalin('base',obj.SubarrayPositionEdit.Value);
            end
        end

        function set.SubarrayPosition(obj,val)
            if~isUIFigure(obj.Parent)
                obj.SubarrayPositionEdit.String=mat2str(val);
            else
                obj.SubarrayPositionEdit.Value=mat2str(val);
            end
        end


        function val=get.SubarrayNormal(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.SubarrayNormalEdit.String);
            else
                val=evalin('base',obj.SubarrayNormalEdit.Value);
            end
        end

        function set.SubarrayNormal(obj,val)
            if~isUIFigure(obj.Parent)
                obj.SubarrayNormalEdit.String=mat2str(val);
            else
                obj.SubarrayNormalEdit.Value=mat2str(val);
            end
        end



        function val=get.GridSize(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.GridSizeEdit.String);
            else
                val=evalin('base',obj.GridSizeEdit.Value);
            end
        end

        function set.GridSize(obj,val)
            if~isUIFigure(obj.Parent)
                obj.GridSizeEdit.String=mat2str(val);
            else
                obj.GridSizeEdit.Value=mat2str(val);
            end
        end


        function val=get.GridSpacing(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.GridSpacingEdit.String);
            else
                val=evalin('base',obj.GridSpacingEdit.Value);
            end
        end

        function set.GridSpacing(obj,val)
            if~isUIFigure(obj.Parent)
                obj.GridSpacingEdit.String=mat2str(val);
            else
                obj.GridSpacingEdit.Value=mat2str(val);
            end
        end




        function val=get.SubarraySelection(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.SubarraySelectionEdit.String);
            else
                val=evalin('base',obj.SubarraySelectionEdit.Value);
            end
        end

        function set.SubarraySelection(obj,val)
            if~isUIFigure(obj.Parent)
                obj.SubarraySelectionEdit.String=mat2str(val);
            else
                obj.SubarraySelectionEdit.Value=mat2str(val);
            end
        end




        function updateArrayObject(obj)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            if obj.Parent.App.IsSubarray
                updateArrayObject(obj.Parent.ArrayDialog);
                sensorArray=obj.Parent.App.CurrentArray;

                if strcmp(obj.SubarrayType,...
                    getString(message('phased:apps:arrayapp:replicatesubarray')))

                    switch obj.GridLayout
                    case getString(message('phased:apps:arrayapp:rectgrid'))
                        if obj.Parent.isUsingLambda(obj.GridSpacingUnits)
                            ratio=propSpeed/freq;
                        else
                            ratio=1;
                        end
                        gridSpacing=obj.GridSpacing*ratio;


                        obj.Parent.App.CurrentArray=phased.ReplicatedSubarray(...
                        'Subarray',sensorArray,...
                        'Layout','Rectangular',...
                        'GridSize',obj.GridSize,...
                        'GridSpacing',gridSpacing);
                    case getString(message('phased:apps:arrayapp:customgrid'))
                        if obj.Parent.isUsingLambda(obj.SubarrayPositionUnits)
                            ratio=propSpeed/freq;
                        else
                            ratio=1;
                        end

                        subarrayPosition=obj.SubarrayPosition*ratio;

                        obj.Parent.App.CurrentArray=phased.ReplicatedSubarray(...
                        'Subarray',sensorArray,...
                        'Layout','Custom',...
                        'SubarrayPosition',subarrayPosition,...
                        'SubarrayNormal',obj.SubarrayNormal);
                    end
                else

                    obj.Parent.App.CurrentArray=phased.PartitionedArray(...
                    'Array',sensorArray,...
                    'SubarraySelection',obj.SubarraySelection);
                end
                updateSubarraySteering(obj.Parent.App);
            else
                updateArrayObject(obj.Parent.ArrayDialog)
            end
        end

        function validParams=verifyParameters(obj)


            SigFreqs=obj.Parent.ElementDialog.SignalFreq;

            if strcmp(obj.SubarrayType,...
                getString(message('phased:apps:arrayapp:replicatesubarray')))

                switch obj.GridLayout
                case getString(message('phased:apps:arrayapp:customgrid'))
                    usingLambda=obj.Parent.isUsingLambda(obj.SubarrayPositionUnits);
                    pos=obj.SubarrayPosition;
                    normal=obj.SubarrayNormal;

                    validSignalFreq=checkValidityOfWaveLengthUnits(obj.Parent,usingLambda,SigFreqs);

                    if size(pos,2)~=size(normal,2)
                        if strcmp(obj.Parent.App.Container,'ToolGroup')
                            h=errordlg(getString(...
                            message('phased:apps:arrayapp:SubarrayNormalError',size(pos,2))),...
                            getString(message('phased:apps:arrayapp:errordlg')),...
                            'modal');
                            uiwait(h)
                        else
                            uialert(obj.Parent.App.ToolGroup,getString(...
                            message('phased:apps:arrayapp:SubarrayNormalError',size(pos,2))),...
                            getString(message('phased:apps:arrayapp:errordlg')));
                        end
                        validSubarrayNormal=false;
                    else
                        validSubarrayNormal=true;
                    end
                    validParams=validSubarrayNormal&&validSignalFreq;
                case getString(message('phased:apps:arrayapp:rectgrid'))
                    usingLambda=obj.Parent.isUsingLambda(obj.GridSpacingUnits);

                    validParams=checkValidityOfWaveLengthUnits(obj.Parent,usingLambda,SigFreqs);

                end
            else
                N=getNumElements(obj.Parent.ArrayDialog);
                cond=size(obj.SubarraySelection,2)~=N;
                if cond
                    if strcmp(obj.Parent.App.Container,'ToolGroup')
                        h=errordlg(getString(message('phased:phased:invalidColumnNumbers',...
                        'SubarraySelection',N)),getString(...
                        message('phased:apps:arrayapp:errordlg')),'modal');
                        uiwait(h);
                    else
                        uialert(obj.Parent.App.ToolGroup,getString(message('phased:phased:invalidColumnNumbers',...
                        'SubarraySelection',N)),getString(...
                        message('phased:apps:arrayapp:errordlg')));
                    end
                    validParams=false;
                else
                    validParams=true;
                end
            end

        end

        function gencode(obj,sw)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            if strcmp(obj.SubarrayType,...
                getString(message('phased:apps:arrayapp:replicatesubarray')))

                addcr(sw,'% Replicate the subarray to form an array');
                addcr(sw,'Array = phased.ReplicatedSubarray(''Subarray'',Array,...');
                addcr(sw,' ''SubarraySteering'',''None'');');

                if strcmp(obj.GridLayout,...
                    getString(message('phased:apps:arrayapp:rectgrid')))
                    addcr(sw,'Array.Layout = ''Rectangular'';');
                    addcr(sw,['Array.GridSize = ',mat2str(obj.GridSize),';']);
                    if obj.Parent.isUsingLambda(obj.GridSpacingUnits)
                        ratio=propSpeed/freq;
                        addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                        addcr(sw,['Array.GridSpacing = ',mat2str(obj.GridSpacing),' .* ',mat2str(ratio),';']);
                    else
                        addcr(sw,['Array.GridSpacing = ',mat2str(obj.GridSpacing),';']);
                    end
                else
                    addcr(sw,'Array.Layout = ''Custom'';');
                    if obj.Parent.isUsingLambda(obj.SubarrayPositionUnits)
                        ratio=propSpeed/freq;
                        addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                        addcr(sw,['Array.SubarrayPosition = ',mat2str(obj.SubarrayPosition),' .* ',mat2str(ratio),';']);
                    else
                        addcr(sw,['Array.SubarrayPosition = ',mat2str(obj.SubarrayPosition),';']);
                    end
                    addcr(sw,['Array.SubarrayNormal = ',mat2str(obj.SubarrayNormal),';']);
                end
            else
                addcr(sw,'% Partition the array');
                addcr(sw,'Array = phased.PartitionedArray(''Array'',Array,...');
                if~isUIFigure(obj.Parent)
                    addcr(sw,[' ''SubarraySelection'',',obj.SubarraySelectionEdit.String,');']);
                else
                    addcr(sw,[' ''SubarraySelection'',',obj.SubarraySelectionEdit.Value,');']);
                end
            end

            switch obj.Parent.App.CurrentArray.SubarraySteering
            case 'None'

            case 'Phase'
                addcr(sw,'Array.SubarraySteering = ''Phase'';');
                addcr(sw,['Array.NumPhaseShifterBits = ',mat2str(obj.Parent.App.SubarrayPhaseQuanBits),';']);
                addcr(sw,['Array.PhaseShifterFrequency = ',mat2str(obj.Parent.App.SubarrayPhaseShifterFreq),';']);
            case 'Time'
                addcr(sw,'Array.SubarraySteering = ''Time'';');
            case 'Custom'
                addcr(sw,'Array.SubarraySteering = ''Custom'';');
            end
        end

        function genreport(obj,sw)
            if strcmp(obj.SubarrayType,...
                getString(message('phased:apps:arrayapp:replicatesubarray')))

                addcr(sw,'% Array Formation ...................................... Replicate Subarray')

                genreport(obj.Parent.ArrayDialog,sw);


                if strcmp(obj.GridLayout,...
                    getString(message('phased:apps:arrayapp:rectgrid')))
                    addcr(sw,'% Grid Layout .......................................... Rectangular');
                    addcr(sw,['% Grid Size  ........................................... ',mat2str(obj.GridSize)]);
                    addcr(sw,['% Grid Spacing (m) ..................................... ',mat2str(obj.GridSpacing)]);
                else
                    addcr(sw,'% Grid Layout .......................................... Custom');
                    addcr(sw,['% Subarray Position (m) ................................ ',mat2str(obj.SubarrayPosition)])
                    addcr(sw,['% Subarray Normal (deg) ................................ ',mat2str(obj.SubarrayNormal)])
                end
            else

                genreport(obj.Parent.ArrayDialog,sw);
                addcr(sw,'% Subarray Formation .................................... Partitioning Array')
            end

            switch obj.Parent.App.CurrentArray.SubarraySteering
            case 'None'
                addcr(sw,'% Subarray Steering Type ............................... None');
            case 'Phase'
                addcr(sw,'% Subarray Steering Type ............................... Phase');
                addcr(sw,['% Subarray Phase Shifter Frequency .................... ',mat2str(obj.Parent.App.SubarrayPhaseShifterFreq)]);
                addcr(sw,['% Subarray Phase Qunatization Bits .................... ',mat2str(obj.Parent.App.SubarrayPhaseQuanBits)]);
            case 'Time'
                addcr(sw,'% Subarray Steering Type ............................... Time');
            case 'Custom'
                addcr(sw,'% Subarray Steering Type ............................... Custom');
            end
        end

        function title=assignArrayDialogTitle(~)

            title=getString(message('phased:apps:arrayapp:additonalsubarrayconfig'));
        end

        function setDefaultParams(obj)

            numElements=getNumElements(obj.Parent.ArrayDialog);

            isApplyButtonEnabled=strcmp(...
            obj.Parent.ApplyDialog.ApplyButton.Enable,'on');
            if strcmp(obj.SubarrayType,getString(message('phased:apps:arrayapp:partitionarray')))
                if rem(numElements,2)~=0

                    lowVal=(numElements+1)/2-1;
                    highVal=(numElements+1)/2;

                    obj.SubarraySelection=[ones(1,(numElements+1)/2-1),zeros(1,(numElements+1)/2);
                    zeros(1,(numElements+1)/2-1),ones(1,(numElements+1)/2)];

                    if~isUIFigure(obj.Parent)
                        obj.SubarraySelectionEdit.String=...
                        ['[ ones(1,',mat2str(lowVal),') zeros(1,',mat2str(highVal),');'...
                        ,' zeros(1,',mat2str(lowVal),') ones(1,',mat2str(highVal),')]'];
                    else
                        obj.SubarraySelectionEdit.Value=...
                        ['[ ones(1,',mat2str(lowVal),') zeros(1,',mat2str(highVal),');'...
                        ,' zeros(1,',mat2str(lowVal),') ones(1,',mat2str(highVal),')]'];
                    end
                else
                    lowVal=(numElements)/2;
                    highVal=numElements/2;

                    obj.SubarraySelection=[ones(1,numElements/2),zeros(ones,numElements/2);
                    zeros(1,numElements/2),ones(1,numElements/2)];

                    if~isUIFigure(obj.Parent)
                        obj.SubarraySelectionEdit.String=...
                        ['[ ones(1,',mat2str(lowVal),') zeros(1,',mat2str(highVal),');'...
                        ,' zeros(1,',mat2str(lowVal),') ones(1,',mat2str(highVal),')]'];
                    else
                        obj.SubarraySelectionEdit.Value=...
                        ['[ ones(1,',mat2str(lowVal),') zeros(1,',mat2str(highVal),');'...
                        ,' zeros(1,',mat2str(lowVal),') ones(1,',mat2str(highVal),')]'];
                    end
                end



                if~isApplyButtonEnabled
                    disableAnalyzeButton(obj.Parent.App);
                end
            end
        end

    end

    methods(Hidden)
        function createUIControls(obj)

            dialogtitle=assignArrayDialogTitle(obj);
            if~isUIFigure(obj.Parent)
                obj.Panel=obj.Parent.createPanel(obj.Parent.App.ParametersFig,...
                dialogtitle,'off');
            else
                obj.Panel=obj.Parent.createPanel(obj.Parent.Layout,...
                dialogtitle,'off');
            end
            obj.Panel.Tag='subarrayPanel';

            hspacing=3;
            vspacing=6;


            obj.Layout=obj.Parent.createLayout(obj.Panel,...
            vspacing,hspacing,...
            [0,0,0,0,0,0,0,0,0,0,1],[0,1,0]);

            if~isUIFigure(obj.Parent)
                parent=obj.Panel;
            else
                parent=obj.Layout;
            end



            obj.GridLayoutLabel=obj.Parent.createTextLabel(parent,...
            getString(message(...
            'phased:apps:arrayapp:gridlayout')),'off');

            layoutpop={getString(message('phased:apps:arrayapp:rectgrid')),...
            getString(message('phased:apps:arrayapp:customgrid'))};

            obj.GridLayoutPopup=obj.Parent.createDropDown(...
            parent,layoutpop,1,...
            getString(message(...
            'phased:apps:arrayapp:gridlayoutTT')),...
            'layoutPopup',@(h,e)parameterChanged(obj,e),'off');


            obj.SubarrayPositionLabel=obj.Parent.createTextLabel(...
            parent,getString(message(...
            'phased:apps:arrayapp:subarraypos')),'off');

            obj.SubarrayPositionEdit=obj.Parent.createEditBox(parent,...
            '[0 0; -0.5 0.5 ;0 0]',...
            getString(message('phased:apps:arrayapp:subarrayposTT')),...
            'subarrayPosEdit',@(h,e)parameterChanged(obj,e),'off');

            subarrayUnits={getString(message('phased:apps:arrayapp:meter')),...
            char(955)};

            obj.SubarrayPositionUnits=obj.Parent.createDropDown(...
            parent,subarrayUnits,1,' ',...
            'subarrayPosUnit',@(h,e)parameterChanged(obj,e),'off');


            obj.SubarrayNormalLabel=obj.Parent.createTextLabel(...
            parent,[getString(message(...
            'phased:apps:arrayapp:subarraynorm')),' ('...
            ,getString(message('phased:apps:arrayapp:degrees')),')'],...
            'off');

            obj.SubarrayNormalEdit=obj.Parent.createEditBox(...
            parent,'[0, 0; 0, 0]',...
            getString(...
            message('phased:apps:arrayapp:subarraynormTT')),...
            'subarrayNormEdit',@(h,e)parameterChanged(obj,e),'off');


            obj.GridSizeLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:gridsize')),...
            'off');

            obj.GridSizeEdit=obj.Parent.createEditBox(...
            parent,'[1 2]',...
            getString(...
            message('phased:apps:arrayapp:gridsizeTT')),...
            'gridSizeEdit',@(h,e)parameterChanged(obj,e),'off');


            obj.GridSpacingLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:gridspacing')),...
            'off');

            obj.GridSpacingEdit=obj.Parent.createEditBox(...
            parent,'[0.5 2]',...
            getString(...
            message('phased:apps:arrayapp:gridspacingTT')),...
            'gridSpacingEdit',@(h,e)parameterChanged(obj,e),'off');

            spacingUnits={getString(message('phased:apps:arrayapp:meter')),...
            char(955)};

            obj.GridSpacingUnits=obj.Parent.createDropDown(...
            parent,spacingUnits,1,' ',...
            'rectGridSpacingUnit',@(h,e)parameterChanged(obj,e),'off');


            obj.SubarraySelectionLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:subarrayselect')),...
            'off');

            obj.SubarraySelectionEdit=obj.Parent.createEditBox(...
            parent,'[1 1 0 0; 0 0 1 1]',...
            getString(...
            message('phased:apps:arrayapp:subarrayselectTT')),...
            'subarraySelectionEdit',@(h,e)parameterChanged(obj,e),'off');
        end

        function layoutUIControls(obj)
            obj.SubarraySelectionLabel.Visible='off';
            obj.SubarraySelectionEdit.Visible='off';
            obj.SubarrayPositionLabel.Visible='off';
            obj.SubarrayPositionEdit.Visible='off';
            obj.SubarrayPositionUnits.Visible='off';
            obj.SubarrayNormalLabel.Visible='off';
            obj.SubarrayNormalEdit.Visible='off';
            obj.GridSizeLabel.Visible='off';
            obj.GridSizeEdit.Visible='off';
            obj.GridSpacingLabel.Visible='off';
            obj.GridSpacingEdit.Visible='off';
            obj.GridSpacingUnits.Visible='off';
            obj.GridLayoutLabel.Visible='off';
            obj.GridLayoutPopup.Visible='off';
            if~isUIFigure(obj.Parent)
                hspacing=3;
                vspacing=6;


                obj.Layout=obj.Parent.createLayout(obj.Panel,...
                vspacing,hspacing,...
                [0,0,0,0,0,0,0,0,0,0,1],[0,1,0]);
                w1=obj.Parent.Width1;
                w2=obj.Parent.Width2;
                w3=obj.Parent.Width3;

                row=1;
                uiControlsHt=24;

                switch obj.SubarrayType
                case getString(message('phased:apps:arrayapp:replicatesubarray'))
                    row=row+1;
                    obj.Parent.addText(obj.Layout,...
                    obj.GridLayoutLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addPopup(obj.Layout,...
                    obj.GridLayoutPopup,row,2,w2,uiControlsHt)

                    obj.GridLayoutLabel.Visible='on';
                    obj.GridLayoutPopup.Visible='on';
                    switch obj.GridLayoutPopup.String{obj.GridLayoutPopup.Value}
                    case getString(message('phased:apps:arrayapp:customgrid'))

                        obj.SubarrayPositionLabel.Visible='on';
                        obj.SubarrayPositionEdit.Visible='on';
                        obj.SubarrayPositionUnits.Visible='on';
                        obj.SubarrayNormalLabel.Visible='on';
                        obj.SubarrayNormalEdit.Visible='on';

                        row=row+1;
                        obj.Parent.addText(obj.Layout,...
                        obj.SubarrayPositionLabel,row,1,w1,uiControlsHt)
                        obj.Parent.addEdit(obj.Layout,...
                        obj.SubarrayPositionEdit,row,2,w2,uiControlsHt)
                        obj.Parent.addPopup(obj.Layout,...
                        obj.SubarrayPositionUnits,row,3,w3,uiControlsHt)

                        row=row+1;
                        obj.Parent.addText(obj.Layout,...
                        obj.SubarrayNormalLabel,row,1,w1,uiControlsHt)
                        obj.Parent.addEdit(obj.Layout,...
                        obj.SubarrayNormalEdit,row,2,w2,uiControlsHt)

                    case getString(message('phased:apps:arrayapp:rectgrid'))

                        obj.GridSizeLabel.Visible='on';
                        obj.GridSizeEdit.Visible='on';
                        obj.GridSpacingLabel.Visible='on';
                        obj.GridSpacingEdit.Visible='on';
                        obj.GridSpacingUnits.Visible='on';

                        row=row+1;
                        obj.Parent.addText(obj.Layout,...
                        obj.GridSizeLabel,row,1,w1,uiControlsHt)
                        obj.Parent.addEdit(obj.Layout,...
                        obj.GridSizeEdit,row,2,w2,uiControlsHt)

                        row=row+1;
                        obj.Parent.addText(obj.Layout,...
                        obj.GridSpacingLabel,row,1,w1,uiControlsHt)
                        obj.Parent.addEdit(obj.Layout,...
                        obj.GridSpacingEdit,row,2,w2,uiControlsHt)
                        obj.Parent.addPopup(obj.Layout,...
                        obj.GridSpacingUnits,row,3,w3,uiControlsHt)
                    end
                case getString(message('phased:apps:arrayapp:partitionarray'))

                    obj.SubarraySelectionLabel.Visible='on';
                    obj.SubarraySelectionEdit.Visible='on';
                    obj.GridLayoutLabel.Visible='off';
                    obj.GridLayoutPopup.Visible='off';

                    row=row+1;
                    obj.Parent.addText(obj.Layout,...
                    obj.SubarraySelectionLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addEdit(obj.Layout,...
                    obj.SubarraySelectionEdit,row,2,w2,uiControlsHt)
                end

                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else

                obj.GridLayoutLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.GridLayoutPopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.SubarrayPositionLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.SubarrayPositionEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.SubarrayPositionUnits.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',3);
                obj.SubarrayNormalLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.SubarrayNormalEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.GridSizeLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.GridSizeEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
                obj.GridSpacingLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',1);
                obj.GridSpacingEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',2);
                obj.GridSpacingUnits.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',3);
                obj.SubarraySelectionLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',1);
                obj.SubarraySelectionEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',2);

                obj.Layout.RowHeight={'fit','fit','fit','fit','fit','fit'};
                switch obj.SubarrayType
                case getString(message('phased:apps:arrayapp:replicatesubarray'))
                    obj.GridLayoutLabel.Visible='on';
                    obj.GridLayoutPopup.Visible='on';
                    switch obj.GridLayoutPopup.Value
                    case getString(message('phased:apps:arrayapp:customgrid'))
                        obj.SubarrayPositionLabel.Visible='on';
                        obj.SubarrayPositionEdit.Visible='on';
                        obj.SubarrayPositionUnits.Visible='on';
                        obj.SubarrayNormalLabel.Visible='on';
                        obj.SubarrayNormalEdit.Visible='on';

                        obj.Layout.RowHeight(4:6)={0,0,0};
                    case getString(message('phased:apps:arrayapp:rectgrid'))
                        obj.GridSizeLabel.Visible='on';
                        obj.GridSizeEdit.Visible='on';
                        obj.GridSpacingLabel.Visible='on';
                        obj.GridSpacingEdit.Visible='on';
                        obj.GridSpacingUnits.Visible='on';
                        obj.Layout.RowHeight([2,3,6])={0,0,0};
                    end
                case getString(message('phased:apps:arrayapp:partitionarray'))
                    obj.SubarraySelectionLabel.Visible='on';
                    obj.SubarraySelectionEdit.Visible='on';
                    obj.Layout.RowHeight(1:5)={0,0,0,0,0};
                end
            end
        end

        function parameterChanged(obj,e)




            prop=e.Source.Tag;
            switch prop
            case 'subarrayPosEdit'
                try
                    sigdatatypes.validate3DCartCoord(...
                    obj.SubarrayPosition,'','Subarray Position');
                    cond=size(obj.SubarrayPosition,2)<2;
                    if cond
                        error(getString(message('phased:system:array:expectMoreColumns','Subarray Position',2)));
                    end
                    obj.ValidSubarrayPosition=obj.SubarrayPosition;
                catch me
                    obj.SubarrayPosition=obj.ValidSubarrayPosition;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'subarrayNormEdit'
                try
                    sigdatatypes.validateAzElAngle(obj.SubarrayNormal,...
                    '','Subarray Normal');
                    cond=size(obj.SubarrayNormal,2)<2;
                    if cond
                        error(getString(message('phased:system:array:expectMoreColumns','SubarrayNormal',2)));
                    end
                    obj.ValidSubarrayNormal=obj.SubarrayNormal;
                catch me
                    obj.SubarrayNormal=obj.ValidSubarrayNormal;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'gridSizeEdit'
                try
                    sigdatatypes.validateIndex(...
                    obj.GridSize,'','Grid Size',{'size',[1,2]});
                    cond=all(obj.GridSize==1);
                    if cond
                        error(getString(message('phased:system:array:invalidSubarrayGridSize','Grid Size')));
                    end
                    obj.ValidGridSize=obj.GridSize;
                catch me
                    obj.GridSize=obj.ValidGridSize;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'gridSpacingEdit'
                try
                    sigdatatypes.validateDistance(...
                    obj.GridSpacing,'','Grid Spacing',...
                    {'size',[1,2],'positive'});
                    obj.ValidGridSpacing=obj.GridSpacing;
                catch me
                    obj.GridSpacing=obj.ValidGridSpacing;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'subarraySelectionEdit'
                try
                    validateattributes(obj.SubarraySelection,{'double'},...
                    {'2d','nonempty','nonnan','finite'},'','Subarray Selection');
                    cond=any(sum(obj.SubarraySelection,2)==0);
                    if cond
                        error(getString(message(...
                        'phased:system:array:expectedNonZeroRows','Subarray Selection')));
                    end
                    obj.ValidSubarraySelection=obj.SubarraySelection;
                catch me
                    obj.SubarraySelection=obj.ValidSubarraySelection;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'layoutPopup'
                if~isUIFigure(obj.Parent)
                    layoutUIControls(obj)
                    remove(obj.Parent.Layout,2,1)
                    add(obj.Parent.Layout,obj.Parent.AdditionalConfigDialog.Panel,2,1,...
                    'MinimumWidth',obj.Width,...
                    'Fill','Horizontal',...
                    'MinimumHeight',obj.Height,...
                    'Anchor','North')

                    update(obj.Parent.Layout,'force');
                else
                    layoutUIControls(obj)
                    adjustLayout(obj.Parent.App);
                end
            end


            enableAnalyzeButton(obj.Parent.App);
        end
    end
end
