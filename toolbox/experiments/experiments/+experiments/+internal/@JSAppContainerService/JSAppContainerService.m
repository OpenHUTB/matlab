classdef JSAppContainerService<handle

    properties(SetAccess=private)
appContainer
visualizationPanel
autoDelete
        isRendering=false
pendingVisualization
    end

    methods(Access={?matlab.unittest.TestCase})
        function fig=openFigure(~,filename)
            fig=openfig(filename,'invisible');
            set(findall(fig,'type','axes'),'ContentsVisible',true,'Visible',true);
        end
    end

    methods
        function appContainerInitialize(self,appId)



            delete(self.visualizationPanel);




            prevWarning=warning('off','MATLAB:class:DestructorError');
            cleanupWarning=onCleanup(@()warning(prevWarning));
            delete(self.appContainer);
            clear cleanupWarning;

            self.appContainer=matlab.ui.container.internal.AppContainer('Tag',appId);
            self.appContainer.attach();
            self.visualizationPanel=matlab.ui.internal.FigurePanel(...
            'Tag','visualization_panel',...
            'Title',message('experiments:manager:VisualizationsPanelTitle').getString(),...
            'Closable',true,...
            'Contextual',true,...
            'Region','bottom',...
            'PreferredHeight',300);
            self.appContainer.add(self.visualizationPanel);
        end

        function delete(self)


            delete(self.visualizationPanel);




            prevWarning=warning('off','MATLAB:class:DestructorError');
            cleanupWarning=onCleanup(@()warning(prevWarning));
            delete(self.appContainer);
        end

        function appContainerResetVisualization(self)
            self.scheduleVisualization(@resetVisualization);
        end

        function appContainerShowMessage(self,msg)
            self.scheduleVisualization(@showMessage,msg);
        end

        function appContainerShowTrainingPlot(self,runID,trialIndx)
            self.scheduleVisualization(@showTrainingPlot,runID,trialIndx);
        end

        function appContainerShowConfusionChart(self,runID,trialIndx)
            self.scheduleVisualization(@showConfusionChart,runID,trialIndx);
        end

        function appContainerShowConfusionChartUsingValidationData(self,runID,trialIndx)
            self.scheduleVisualization(@showConfusionChartUsingValidationData,runID,trialIndx);
        end

        function appContainerShowROCCurve(self,runID,trialIndx)
            self.scheduleVisualization(@showROCCurve,runID,trialIndx);
        end

        function appContainerShowROCCurveUsingValidationData(self,runID,trialIndx)
            self.scheduleVisualization(@showROCCurveUsingValidationData,runID,trialIndx);
        end

        function setVisualizationAutoDelete(self)
            self.autoDelete=true;
        end

        function generateConfusionChart_V1(self,label,trainedModel,data,responseName,title,trainingType)
            [YPredicted,labels,~,errorLabel,~]=experiments.internal.generateInputsForConfusionMatrix(trainedModel,data,responseName,trainingType);
            try

                if~isempty(errorLabel)
                    error(message(errorLabel));
                end

                self.generateConfusionChart(labels,YPredicted,title);
            catch ME
                label=message(label).getString();
                msg=message('experiments:results:NoVisualizationAvailableAndReason',label,ME.message).getString();
                self.showMessage(msg);
            end

        end

        function generateROCCurve_V1(self,label,trainedModel,data,responseName,title,trainingType)
            [~,actualLabels,scores,~,errorLabel]=experiments.internal.generateInputsForConfusionMatrix(trainedModel,data,responseName,trainingType);
            try

                if~isempty(errorLabel)
                    error(message(errorLabel));
                end

                self.generateROCCurve(actualLabels,scores,order,title);
            catch ME
                label=message(label).getString();
                msg=message('experiments:results:NoVisualizationAvailableAndReason',label,ME.message).getString();
                self.showMessage(msg);
            end

        end

        function generateConfusionChart(self,labels,YPredicted,title)

            title=regexprep(title,'[{}_^\\]','\\$0');


            self.showVisualization(...
            @(f)confusionchart(f,labels,YPredicted,'Title',title,'RowSummary','row-normalized','ColumnSummary','column-normalized'),...
            true);
        end

        function generateROCCurve(self,xArray,yArray,tArray,aucArray,order,titleForROCCurve)

            titleForROCCurve=regexprep(titleForROCCurve,'[{}_^\\]','\\$0');


            function plotROCCurveInPanel(f)




                rocCurve=experiments.internal.visualizations.ROCCurve(...
                f,...
                "parentPanel",f,...
                "titleForROCCurvePlot",titleForROCCurve,...
                "menuType","listBox",...
                "menuValues",order,...
                "xArray",xArray,...
                "yArray",yArray,...
                "tArray",tArray,...
                "aucArray",aucArray...
                );

            end


            self.showVisualization(...
            @plotROCCurveInPanel,...
            true);
        end

        function displayConfusionChart(self,label,validation,runID,trialIndx)
            runDir=self.getResultsDir();
            filePathForInput=fullfile(runDir,runID,['Trial_',num2str(trialIndx)],'input.mat');
            confusionMatInfoFile=fullfile(runDir,runID,['Trial_',num2str(trialIndx)],'confusionmatrix.mat');

            if exist(filePathForInput,'file')


                warning('off','MATLAB:load:variableNotFound');

                x=load(filePathForInput,'trainingData');

                warning('on','MATLAB:load:variableNotFound');
                if isfield(x,'trainingData')
                    self.displayConfusionChart_V1(label,validation,runID,trialIndx);
                else
                    self.displayConfusionChart_V2(label,validation,runID,trialIndx)
                end
            elseif exist(confusionMatInfoFile,'file')
                self.displayConfusionChart_V2(label,validation,runID,trialIndx)
            else
                label=message(label).getString();
                msg=message('experiments:results:NoVisualizationAvailable',label).getString();
                self.showMessage(msg);
            end

        end

        function displayROCCurve(self,label,validation,runID,trialIndx)
            runDir=self.getResultsDir();
            filePathForInput=fullfile(runDir,runID,['Trial_',num2str(trialIndx)],'input.mat');
            ROCCurveInfoFile=fullfile(runDir,runID,['Trial_',num2str(trialIndx)],'roccurve.mat');


            if exist(filePathForInput,'file')


                warning('off','MATLAB:load:variableNotFound');

                x=load(filePathForInput,'trainingData');

                warning('on','MATLAB:load:variableNotFound');
                if isfield(x,'trainingData')
                    self.displayROCCurve_V1(label,validation,runID,trialIndx);
                else
                    self.displayROCCurve_V2(label,validation,runID,trialIndx)
                end
            elseif exist(ROCCurveInfoFile,'file')
                self.displayROCCurve_V2(label,validation,runID,trialIndx)
            else
                label=message(label).getString();
                msg=message('experiments:results:NoVisualizationAvailable',label).getString();
                self.showMessage(msg);
            end

        end

        function displayConfusionChart_V1(self,label,validation,runID,trialIndx)
            runDir=self.getResultsDir();
            filePathForOutput=fullfile(runDir,runID,['Trial_',num2str(trialIndx)],'output.mat');
            filePathForInput=fullfile(runDir,runID,['Trial_',num2str(trialIndx)],'input.mat');

            if(~exist(filePathForOutput,'file'))
                label=message(label).getString();
                msg=message('experiments:results:NoVisualizationAvailable',label).getString();
                self.showMessage(msg);
                return;
            end

            self.showMessage(message('experiments:results:GeneratingConfusionMatrix').getString(),true);
            title=self.getTitle(label,runID,trialIndx);

            out=load(filePathForOutput,'nnet');
            trainedModel=out.nnet;
            if(validation==false)
                input=load(filePathForInput,'trainingData');
                data=input.trainingData;
                input=load(filePathForInput,'responseName');
                responseName=input.responseName;
            else
                input=load(filePathForInput,'validationData');
                data=input.validationData;
                responseName='';
            end
            trainingType=self.rsGetRun(runID).trainingType;
            self.generateConfusionChart_V1(label,trainedModel,data,responseName,title,trainingType);

        end

        function displayROCCurve_V1(self,label,validation,runID,trialIndx)
            runDir=self.getResultsDir();
            filePathForOutput=fullfile(runDir,runID,['Trial_',num2str(trialIndx)],'output.mat');
            filePathForInput=fullfile(runDir,runID,['Trial_',num2str(trialIndx)],'input.mat');

            if(~exist(filePathForOutput,'file'))
                label=message(label).getString();
                msg=message('experiments:results:NoVisualizationAvailable',label).getString();
                self.showMessage(msg);
                return;
            end

            self.showMessage(message('experiments:results:GeneratingROCCurve').getString(),true);
            title=self.getTitle(label,runID,trialIndx);

            out=load(filePathForOutput,'nnet');
            trainedModel=out.nnet;
            if(validation==false)
                input=load(filePathForInput,'trainingData');
                data=input.trainingData;
                input=load(filePathForInput,'responseName');
                responseName=input.responseName;
            else
                input=load(filePathForInput,'validationData');
                data=input.validationData;
                responseName='';
            end
            trainingType=self.rsGetRun(runID).trainingType;
            self.generateROCCurve_V1(label,trainedModel,data,responseName,title,trainingType);

        end

        function displayConfusionChart_V2(self,label,validation,runID,trialIndx)
            runDir=self.getResultsDir();
            filePathForConfusionMatrix=fullfile(runDir,runID,['Trial_',num2str(trialIndx)],'confusionmatrix.mat');

            if(~exist(filePathForConfusionMatrix,'file'))
                label=message(label).getString();
                msg=message('experiments:results:NoVisualizationAvailable',label).getString();
                self.showMessage(msg);
                return;
            end
            self.showMessage(message('experiments:results:GeneratingConfusionMatrix').getString(),true);

            out=load(filePathForConfusionMatrix);
            if(validation==false)
                m=out.matrixForTrainingData;
                order=out.truePredictedLabelsForTraining;
                errorLabel=out.errorLabel;
            else
                m=out.matrixForValidationData;
                order=out.truePredictedLabelsForValidation;
                errorLabel=out.errorLabelValidation;
            end

            if(~isempty(errorLabel)||isempty(m)||isempty(order))
                if(ischar(errorLabel))
                    label=message(label).getString();
                    msg=message('experiments:results:NoVisualizationAvailableAndReason',label,message(errorLabel).getString()).getString();
                    self.showMessage(msg);
                elseif(iscell(errorLabel))
                    newStr=split(errorLabel,',');
                    msg=message('experiments:results:NoVisualizationAvailableAndReason',label,message(newStr{1}).getString()).getString();
                    self.showMessage(strcat(msg," ",newStr{2}));
                end

                return;
            end






            if(~isfield(out,'version'))
                m=transpose(m);
            end

            try
                title=self.getTitle(label,runID,trialIndx);
                self.generateConfusionChart(m,order,title);
            catch ME
                label=message(label).getString();
                msg=message('experiments:results:NoVisualizationAvailableAndReason',label,ME.message).getString();
                self.showMessage(msg);
            end


        end

        function displayROCCurve_V2(self,label,validation,runID,trialIndx)
            runDir=self.getResultsDir();
            filePathForROCCurve=fullfile(runDir,runID,['Trial_',num2str(trialIndx)],'roccurve.mat');

            if(~exist(filePathForROCCurve,'file'))
                label=message(label).getString();
                msg=message('experiments:results:NoVisualizationAvailable',label).getString();
                self.showMessage(msg);
                return;
            end
            self.showMessage(message('experiments:results:GeneratingROCCurve').getString(),true);

            out=load(filePathForROCCurve);
            if(validation==false)
                xArray=out.falsePositiveRatesArrayForTraining;
                yArray=out.truePositiveRatesArrayForTraining;
                tArray=out.thresholdsArrayForTraining;
                aucArray=out.aucArrayForTraining;
                order=out.orderForTraining;
                errorLabel=out.errorLabelROCCurve;
            else
                xArray=out.falsePositiveRatesArrayForValidation;
                yArray=out.truePositiveRatesArrayForValidation;
                tArray=out.thresholdsArrayForValidation;
                aucArray=out.aucArrayForValidation;
                order=out.orderForValidation;
                errorLabel=out.errorLabelROCCurveValidation;
            end

            if(~isempty(errorLabel)||isempty(xArray)||isempty(yArray)||isempty(tArray)||isempty(aucArray)||isempty(order))
                label=message(label).getString();
                msg=message('experiments:results:NoVisualizationAvailableAndReason',label,message(errorLabel).getString()).getString();
                self.showMessage(msg);
                return;
            end

            try
                titleForROCCurve=self.getTitle(label,runID,trialIndx);
                self.generateROCCurve(xArray,yArray,tArray,aucArray,order,titleForROCCurve);
            catch ME
                label=message(label).getString();
                msg=message('experiments:results:NoVisualizationAvailableAndReason',label,ME.message).getString();
                self.showMessage(msg);
            end


        end

    end

    methods(Access=protected)
        function scheduleVisualization(self,fn,varargin)




            self.pendingVisualization.fn=fn;
            self.pendingVisualization.args=varargin;

            function resetIsRendering(self)
                self.isRendering=false;
            end



            if~self.isRendering
                self.isRendering=true;
                cleanupIsRendering=onCleanup(@()resetIsRendering(self));



                while~isempty(self.pendingVisualization)
                    fn=self.pendingVisualization.fn;
                    args=self.pendingVisualization.args;
                    self.pendingVisualization=[];

                    fn(self,args{:});
                end
            end
        end

        function resetVisualization(self)
            if self.autoDelete
                fn=@delete;
            else
                fn=@(c)c.set('Parent',[]);
            end
            arrayfun(fn,self.visualizationPanel.Figure.Children);
            self.visualizationPanel.Figure.Pointer='arrow';
            drawnow();
        end

        function showVisualization(self,panel,autoDelete,waiting)

            self.resetVisualization();


            if isa(panel,'function_handle')
                panel(self.visualizationPanel.Figure);
            else
                panel.Parent=self.visualizationPanel.Figure;
            end
            self.visualizationPanel.Opened=true;
            self.autoDelete=autoDelete;
            if exist('waiting','var')&&waiting
                self.visualizationPanel.Figure.Pointer='watch';
            end
            drawnow();
        end

        function showMessage(self,msg,waiting)

            panel=uigridlayout('Parent',[],'ColumnWidth',{'1x','fit','1x'},'RowHeight',{'1x','fit','1x'});
            label=uilabel('Parent',panel,'Text',msg,'FontWeight','bold');
            label.Layout.Column=2;
            label.Layout.Row=2;
            waiting=exist('waiting','var')&&waiting;
            self.showVisualization(panel,true,waiting);
        end

        function title=getTitle(self,labelID,runID,trialID)
            run=self.rsGetRun(runID);
            label=message(labelID).getString();
            title=message('experiments:results:VisualizationLabel',label,trialID,run.runLabel,run.expName).getString();
        end

        function showTrainingPlot(self,runID,trialIndx)
            self.showMessage(message('experiments:results:LoadingTrainingPlot').getString(),true);
            run=self.rsGetRun(runID);
            if isfield(run,'job')
                trainingPlotFile=fullfile(self.getResultsDir(),runID,['Trial_',num2str(trialIndx)],'trainingPlot.fig');
                trainingPlotFileRunning=fullfile(self.getResultsDir(),runID,['Trial_',num2str(trialIndx)],'trainingPlot_Running.fig');
                if exist(trainingPlotFile,'file')
                    fig=self.openFigure(trainingPlotFile);
                    self.showVisualization(fig.Children(1),true);
                    delete(fig);
                elseif exist(trainingPlotFileRunning,'file')
                    fig=self.openFigure(trainingPlotFileRunning);
                    self.showVisualization(fig.Children(1),true);
                    delete(fig);
                else
                    label=message('experiments:results:TrainingPlotLabel').getString();
                    msg=message('experiments:results:NoVisualizationAvailable',label).getString();
                    self.showMessage(msg);
                end
                return;
            end

            data=self.rsGetTrial(runID,trialIndx);
            if strcmp(data{2}.status,'Running')
                if self.parallelToggleOn
                    trialRunner=self.trialRunnerMap(trialIndx);
                    panel=trialRunner.getPanel();
                else
                    trialRunnerObj=self.execInfo.trialRunner;
                    panel=trialRunnerObj.getPanel();
                end


                self.showVisualization(panel,false);
            else
                trainingPlotFile=fullfile(self.getResultsDir(),runID,['Trial_',num2str(trialIndx)],'trainingPlot.fig');
                if exist(trainingPlotFile,'file')
                    fig=self.openFigure(trainingPlotFile);
                    self.showVisualization(fig.Children(1),true);
                    delete(fig);
                else
                    label=message('experiments:results:TrainingPlotLabel').getString();
                    msg=message('experiments:results:NoVisualizationAvailable',label).getString();
                    self.showMessage(msg);
                end
            end
        end

        function showConfusionChartUsingValidationData(self,runID,trialIndx)
            self.displayConfusionChart('experiments:results:ConfusionMatrixLabelValidationData',true,runID,trialIndx);
        end

        function showConfusionChart(self,runID,trialIndx)
            self.displayConfusionChart('experiments:results:ConfusionMatrixLabelTrainingData',false,runID,trialIndx);
        end

        function showROCCurveUsingValidationData(self,runID,trialIndx)
            self.displayROCCurve('experiments:results:ROCCurveLabelValidationData',true,runID,trialIndx);
        end

        function showROCCurve(self,runID,trialIndx)
            self.displayROCCurve('experiments:results:ROCCurveLabelTrainingData',false,runID,trialIndx);
        end
    end
end
