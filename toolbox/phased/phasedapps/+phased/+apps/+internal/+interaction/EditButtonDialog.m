classdef EditButtonDialog<handle







    properties(Access=private)
App
        UIFigure matlab.ui.Figure
        EditSubarrayelementsPanel matlab.ui.container.Panel
        CancelButton matlab.ui.control.Button
        OKButton matlab.ui.control.Button
        ElementWeightsEditField matlab.ui.control.EditField
        ElementWeightsLabel matlab.ui.control.Label
        ElementIndexEditField matlab.ui.control.EditField
        ElementIndexEditFieldLabel matlab.ui.control.Label
CurrentSelection
CurrentName
    end


    methods(Access=private)


        function OKButtonPushed(obj,~)
            setAppStatus(obj.App,true)

            elemIndex=str2num(obj.ElementIndexEditField.Value);
            elemweights=str2num(obj.ElementWeightsEditField.Value);
            if~isequal(numel(elemIndex),numel(elemweights))
                if strcmp(obj.App.Container,'ToolGroup')
                    h=errordlg(getString(message('phased:apps:arrayapp:elemweightscounterr')),...
                    getString(message('phased:apps:arrayapp:errordlg')),...
                    'modal');
                    uiwait(h);
                else
                    uialert(obj.App.ToolGroup,getString(message('phased:apps:arrayapp:elemweightscounterr')),...
                    getString(message('phased:apps:arrayapp:errordlg')));
                end
                obj.OKButton.Enable='off';
                obj.ElementIndexEditField.Value=mat2str(obj.App.ElementIndex{obj.CurrentSelection}');
                obj.ElementWeightsEditField.Value=mat2str(obj.App.SubarrayElementWeights{obj.CurrentSelection});
                return;
            end

            if~isequal(length(elemIndex),length(unique(elemIndex)))
                if strcmp(obj.App.Container,'ToolGroup')
                    h=errordlg(getString(message('phased:apps:arrayapp:elemidxunique')),...
                    getString(message('phased:apps:arrayapp:errordlg')),...
                    'modal');
                    uiwait(h);
                else
                    uialert(obj.App.ToolGroup,getString(message('phased:apps:arrayapp:elemidxunique')),...
                    getString(message('phased:apps:arrayapp:errordlg')));
                end
                obj.OKButton.Enable='off';
                obj.ElementIndexEditField.Value=mat2str(obj.App.ElementIndex{obj.CurrentSelection}');
                obj.ElementWeightsEditField.Value=mat2str(obj.App.SubarrayElementWeights{obj.CurrentSelection});
                return;
            end
            obj.App.ElementIndex{obj.CurrentSelection}=str2num(obj.ElementIndexEditField.Value)';
            obj.App.SubarrayElementWeights{obj.CurrentSelection}=str2num(obj.ElementWeightsEditField.Value);

            [elemIndex,sortbeforeidx]=sort(elemIndex);
            elemweights=elemweights(sortbeforeidx);
            if~isempty(elemIndex)
                obj.App.ElementIndex{obj.CurrentSelection}=elemIndex';
                obj.App.SubarrayElementWeights{obj.CurrentSelection}=elemweights;
                numElem=getNumElements(obj.App.CurrentArray);
                numSubArray=numel(obj.App.ElementIndex);
                selMatrix=zeros(numSubArray,numElem);

                for idx=1:numSubArray
                    selMatrix(idx,sort(obj.App.ElementIndex{idx}))=obj.App.SubarrayElementWeights{idx};
                end
                obj.App.ParametersPanel.AdditionalConfigDialog.SubarraySelection=selMatrix;
                obj.App.CurrentArray.SubarraySelection=selMatrix;
                disableAnalyzeButton(obj.App)
                updateOpenPlots(obj.App)
                updateArrayCharTable(obj.App);
                obj.App.IsChanged=true;
                setAppTitle(obj.App,obj.App.DefaultSessionName)

                idx=numel(obj.App.StoreData);
                obj.App.StoreData{idx+1}=selMatrix;
                obj.App.StoreNames{idx+1}=obj.App.SubarrayLabels.Names;
                obj.App.StoreDataIndex=numel(obj.App.StoreData);
                if obj.App.StoreDataIndex>1
                    obj.App.SubarrayLabels.UndoButton.Enable='on';
                end
                if obj.App.SubarrayLabels.UndoIndex>obj.App.SubarrayLabels.RedoIndex
                    obj.App.SubarrayLabels.RedoButton.Enable='on';
                end
                obj.App.ParametersPanel.AdditionalConfigDialog.SubarraySelection=obj.App.CurrentArray.SubarraySelection;
            end
            delete(obj);
        end


        function ElementIndexEditFieldValueChanged(obj)
            obj.OKButton.Enable='off';
            value=str2num(obj.ElementIndexEditField.Value);%#ok<ST2NM>
            try
                validateattributes(value,{'double'},...
                {'2d','nonempty','nonnan','nonnegative','real','finite','nonzero','nrows',1},'','ElementIndex');
            catch me
                throwError(obj.App,me);
                obj.ElementIndexEditField.Value=mat2str(obj.App.ElementIndex{obj.CurrentSelection}');
                return
            end
            if any(value>size(obj.App.CurrentArray.SubarraySelection,2))
                if strcmp(obj.App.Container,'ToolGroup')
                    h=errordlg(getString(message('phased:apps:arrayapp:elemidxvalid')),...
                    getString(message('phased:apps:arrayapp:errordlg')),...
                    'modal');
                    uiwait(h)
                else
                    uialert(obj.App.ToolGroup,getString(message('phased:apps:arrayapp:elemidxvalid')),...
                    getString(message('phased:apps:arrayapp:errordlg')));
                end
                obj.ElementIndexEditField.Value=mat2str(obj.App.ElementIndex{obj.CurrentSelection}');
                return
            end
            obj.OKButton.Enable='on';
        end


        function ElementWeightsEditFieldValueChanged(obj,~)
            obj.OKButton.Enable='off';
            value=str2num(obj.ElementWeightsEditField.Value);%#ok<ST2NM>
            try
                validateattributes(value,{'double'},{'2d','nonempty','nonnan','nonnegative','real','finite','nonzero','nrows',1},'','SubarrayElementWeights');
            catch me
                throwError(obj.App,me);
                obj.ElementWeightsEditField.Value=mat2str(obj.App.SubarrayElementWeights{obj.CurrentSelection});
                obj.OKButton.Enable='on';
                return
            end
            obj.OKButton.Enable='on';
        end


        function CancelButtonPushed(obj,~)
            delete(obj);
        end

    end


    methods(Access=private)


        function createComponents(obj)
            setAppStatus(obj.App,true);

            obj.UIFigure=uifigure('Visible','off');
            obj.UIFigure.Position=[80,100,472,210];
            obj.UIFigure.Name=getString(message('phased:apps:arrayapp:editsubarraytitle',obj.CurrentName));
            obj.UIFigure.WindowStyle='modal';
            obj.UIFigure.CloseRequestFcn=@(h,e)delete(obj);


            obj.EditSubarrayelementsPanel=uipanel(obj.UIFigure);
            obj.EditSubarrayelementsPanel.Title='';
            obj.EditSubarrayelementsPanel.Position=[1,5,470,210];


            obj.ElementIndexEditFieldLabel=uilabel(obj.EditSubarrayelementsPanel);
            obj.ElementIndexEditFieldLabel.HorizontalAlignment='right';
            obj.ElementIndexEditFieldLabel.Position=[15,130,82,22];
            obj.ElementIndexEditFieldLabel.Text=getString(message('phased:apps:arrayapp:editelemidxlabel'));


            obj.ElementIndexEditField=uieditfield(obj.EditSubarrayelementsPanel,'text');
            obj.ElementIndexEditField.ValueChangedFcn=@(~,~)ElementIndexEditFieldValueChanged(obj);
            obj.ElementIndexEditField.Position=[141,130,268,31];
            obj.ElementIndexEditField.Tag='elementidxedit';
            if numel(obj.App.ElementIndex)<obj.CurrentSelection
                obj.App.ElementIndex{obj.CurrentSelection}=[];
                obj.App.SubarrayElementWeights{obj.CurrentSelection}=[];
            end
            if isequal(numel(obj.App.ElementIndex{obj.CurrentSelection}'),1)
                obj.ElementIndexEditField.Value=strcat('[',mat2str(obj.App.ElementIndex{obj.CurrentSelection}),']');
            elseif iscolumn(obj.App.ElementIndex{obj.CurrentSelection}')
                obj.ElementIndexEditField.Value=mat2str(reshape(obj.App.ElementIndex{obj.CurrentSelection},1,[]));
            else
                obj.ElementIndexEditField.Value=mat2str(obj.App.ElementIndex{obj.CurrentSelection}');
            end

            obj.ElementWeightsLabel=uilabel(obj.EditSubarrayelementsPanel);
            obj.ElementWeightsLabel.HorizontalAlignment='right';
            obj.ElementWeightsLabel.Position=[15,89,96,22];
            obj.ElementWeightsLabel.Text=getString(message('phased:apps:arrayapp:editelemweightslabel'));


            obj.ElementWeightsEditField=uieditfield(obj.EditSubarrayelementsPanel,'text');
            obj.ElementWeightsEditField.ValueChangedFcn=@(~,~)ElementWeightsEditFieldValueChanged(obj);
            obj.ElementWeightsEditField.Position=[141,82,268,26];
            obj.ElementWeightsEditField.Tag='elementweightsedit';
            if isequal(numel(obj.App.ElementIndex{obj.CurrentSelection}'),1)
                obj.ElementWeightsEditField.Value=strcat('[',mat2str(obj.App.SubarrayElementWeights{obj.CurrentSelection}),']');
            else
                obj.ElementWeightsEditField.Value=mat2str(obj.App.SubarrayElementWeights{obj.CurrentSelection});
            end

            obj.OKButton=uibutton(obj.EditSubarrayelementsPanel,'push');
            obj.OKButton.ButtonPushedFcn=@(~,~)OKButtonPushed(obj);
            obj.OKButton.Tag='okbtn';
            obj.OKButton.Position=[80,32,100,22];
            obj.OKButton.Text=getString(message('phased:apps:arrayapp:editOKBtn'));
            obj.OKButton.Enable='off';


            obj.CancelButton=uibutton(obj.EditSubarrayelementsPanel,'push');
            obj.CancelButton.ButtonPushedFcn=@(~,~)CancelButtonPushed(obj);
            obj.CancelButton.Tag='editcancelbutton';
            obj.CancelButton.Position=[254,32,100,22];
            obj.CancelButton.Text=getString(message('phased:apps:arrayapp:editCancelBtn'));


            obj.UIFigure.Visible='on';
        end
    end


    methods(Access=public)


        function obj=EditButtonDialog(varargin)

            obj.App=varargin{1};
            obj.CurrentSelection=varargin{2};
            obj.CurrentName=varargin{3};
            createComponents(obj)
        end


        function delete(obj)
            setAppStatus(obj.App,false);

            delete(obj.UIFigure)
        end
    end
end