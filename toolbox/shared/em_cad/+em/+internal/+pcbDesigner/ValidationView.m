classdef ValidationView<cad.View




    properties
        Parent=[];
        ParentLayout;

NameText
StatusText
MessageText

        checkBoardView;
        checkLayersView;
        checkFeedView;
        checkViaView;
        checkLoadView;

OkButton

        validationStatus;
        ShowStatus=0;

        TitleColor=[102,102,102]/256;

PanelLabel
    end

    methods

        function self=ValidationView(Parent)
            self.Parent=Parent;
            createValidationViewnew(self);
        end

        function setPosition(self,gobj,row,column)
            gobj.Layout.Row=row;
            gobj.Layout.Column=column;
        end

        function createValidationViewnew(self)
            import matlab.ui.internal.toolstrip.*

            self.Parent.Resize='off';
            self.Parent.CloseRequestFcn=@(src,evt)closeFcn(self);
            self.ParentLayout=uigridlayout(self.Parent,'Scrollable','on');
            self.PanelLabel=uilabel(self.ParentLayout,'Text',' Validation Results','FontWeight','bold','tag','TitleLabel','FontSize',12);
            setPosition(self,self.PanelLabel,1,1);
            self.NameText=uieditfield(self.ParentLayout,'FontColor',self.TitleColor,'FontWeight','normal','Editable',"off",'Value'," TEST",'HorizontalAlignment','Left');
            setPosition(self,self.NameText,2,1);
            self.StatusText=uieditfield(self.ParentLayout,'FontColor',self.TitleColor,'FontWeight','normal','Editable',"off",'Value'," STATUS",'HorizontalAlignment','Left');
            setPosition(self,self.StatusText,2,2);
            self.MessageText=uieditfield(self.ParentLayout,'FontColor',self.TitleColor,'FontWeight','normal','Editable',"off",'Value'," MESSAGE",'HorizontalAlignment','Left');
            setPosition(self,self.MessageText,2,[3,6]);

            self.checkBoardView=em.internal.pcbDesigner.ValidationUi(self.ParentLayout,'Check Board Shape','','','BoardShape');
            self.checkBoardView.setPosition(3,[1,6]);
            self.checkLayersView=em.internal.pcbDesigner.ValidationUi(self.ParentLayout,'Check Layers','','','Layers');
            self.checkLayersView.setPosition(4,[1,6]);
            self.checkFeedView=em.internal.pcbDesigner.ValidationUi(self.ParentLayout,'Check Feed','','','Feed');
            self.checkFeedView.setPosition(5,[1,6]);
            self.checkViaView=em.internal.pcbDesigner.ValidationUi(self.ParentLayout,'Check Via','','','Via');
            self.checkViaView.setPosition(6,[1,6]);
            self.checkLoadView=em.internal.pcbDesigner.ValidationUi(self.ParentLayout,'Check Load','','','Load');
            self.checkLoadView.setPosition(7,[1,6]);

            self.OkButton=uibutton(self.ParentLayout,'Tag','Close','Text','Close',...
            "ButtonPushedFcn",@(src,evt)hideValidation(self));
            self.setPosition(self.OkButton,9,6)

            self.ParentLayout.ColumnWidth={'2.5x','1.5x','1x','1x','1x'};
            self.ParentLayout.ColumnSpacing=0;
            self.ParentLayout.RowSpacing=0;
            self.ParentLayout.Padding=[20,20,20,15];

            self.ParentLayout.RowHeight={40,30,self.checkBoardView.Height,...
            self.checkLayersView.Height,self.checkFeedView.Height,...
            self.checkViaView.Height,self.checkLoadView.Height,15,25};
            self.Parent.Position(3:4)=[500,(40+30+15+25+35+self.checkBoardView.Height+...
            self.checkLayersView.Height+self.checkFeedView.Height+...
            self.checkViaView.Height+self.checkLoadView.Height)];
            self.Parent.Position(1:2)=[200,200];
            self.Parent.Name='Validate Design';
        end

        function closeFcn(self)
            self.Parent.Resize='on';
            self.ParentLayout.Scrollable='on';
            self.validationStatus='end';
            if strcmpi(self.validationStatus,'end')
                hideValidation(self);
            end
        end

        function startValidationDialog(self)
            resetValidation(self);
            showValidation(self);
            startValidation(self);
        end

        function startValidation(self)
            self.notify('Validate');
        end

        function showValidation(self)
            self.ShowStatus=1;
            self.Parent.Visible='on';
            self.Parent.WindowStyle='modal';

        end

        function hideValidation(self)
            self.ShowStatus=0;
            self.Parent.Visible='off';
            self.Parent.WindowStyle='normal';
            resetValidation(self)
            self.notify('DialogClosed');
        end

        function resetValidation(self)
            self.checkBoardView.Status='';
            self.checkBoardView.Message='';
            self.checkLayersView.Status='';
            self.checkLayersView.Message='';
            self.checkFeedView.Status='';
            self.checkFeedView.Message='';
            self.checkViaView.Status='';
            self.checkViaView.Message='';
            self.checkLoadView.Status='';
            self.checkLoadView.Message='';
            self.ParentLayout.RowHeight={40,30,self.checkBoardView.Height,...
            self.checkLayersView.Height,self.checkFeedView.Height,...
            self.checkViaView.Height,self.checkLoadView.Height,15,25};
            self.Parent.Position(3:4)=[500,(40+30+15+25+35+self.checkBoardView.Height+...
            self.checkLayersView.Height+self.checkFeedView.Height+...
            self.checkViaView.Height+self.checkLoadView.Height)];
        end
        function validationStart(self)
            self.validationStatus='Start';
            resetValidation(self);
        end
        function validationUpdated(self,evt)
            import matlab.ui.internal.toolstrip.*

            if self.ShowStatus
                figure(self.Parent);
            end

            self.validationStatus='Update';
            if strcmpi(evt.Type,'BoardShape')
                if strcmpi(evt.State,'Success')
                    self.checkBoardView.Status='Pass';
                elseif strcmpi(evt.State,'Start')
                    self.checkBoardView.Status='Running';
                elseif strcmpi(evt.State,'Fail')
                    if~self.ShowStatus
                        self.ShowStatus=1;
                        figure(self.Parent);

                    end
                    self.checkBoardView.Status='Fail';
                    self.checkBoardView.Message=[self.checkBoardView.Message,...
                    newline,newline,evt.Message];
                end
            elseif strcmpi(evt.Type,'Layers')
                if strcmpi(evt.State,'Success')
                    self.checkLayersView.Status='Pass';
                elseif strcmpi(evt.State,'Start')
                    self.checkLayersView.Status='Running';
                elseif strcmpi(evt.State,'Fail')
                    if~self.ShowStatus
                        self.ShowStatus=1;
                        figure(self.Parent);

                    end
                    self.checkLayersView.Status='Fail';
                    self.checkLayersView.Message=[self.checkLayersView.Message,...
                    newline,newline,evt.Message];
                end
            elseif strcmpi(evt.Type,'Feed')
                if strcmpi(evt.State,'Success')
                    self.checkFeedView.Status='Pass';
                elseif strcmpi(evt.State,'Start')
                    self.checkFeedView.Status='Running';
                elseif strcmpi(evt.State,'Fail')
                    if~self.ShowStatus
                        self.ShowStatus=1;
                        figure(self.Parent);

                    end

                    if strcmpi(self.checkFeedView.Status,'Pass')
                        self.checkFeedView.Message=evt.Message;
                        self.checkFeedView.Status='Fail';
                    else
                        self.checkFeedView.Status='Fail';
                        self.checkFeedView.Message=[self.checkFeedView.Message,...
                        newline,newline,evt.Message];
                    end
                end
            elseif strcmpi(evt.Type,'Via')
                if strcmpi(evt.State,'Success')
                    self.checkViaView.Status='Pass';
                elseif strcmpi(evt.State,'Start')
                    self.checkViaView.Status='Running';
                elseif strcmpi(evt.State,'Fail')
                    if~self.ShowStatus
                        self.ShowStatus=1;
                        figure(self.Parent);

                    end
                    self.checkViaView.Status='Fail';
                    self.checkViaView.Message=[self.checkViaView.Message,...
                    newline,newline,evt.Message];
                end
            elseif strcmpi(evt.Type,'Load')
                if strcmpi(evt.State,'Success')
                    self.checkLoadView.Status='Pass';
                elseif strcmpi(evt.State,'Start')
                    self.checkLoadView.Status='Running';
                elseif strcmpi(evt.State,'Fail')
                    if~self.ShowStatus
                        self.ShowStatus=1;
                        figure(self.Parent);

                    end
                    self.checkLoadView.Status='Fail';
                    self.checkLoadView.Message=[self.checkLoadView.Message,...
                    newline,newline,evt.Message];
                end
            end

        end
        function validationEnd(self)
            self.ParentLayout.RowHeight={40,30,self.checkBoardView.Height,...
            self.checkLayersView.Height,self.checkFeedView.Height,...
            self.checkViaView.Height,self.checkLoadView.Height,15,25};
            self.Parent.Position(3:4)=[500,(40+30+15+25+35+self.checkBoardView.Height+...
            self.checkLayersView.Height+self.checkFeedView.Height+...
            self.checkViaView.Height+self.checkLoadView.Height)];
            self.validationStatus='End';
        end
        function modelChanged(self,evt)
        end

        function setModel(self,model)
            addlistener(model,'ValidationStart',@(src,evt)validationStart(self));
            addlistener(model,'ValidationUpdated',@(src,evt)validationUpdated(self,evt));
            addlistener(model,'ValidationEnd',@(src,evt)validationEnd(self));
            addlistener(self,'Validate',@(src,evt)validateDesign(model));
        end

        function delete(self)
            if self.checkValid(self.Parent)
                clf(self.Parent);
                self.Parent.delete;
            end
        end
    end
    events
Validate
    end
end
