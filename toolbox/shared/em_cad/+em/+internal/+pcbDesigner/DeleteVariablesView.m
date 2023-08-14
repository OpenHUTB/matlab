classdef DeleteVariablesView<cad.View
    properties
Parent
Layout
MapView
MapViewPanel
DeleteBtn
CancelBtn
        DeleteMessage=@(x)getString(message("antenna:pcbantennadesigner:DeleteMessage",x));
DeleteMessageUI
        VarData=[];
        AdditionalCallback=@()1;
        DeleteVariablesCallback=@(src,evt)1;
    end

    methods
        function self=DeleteVariablesView(Parent)
            self.Parent=Parent;
            createUiControls(self);
        end

        function setModel(self,Model)
            addlistener(self,'DeleteVariables',@(src,evt)Model.deleteVariable(src,evt));
        end

        function createUiControls(self)
            import matlab.ui.internal.toolstrip.Icon;
            self.Layout=uigridlayout(self.Parent,[4,6],ColumnWidth={60,40,'1x',50,50,50});
            self.Layout.RowHeight={'1x',75,5,25};
            self.MapViewPanel=uipanel(self.Layout,Tag="MapViewPanel");
            setLayout(self,self.MapViewPanel,1,[1,6]);
            self.MapView=em.internal.pcbDesigner.MapView(self.MapViewPanel,0,'Warn');

            self.DeleteMessageUI=uilabel(self.Layout,'HorizontalAlignment','Left','Text',self.DeleteMessage([newline,newline]),Tag="DeleteMessage",WordWrap="on");
            setLayout(self,self.DeleteMessageUI,2,[2,5]);
            self.DeleteBtn=uibutton(self.Layout,'Text','Delete Variable','ButtonPushedFcn',@(src,evt)inputCallback(self,src),Tag="DeleteBtn");
            setLayout(self,self.DeleteBtn,4,[4,5]);
            self.CancelBtn=uibutton(self.Layout,'Text','Cancel','ButtonPushedFcn',@(src,evt)inputCallback(self,src),Tag="CancelBtn");
            setLayout(self,self.CancelBtn,4,6);
            self.Parent.Tag="DeleteVariablesView";
            if isprop(self.Parent,'CloseRequestFcn')
                self.Parent.CloseRequestFcn=@(src,evt)self.hideDialog();
                self.Parent.Name="Delete Variables";
                self.Parent.WindowStyle='modal';
            end
        end

        function showDialog(self)
            self.Parent.Visible='on';
        end
        function hideDialog(self)
            self.Parent.delete;
            self.AdditionalCallback();
        end

        function retval=updateView(self,vm,vars)
            retval=updateView(self.MapView,vm,vars);
            self.Parent.Position(4)=500;
            self.VarData=vars;

        end

        function inputCallback(self,src)
            if strcmpi(src.Tag,'DeleteBtn')
                self.DeleteVariablesCallback(cad.events.VariableEventData(self.VarData,[]));

            end

            self.hideDialog();
        end

    end
    events
DeleteVariables
    end

end