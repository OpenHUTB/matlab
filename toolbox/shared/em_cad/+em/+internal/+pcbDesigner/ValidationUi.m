classdef ValidationUi<handle
    properties
Parent
Height
    end
    properties(Dependent=true)

Label
Status
Message
    end

    properties(Hidden=true)
privateLabel
privateStatus
privateMessage
privateTag
Panel
Layout
LabelText
StatusText
StatusIcon
StatusLayout
MessageText
MessagePanel
MessageLayout
        Iconpath=fullfile(matlabroot,"toolbox","shared","em_cad","+em","+internal","+pcbDesigner","+src");
    end

    methods
        function self=ValidationUi(Parent,Label,Status,Message,Tag)
            self.privateLabel=Label;
            self.privateStatus=Status;
            self.privateMessage=Message;
            self.privateTag=Tag;
            self.Parent=Parent;
            createUi(self);
        end

        function set.Label(self,propval)
            self.LabelText.Text=propval;
            self.privateLabel=propval;
        end

        function val=get.Label(self)
            val=self.LabelText.Text;
        end

        function set.Status(self,propval)
            self.StatusText.Text=propval;
            self.setStatusVal();
            self.privateStatus=propval;
        end

        function val=get.Status(self)
            val=self.StatusText.Text;
        end

        function set.Message(self,propval)
            self.MessageText.Text=propval;
            self.privateMessage=propval;
        end

        function val=get.Message(self)
            val=self.MessageText.Text;
        end

        function setPosition(self,row,column)
            self.Panel.Layout.Row=row;
            self.Panel.Layout.Column=column;
        end

        function setPos(self,gobj,row,column)
            gobj.Layout.Row=row;
            gobj.Layout.Column=column;
        end
        function createUi(self)
            self.Panel=uipanel(self.Parent);
            self.Panel.Tag=self.privateTag;
            self.Layout=uigridlayout(self.Panel);
            self.LabelText=uilabel(self.Layout,'FontSize',12,'FontWeight',...
            'normal','Text',['  ',self.privateLabel],'WordWrap','on','Tag',[self.privateTag,'LabelText'],'BackgroundColor',[1,1,1]);
            setPos(self,self.LabelText,1,1);
            self.StatusLayout=uigridlayout(self.Layout);
            setPos(self,self.StatusLayout,1,2);

            self.StatusIcon=uiimage(self.StatusLayout,'tag',[self.privateTag,'StatusIcon'],'backgroundColor',[1,1,1]);
            setPos(self,self.StatusIcon,1,1);
            self.StatusText=uilabel(self.StatusLayout,'FontWeight','normal','Text',self.privateStatus,'Tag',[self.privateTag,'StatusText'],'BackgroundColor',[1,1,1]);
            setPos(self,self.StatusText,1,2);
            setPos(self,self.StatusLayout,1,2);
            setStatusVal(self);
            self.MessagePanel=uipanel(self.Layout);
            setPos(self,self.MessagePanel,1,[3,6]);
            self.MessageLayout=uigridlayout(self.MessagePanel);
            self.MessageText=uilabel(self.MessageLayout,'FontWeight','normal',...
            "Text",self.privateMessage,'WordWrap','on','BackgroundColor',[1,1,1],'Tag',[self.privateTag,'Message']);
            setPos(self,self.MessageText,1,1);

            self.MessageLayout.ColumnWidth={'1x'};
            self.MessageLayout.RowHeight={'fit'};
            self.MessageLayout.Scrollable='on';
            self.MessageLayout.Padding=[10,0,0,0];
            self.MessageLayout.BackgroundColor=[1,1,1];

            self.Layout.ColumnWidth={'2.5x','1.5x','1x','1x','1x'};
            self.Layout.RowHeight={'1x'};
            self.Layout.Padding=[0,0,0,0];
            self.Layout.BackgroundColor=[0.7,0.7,0.7];
            self.Layout.ColumnSpacing=1;
            self.StatusLayout.RowHeight={'1x'};
            self.StatusLayout.ColumnWidth={16,'2x'};
            self.StatusLayout.ColumnSpacing=5;
            self.StatusLayout.Padding=[10,1,1,1];
            self.StatusLayout.BackgroundColor=[1,1,1];


        end

        function setStatusVal(self)
            layoutpos=getpixelposition(self.Layout);
            if strcmpi(self.Status,'Pass')
                self.StatusIcon.ImageSource=fullfile(self.Iconpath,"success_16.png");
                self.StatusText.FontColor=[0,0.7,0];
                self.MessageText.FontColor=[0,0,0];
                self.MessageText.Text=[newline,'Test passed successfully'];
                layoutpos(4)=40;
            elseif strcmpi(self.Status,'Fail')
                self.StatusIcon.ImageSource=fullfile(self.Iconpath,"mafailed_16_16.png");
                self.StatusText.FontColor=[0.7,0,0];
                self.MessageText.FontColor=[0.7,0,0];
                layoutpos(4)=80;
            elseif strcmpi(self.Status,'Warn')
                self.StatusIcon.ImageSource=fullfile(self.Iconpath,"warning_16.png");
                self.StatusText.FontColor=[255,204,0]/255;
                self.MessageText.FontColor=[0,0,0];
                layoutpos(4)=80;
            elseif strcmpi(self.Status,'Running')
                self.StatusIcon.ImageSource=fullfile(self.Iconpath,"restart.svg");
                self.StatusText.FontColor=[0,0,0];
                self.MessageText.FontColor=[0,0,0];
                layoutpos(4)=40;
            elseif strcmpi(self.Status,'')
                self.StatusIcon.ImageSource=fullfile(self.Iconpath,"empty_error.png");
                self.StatusText.FontColor=[0,0,0];
                self.MessageText.FontColor=[0,0,0];
                self.MessageText.Text='Test Pending';
                layoutpos(4)=40;
            end

            self.Height=layoutpos(4);

        end
    end
end