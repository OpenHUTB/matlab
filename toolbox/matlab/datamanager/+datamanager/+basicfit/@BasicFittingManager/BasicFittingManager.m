classdef BasicFittingManager<handle

    properties(Access={?tbasicfit,?tBasicFittingManager,?tBasicFitDialog})

ParentFigure

        BasicFitDialog datamanager.basicfit.BasicFitDialog
    end


    methods(Access=public)


        function this=BasicFittingManager(parentFigure)
            if~isempty(basicfitdatastat('bfitFindProp',parentFigure,'Basic_Fit_GUI_Object'))&&...
                ~isempty(parentFigure.Basic_Fit_GUI_Object)
                this=parentFigure.Basic_Fit_GUI_Object;
                if isvalid(parentFigure)&&this.isBasicFitDialogClosed()

                    this.initFitData();
                end
                this.BasicFitDialog.bringToFront();

            else
                this.ParentFigure=parentFigure;
                this.BasicFitDialog=datamanager.basicfit.BasicFitDialog(this,this.ParentFigure);
                if isvalid(parentFigure)
                    this.initFitData();
                end
            end
        end


        function delete(this)
            delete(this.BasicFitDialog);
        end



        function closeBasicFit(this)
            if isvalid(this)
                basicfitdatastat('bfitcleanup',this.ParentFigure,1);
            end

            this.delete();
        end



        function enableBasicFitFromM(this)
            this.BasicFitDialog.bringToFront();
        end



        function state=isBasicFitDialogClosed(this)
            state=this.BasicFitDialog.isClosed();
        end


        function changeData(this,dataObjs,dispNames,~,~,selectedFits,viewState,...
            evaluatedData,~,~,~,results)
            this.BasicFitDialog.updateView(dataObjs,dispNames,selectedFits,viewState,evaluatedData,results);
        end
    end


    methods(Static,Access={?datamanager.basicfit.BasicFitDialog,?tBasicFittingManager})



        function openHelpPage()
            basicfitdatastat("bfithelp","bf");
        end


        function numericResults=getFitResults(viewState)
            numericResults=basicfitdatastat('bfitcheckfitbox',viewState.SelectedFit,...
            viewState.DataObjects,viewState.CurrentFitIndex,...
            viewState.isEquationOn,viewState.sigDigits,...
            viewState.showResiduals,viewState.ResidPlotType,...
            viewState.IsSubplotLocation,viewState.showRMSE);
        end


        function showEquationCallback(doShowEquation,sigDigits,currentObject,fitIndex)

            guistate=getappdata(currentObject,'Basic_Fit_Results_State');
            guistate.showEquations(fitIndex+1)=doShowEquation;
            setappdata(currentObject,'Basic_Fit_Results_State',guistate);
            basicfitdatastat('bfitcheckshowequations',1,...
            currentObject,str2double(sigDigits));
        end



        function showRMSECallback(doShowRMSESquare,sigDigits,currentObject,fitIndex)
            guistate=getappdata(currentObject,'Basic_Fit_Results_State');
            guistate.showRMSE(fitIndex+1)=doShowRMSESquare;
            setappdata(currentObject,'Basic_Fit_Results_State',guistate);
            basicfitdatastat('bfitcheckshowequations',1,currentObject,str2double(sigDigits));
        end



        function showR2Callback(doShowRSquare,sigDigits,currentObject,fitIndex)
            guistate=getappdata(currentObject,'Basic_Fit_Results_State');
            guistate.showR2(fitIndex+1)=doShowRSquare;
            setappdata(currentObject,'Basic_Fit_Results_State',guistate);
            basicfitdatastat('bfitcheckshowequations',1,currentObject,str2double(sigDigits));
        end


        function reComputeAndShowResiduals(currentObject,doShowResiduals,residualPlotStyle,residualPlotLocation,showResidualsRMSE)
            basicfitdatastat('bfitcheckplotresiduals',doShowResiduals,...
            currentObject,residualPlotStyle,residualPlotLocation,showResidualsRMSE);
        end


        function displayNormOfResiduals(doShowResiduals,currentObject)
            basicfitdatastat('bfitcheckshownormresiduals',doShowResiduals,currentObject);
        end



        function numericResult=updateSignificantDigits(doShowResults,sigDigits,currentObject,fitIndex)
            basicfitdatastat('bfitcheckshowequations',doShowResults,currentObject,sigDigits);
            numericResult=basicfitdatastat('bfitcalcfit',currentObject,fitIndex);
        end
    end

    methods(Access={?datamanager.basicfit.BasicFitDialog,?tBasicFittingManager})
        function initFitData(this)

            try
                [dataObjs,dispNames,~,selectedFits,...
                viewState,evaluatedData,xData,yData,~,results]=basicfitdatastat('bfitopen',this.ParentFigure,'bf');

                this.BasicFitDialog.updateView(dataObjs,dispNames,selectedFits,...
                viewState,evaluatedData,results);
                if~isempty(evaluatedData)&&evaluatedData~=" "
                    this.BasicFitDialog.updateTabularView(table(xData,yData));
                end
            catch ex
                if~strcmpi(ex.identifier,'MATLAB:class:InvalidHandle')
                    close(this.BasicFitDialog.BasicFitFigure);
                    errordlg(ex.message,'Error','modal');
                end
            end
        end


        function dropDownSelectionChanged(this,selectedObject)
            [~,selectedFits,viewState,evaluatedData,xData,yData,~,results]=basicfitdatastat('bfitupdate',this.ParentFigure,selectedObject,1);

            if~isempty(viewState)
                this.BasicFitDialog.setDependentViewState(any(selectedFits));

                this.BasicFitDialog.populateData(viewState,evaluatedData);

                this.BasicFitDialog.updateFitSelectionAndResults(selectedFits,results);
            end
            if~isempty(xData)
                this.BasicFitDialog.updateTabularView(table(xData,yData));
            end
        end


        function normalizeXData(this,isNormalized,currentObject)
            [~,~,results]=basicfitdatastat('bfitnormalizedata',isNormalized,currentObject);
            fitIndex=this.BasicFitDialog.getCurrentFitIndex()+1;
            if~isempty(fitIndex)
                this.BasicFitDialog.FitResults=results;

                this.BasicFitDialog.updateFitResults(results{fitIndex});
            end
        end


        function evaluateAndDisplayNewData(this,evaluatedData,doShowEvalOnPlot,currentObject,fitIndex)
            [xData,yData]=basicfitdatastat('bfitevalfitbutton',currentObject,fitIndex,...
            evaluatedData,doShowEvalOnPlot);
            this.BasicFitDialog.updateTabularView(table(xData,yData));
        end


        function exportResultsToWorkspace(this,currentObject,currentFitIndex)
            if~isempty(this.BasicFitDialog.ExportResultsDialog)&&...
                isvalid(this.BasicFitDialog.ExportResultsDialog)
                delete(this.BasicFitDialog.ExportResultsDialog);
            end
            this.BasicFitDialog.ExportResultsDialog=basicfitdatastat('bfitsavefit',currentObject,currentFitIndex);
        end



        function exportEvaluatedDataToWorkspace(this,currentObject)
            if~isempty(this.BasicFitDialog.ExportEvaluatedDataDialog)&&...
                isvalid(this.BasicFitDialog.ExportEvaluatedDataDialog)
                delete(this.BasicFitDialog.ExportEvaluatedDataDialog);
            end
            this.BasicFitDialog.ExportEvaluatedDataDialog=basicfitdatastat('bfitsaveresults',currentObject);
        end
    end
end