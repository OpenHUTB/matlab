classdef(Hidden,Sealed)ApplyChangesController<handle






    properties(Access=private)
pToolStrip
pApp
pParams
    end

    methods
        function obj=ApplyChangesController(varargin)
            obj.pApp=varargin{1}.App;
            obj.pToolStrip=varargin{1}.App.ToolStripDisplay;
            obj.pParams=varargin{1};
        end

        function execute(obj,~,~)


            setAppStatus(obj.pApp,true);



            if~obj.pApp.IsSubarray
                validArrayParams=verifyParameters(obj.pParams.ArrayDialog);
                validTaper=verifyTaper(obj);
                validSubarrayParams=true;
            else
                validSubarrayParams=verifyParameters(obj.pParams.AdditionalConfigDialog);
                if~validSubarrayParams


                    setAppStatus(obj.pApp,false);
                    return
                end
                validArrayParams=verifyParameters(obj.pParams.ArrayDialog);
                validTaper=verifyTaper(obj);
            end


            if isa(obj.pParams.ElementDialog,'phased.apps.internal.elementDialogs.CustomAntennaDialog')||...
                isa(obj.pParams.ElementDialog,'phased.apps.internal.elementDialogs.CustomPolarizedAntennaDialog')||...
                isa(obj.pParams.ElementDialog,'phased.apps.internal.elementDialogs.CustomMicrophoneDialog')
                validElementParams=verifyParameters(obj.pParams.ElementDialog);
            else
                validElementParams=true;
            end

            if validElementParams

                try
                    updateElementObject(obj.pParams.ElementDialog)
                catch me
                    throwError(obj.pApp,me);
                    setAppStatus(obj.pApp,false);
                    return;
                end
                if isa(obj.pApp.CurrentArray,'phased.internal.AbstractArray')
                    obj.pApp.CurrentArray.Element=obj.pApp.CurrentElement;
                elseif isa(obj.pApp.CurrentArray,'phased.PartitionedArray')
                    obj.pApp.CurrentArray.Array.Element=obj.pApp.CurrentElement;
                else
                    obj.pApp.CurrentArray.Subarray.Element=obj.pApp.CurrentElement;
                end
            end

            if validArrayParams&&validTaper&&validSubarrayParams
                if~obj.pApp.IsSubarray

                    updateArrayObject(obj.pParams.ArrayDialog);
                    obj.pApp.ParametersPanel.ArrayDialog.Panel.Title=...
                    assignArrayDialogTitle(obj.pApp.ParametersPanel.ArrayDialog);
                    disableSubarraySteeringOptions(obj.pApp)
                else
                    updateArrayObject(obj.pParams.AdditionalConfigDialog);
                    obj.pApp.ParametersPanel.ArrayDialog.Panel.Title=...
                    assignArrayDialogTitle(obj.pApp.ParametersPanel.ArrayDialog);
                    enableSubarraySteeringOptions(obj.pApp)

                    weights=evalin('base',...
                    obj.pApp.ToolStripDisplay.SubarrayCustomWeightEdit.Value);
                    if isscalar(weights)

                        computeElementWeights(obj.pApp,weights);
                    else



                        try
                            validateElementWeights(obj.pApp,weights);
                        catch
                            obj.pApp.ToolStripDisplay.SubarrayCustomWeightEdit.Value='1';
                            computeElementWeights(obj.pApp,1);
                        end
                    end
                end

                disablAndEnableGratingLobe(obj.pApp)
            end


            validSteerPhase=verifySteerAndPhaseShiftBits(obj.pApp);
            validElLimit=verifyElementLimit(obj);

            if isa(obj.pApp.CurrentArray,'phased.PartitionedArray')
                if~isempty(obj.pApp.SubarrayLabels)
                    clear(obj.pApp.SubarrayLabels);
                end
                selMatrix=obj.pParams.AdditionalConfigDialog.SubarraySelection;
                obj.pApp.ElementIndex=[];
                obj.pApp.SubarrayElementWeights=[];
                [r,~]=size(selMatrix);
                for i=1:r
                    obj.pApp.ElementIndex{i}=find(selMatrix(i,:)');
                    obj.pApp.SubarrayElementWeights{i}=selMatrix(i,obj.pApp.ElementIndex{i});
                end
                Labelposition=[0,0,obj.pApp.SubarrayPartitionFig.Position(3:4)];
                obj.pApp.SubarrayLabels=phased.apps.internal.interaction.SubarrayLabels(obj.pApp,Labelposition);
            end



            if validArrayParams&&validElementParams&&validSteerPhase...
                &&validTaper&&validElLimit&&validSubarrayParams

                updateOpenPlots(obj.pApp)
                updateArrayCharTable(obj.pApp)
                obj.pApp.IsChanged=true;
                setAppTitle(obj.pApp,obj.pApp.DefaultSessionName)


                disableAnalyzeButton(obj.pApp);
            end


            setAppStatus(obj.pApp,false);
        end
    end

    methods(Access=protected)
        function validLimit=verifyElementLimit(obj)

            numElm=getNumElements(obj.pApp.CurrentArray);

            if numElm>obj.pParams.NumElLimit
                if strcmp(obj.pApp.Container,'ToolGroup')
                    choice=questdlg(getString(message('phased:apps:arrayapp:warnstring')),...
                    getString(message('phased:apps:arrayapp:warndlgName')),...
                    getString(message('phased:apps:arrayapp:yes')),...
                    getString(message('phased:apps:arrayapp:no')),...
                    getString(message('phased:apps:arrayapp:no')));
                else

                    setAppStatus(obj.pApp,false);
                    choice=uiconfirm(obj.pApp.ToolGroup,...
                    getString(message('phased:apps:arrayapp:warnstring')),...
                    getString(message('phased:apps:arrayapp:warndlgName')),...
                    'Options',{getString(message('phased:apps:arrayapp:yes')),...
                    getString(message('phased:apps:arrayapp:no'))},...
                    'DefaultOption',getString(message('phased:apps:arrayapp:no')));
                end
                if strcmp(choice,getString(message('phased:apps:arrayapp:no')))
                    validLimit=false;
                    return
                else

                    setAppStatus(obj.pApp,true);

                    obj.pParams.NumElLimit=numElm;
                    validElLimit=true;
                end
            else
                validElLimit=true;
            end





            cond=~isempty(obj.pApp.Pattern3DFig);

            if cond&&numElm>obj.pParams.NumElLimit3D
                if strcmp(obj.pApp.Container,'ToolGroup')
                    choice=questdlg(getString(message('phased:apps:arrayapp:warn3dplotstring')),...
                    getString(message('phased:apps:arrayapp:warndlgName')),...
                    getString(message('phased:apps:arrayapp:yes')),...
                    getString(message('phased:apps:arrayapp:no')),...
                    getString(message('phased:apps:arrayapp:no')));
                else

                    setAppStatus(obj.pApp,false);
                    choice=uiconfirm(obj.pApp.ToolGroup,...
                    getString(message('phased:apps:arrayapp:warn3dplotstring')),...
                    getString(message('phased:apps:arrayapp:warndlgName')),...
                    'Options',{getString(message('phased:apps:arrayapp:yes')),...
                    getString(message('phased:apps:arrayapp:no'))},...
                    'DefaultOption',getString(message('phased:apps:arrayapp:no')));
                end
                if strcmp(choice,getString(message('phased:apps:arrayapp:no')))
                    validLimit=false;
                    return
                else

                    setAppStatus(obj.pApp,true);
                    validEl3D=true;
                end

                obj.pParams.NumElLimit3D=numElm;
            else
                validEl3D=true;
            end

            validLimit=validElLimit&&validEl3D;
        end

        function validTaper=verifyTaper(obj)



            if~isa(obj.pParams.ArrayDialog,'phased.apps.internal.arrayDialogs.CircularPlanarDialog')
                numElm=getNumElements(obj.pParams.ArrayDialog);
            else
                try
                    numElm=getNumElements(obj.pParams.ArrayDialog);
                catch me
                    throwError(obj.pApp,me);
                    validTaper=false;
                    return;
                end
            end

            isCustomRowColumnTaper=false;
            if isa(obj.pParams.ArrayDialog,'phased.apps.internal.arrayDialogs.URADialog')
                if strcmp(obj.pParams.ArrayDialog.TaperInputType,getString(message('phased:apps:arrayapp:Custom')))
                    isCustomTaper=true;
                    Taper=obj.pParams.ArrayDialog.CustomTaper;
                else
                    isCustomTaper=false;
                    isCustomRowColumnTaper=true;
                    if strcmp(obj.pParams.ArrayDialog.RowTaper,getString(message('phased:apps:arrayapp:Custom')))
                        isCustomRowTaper=true;
                        RowTaper=obj.pParams.ArrayDialog.RowCustomTaper;
                        ColumnTaper=obj.pParams.ArrayDialog.ColumnCustomTaper;
                    else
                        isCustomRowTaper=false;
                    end
                    if strcmp(obj.pParams.ArrayDialog.ColumnTaper,getString(message('phased:apps:arrayapp:Custom')))
                        isCustomColumnTaper=true;
                        RowTaper=obj.pParams.ArrayDialog.RowCustomTaper;
                        ColumnTaper=obj.pParams.ArrayDialog.ColumnCustomTaper;
                    else
                        isCustomColumnTaper=false;
                    end
                    validTaper=true;
                end
            elseif isa(obj.pParams.ArrayDialog,'phased.apps.internal.arrayDialogs.ULADialog')
                if strcmp(obj.pParams.ArrayDialog.Taper,getString(message('phased:apps:arrayapp:Custom')))
                    isCustomTaper=true;
                    Taper=obj.pParams.ArrayDialog.CustomTaper;
                else
                    isCustomTaper=false;
                    validTaper=true;
                end
            else
                isCustomTaper=true;
                Taper=obj.pParams.ArrayDialog.Taper;
            end

            if isCustomTaper&&~isCustomRowColumnTaper
                if isa(obj.pApp.CurrentArray,'phased.URA')
                    sz=obj.pParams.ArrayDialog.Size;
                    cond=~isscalar(Taper)&&any(size(Taper)~=sz)...
                    &&any(size(Taper)~=[1,sz(1)*sz(2)])...
                    &&any(size(Taper)~=[sz(1)*sz(2),1]);
                    if cond
                        if strcmp(obj.pApp.Container,'ToolGroup')
                            h=errordlg(getString(...
                            message('phased:apps:arrayapp:errorURACustomTaper',...
                            sprintf('%d',sz(1)*sz(2)),...
                            sprintf('%d %d',sz(1),sz(2)))),...
                            getString(message(...
                            'phased:apps:arrayapp:errordlg')),'modal');
                            uiwait(h)
                        else
                            uialert(obj.pApp.ToolGroup,getString(...
                            message('phased:apps:arrayapp:errorURACustomTaper',...
                            sprintf('%d',sz(1)*sz(2)),...
                            sprintf('%d %d',sz(1),sz(2)))),...
                            getString(message(...
                            'phased:apps:arrayapp:errordlg')));
                        end
                        validTaper=false;
                        return;
                    else
                        validTaper=true;
                    end
                else
                    if~isscalar(Taper)&&length(Taper)~=numElm
                        if strcmp(obj.pApp.Container,'ToolGroup')
                            h=errordlg(getString(...
                            message('phased:apps:arrayapp:errorTaper')),...
                            getString(message(...
                            'phased:apps:arrayapp:errordlg')),'modal');
                            uiwait(h)
                        else
                            uialert(obj.pApp.ToolGroup,getString(...
                            message('phased:apps:arrayapp:errorTaper')),...
                            getString(message(...
                            'phased:apps:arrayapp:errordlg')));
                        end
                        validTaper=false;
                        return;
                    else
                        validTaper=true;
                    end
                end
            elseif~isCustomTaper&&isCustomRowColumnTaper
                if isa(obj.pApp.CurrentArray,'phased.URA')
                    rowSize=obj.pParams.ArrayDialog.Size(1);
                    columnSize=obj.pParams.ArrayDialog.Size(2);

                    if isCustomRowTaper&&~isscalar(RowTaper)&&length(RowTaper)~=columnSize
                        if strcmp(obj.pApp.Container,'ToolGroup')
                            h=errordlg(getString(...
                            message('phased:apps:arrayapp:RowCustomTaperError',columnSize)),...
                            getString(message(...
                            'phased:apps:arrayapp:errordlg')),'modal');
                            uiwait(h)
                        else
                            uialert(obj.pApp.ToolGroup,getString(...
                            message('phased:apps:arrayapp:RowCustomTaperError',columnSize)),...
                            getString(message(...
                            'phased:apps:arrayapp:errordlg')))
                        end
                        validTaper=false;
                        return;
                    end

                    if isCustomColumnTaper&&~isscalar(ColumnTaper)&&length(ColumnTaper)~=rowSize
                        if strcmp(obj.pApp.Container,'ToolGroup')
                            h=errordlg(getString(...
                            message('phased:apps:arrayapp:ColumnCustomTaperError',rowSize)),...
                            getString(message(...
                            'phased:apps:arrayapp:errordlg')),'modal');
                            uiwait(h)
                        else
                            uialert(obj.pApp.ToolGroup,getString(...
                            message('phased:apps:arrayapp:ColumnCustomTaperError',rowSize)),...
                            getString(message(...
                            'phased:apps:arrayapp:errordlg')))
                        end
                        validTaper=false;
                        return;
                    end
                end
            end
        end
    end

end