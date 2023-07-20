classdef RFBudgetAnalyzerTool<handle











    properties
Model
View
Controller
    end

    methods

        function self=RFBudgetAnalyzerTool(varargin)














            s=settings;
            parser=inputParser;
            parser.addOptional('PreviousModel',[],...
            @(x)isa(x,'rf.internal.apps.budget.rfbudget')||...
            isa(x,'rfbudget')||ischar(x)||isempty(x)||isstring(x));
            parser.addParameter('UseAppContainer',...
            s.rf.Decaf.ActiveValue,@islogical);
            if mod(nargin,2)==0
                parse(parser,[],varargin{:});
            else
                parse(parser,varargin{:});
            end

            self.Model=rf.internal.apps.budget.Model('UseAppContainer',...
            parser.Results.UseAppContainer);
            self.View=rf.internal.apps.budget.View('UseAppContainer',...
            parser.Results.UseAppContainer);
            self.Controller=...
            rf.internal.apps.budget.Controller(self.Model,self.View);

            if~isempty(parser.Results.PreviousModel)
                initialModel(self.Model,parser.Results.PreviousModel)
            end
            newView(self.View,self.Model.Name,self.Model.Budget)

            self.View.UseAppContainer=parser.Results.UseAppContainer;

            try
                if self.View.UseAppContainer
                    s.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue=1;
                    s.matlab.ui.internal.uicontrol.UseRedirectInUifigure.TemporaryValue=1;
                else
                    s.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue=0;
                    s.matlab.ui.internal.uicontrol.UseRedirectInUifigure.TemporaryValue=0;
                end
            catch

            end

            if self.View.UseAppContainer
                self.View.Toolstrip.AppContainer.CanCloseFcn=@(h)closeCallback(self);
            else

                addlistener(self.View.Toolstrip.ToolGroup,'GroupAction',...
                @(h,e)closeCallback(self,e));



                self.View.Toolstrip.ToolGroup.approveClose();
            end
        end

        function varargout=closeCallback(self,varargin)




            if self.View.UseAppContainer
                if~isempty(self.Model)&&self.Model.IsChanged
                    if self.Model.processBudgetSaving(self.View.CanvasFig.Figure)
                        varargout{1}=false;
                        return
                    end
                end
                varargout{1}=true;
                try

                    s=settings;
                    s.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue=0;
                    s.matlab.ui.internal.uicontrol.UseRedirectInUifigure.TemporaryValue=0;
                catch
                end
                antennaHandle=[];
                if~isempty(self.View.Parameters.AntennaDialog)
                    antennaHandle=self.View.Parameters.AntennaDialog.getAppHandle();
                end
                if~isempty(self.View.Parameters.AntennaDialogRx)
                    antennaHandle=self.View.Parameters.AntennaDialogRx.getAppHandle();
                end
                if~isempty(self.View.Parameters.AntennaDialogTxRx)
                    antennaHandle=self.View.Parameters.AntennaDialogTxRx.getAppHandle();
                end
                if~isempty(antennaHandle)&&~strcmpi(antennaHandle(1).App.AppContainer.State,'TERMINATED')
                    antennaHandle(1).App.AppContainer.close();
                    if numel(antennaHandle)==2
                        if~strcmpi(antennaHandle(2).App.AppContainer.State,'TERMINATED')
                            antennaHandle(2).App.AppContainer.close();
                        end
                    end
                end
            else
                et=varargin{1}.EventData.EventType;
                if strcmp(et,'CLOSING')
                    if~isempty(self.Model)&&self.Model.IsChanged
                        if self.Model.processBudgetSaving()
                            return
                        end
                    end
                    antennaHandle=[];
                    if~isempty(self.View.Parameters.AntennaDialog)
                        antennaHandle=self.View.Parameters.AntennaDialog.getAppHandle();
                    end
                    if~isempty(self.View.Parameters.AntennaDialogRx)
                        antennaHandle=self.View.Parameters.AntennaDialogRx.getAppHandle();
                    end
                    if~isempty(self.View.Parameters.AntennaDialogTxRx)
                        antennaHandle=self.View.Parameters.AntennaDialogTxRx.getAppHandle();
                    end
                    if~isempty(antennaHandle)&&any(isvalid(antennaHandle))
                        antennaHandle(1).Model.CloseController.execute(antennaHandle(1),varargin{1});
                        if numel(antennaHandle)==2
                            antennaHandle(2).Model.CloseController.execute(antennaHandle(2),varargin{1});
                        end
                    end
                    if self.View.Toolstrip.NewBtn.Enabled
                        delete(self.View)
                        delete(self)
                    end
                end
            end
        end
    end
end


