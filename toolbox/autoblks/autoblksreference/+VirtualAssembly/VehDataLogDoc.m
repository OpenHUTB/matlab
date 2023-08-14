classdef VehDataLogDoc<matlab.mixin.SetGet&matlab.mixin.Heterogeneous




    properties

Doc

        FigDoc matlab.ui.Figure

AppContainer

SignalList

SelectedSignals
    end

    properties(SetAccess=private)

        SignalSelectButton matlab.ui.control.Button
        SignalRemoveButton matlab.ui.control.Button
        SignalRemoveAllButton matlab.ui.control.Button
        SignalDefaultButton matlab.ui.control.Button
        SelectedSignalListBox matlab.ui.control.ListBox
SignalTree
GridLayout1
GridLayout2
GridLayout3

    end

    properties(Constant)
        DefaultSignals=["Driver.SteerFdbk","Driver.AccelFdbk","Driver.DecelFdbk",...
        "Driver.GearFdbk","Body.BdyFrm.Cg.Vel.xdot","Body.BdyFrm.Cg.Acc.ax",...
        "Body.BdyFrm.Cg.Acc.ay","Body.BdyFrm.Cg.Acc.az","Driveline.EMSpd","Battery.BattSoc",...
        "Battery.BattVolt","Battery.BattCurr","EM.EMTrq",...
        "Engine.EngTrq","Engine.EngSpdOut"];

    end

    methods

        function obj=VehDataLogDoc(varargin)
            set(obj,varargin{:});

            if isempty(obj.SelectedSignals)
                obj.SelectedSignals=obj.DefaultSignals;
            end

            obj.SignalList=VirtualAssembly.readSignalList();

            [doc,fig]=addDocumentFigures(obj,'Logging');
            obj.Doc=doc;
            obj.FigDoc=fig;

            obj.setupDocLyt();

        end

    end


    methods(Access=private)
        function[doc,fig]=addDocumentFigures(obj,name)


            docOptions.Title=name;
            docOptions.DocumentGroupTag='Configuration';

            doc=matlab.ui.internal.FigureDocument(docOptions);
            doc.Closable=false;
            doc.Figure.AutoResizeChildren='on';
            doc.Tag='Logging';

            obj.AppContainer.add(doc);
            drawnow();

            fig=doc.Figure;
            fig.Tag=name;
            fig.AutoResizeChildren='on';
            fig.Interruptible='off';
            fig.BusyAction='cancel';
        end

        function setupDocLyt(obj)

            obj.GridLayout1=uigridlayout(obj.FigDoc,[1,4]);
            obj.GridLayout1.ColumnWidth={'1x','0.4x','1x','0.4x'};
            obj.GridLayout1.Padding=[10,10,10,10];
            obj.GridLayout1.BackgroundColor=[1,1,1];


            SignalListPanel=uipanel(obj.GridLayout1,'Title','Signal List');
            GridLayout_SignalTree=uigridlayout(SignalListPanel);
            GridLayout_SignalTree.ColumnWidth={'1x'};
            GridLayout_SignalTree.RowHeight={'1x'};
            obj.SignalTree=uitree(GridLayout_SignalTree);
            SignalListStr=obj.SignalList;

            parent=uitreenode(obj.SignalTree,'Text',SignalListStr.SignalName);

            obj.buildSignalTree(SignalListStr.Children,parent);
            expand(obj.SignalTree);


            obj.GridLayout2=uigridlayout(obj.GridLayout1,[3,1]);
            obj.GridLayout2.RowHeight={'1x','fit','1x'};
            obj.GridLayout2.BackgroundColor=[1,1,1];


            obj.SignalSelectButton=uibutton(obj.GridLayout2,'push');
            obj.SignalSelectButton.ButtonPushedFcn=@(~,~)SignalSelectButtonPushed(obj);
            obj.SignalSelectButton.Layout.Row=2;
            obj.SignalSelectButton.Layout.Column=1;
            obj.SignalSelectButton.Text='Select>>';
            obj.SignalSelectButton.Tag='SignalSelectButton';


            SelectedSignalListPanel=uipanel(obj.GridLayout1,'Title','Selected Signals');
            GridLayout_SelectedSignal=uigridlayout(SelectedSignalListPanel);
            GridLayout_SelectedSignal.ColumnWidth={'1x'};
            GridLayout_SelectedSignal.RowHeight={'1x'};
            obj.SelectedSignalListBox=uilistbox(GridLayout_SelectedSignal);
            obj.SelectedSignalListBox.Tag='SelectedSignalListBox';
            obj.SelectedSignalListBox.Multiselect='on';
            if isempty(obj.SelectedSignals)
                obj.SelectedSignalListBox.Items={};
            else
                obj.SelectedSignalListBox.Items=obj.SelectedSignals;
            end


            obj.GridLayout3=uigridlayout(obj.GridLayout1,[5,1]);
            obj.GridLayout3.RowHeight={'1x','fit','fit','fit','1x'};
            obj.GridLayout3.Padding=[10,10,10,10];
            obj.GridLayout3.BackgroundColor=[1,1,1];


            obj.SignalRemoveButton=uibutton(obj.GridLayout3,'push');
            obj.SignalRemoveButton.ButtonPushedFcn=@(~,~)SignalRemoveButtonPushed(obj);
            obj.SignalRemoveButton.Layout.Row=3;
            obj.SignalRemoveButton.Layout.Column=1;
            obj.SignalRemoveButton.Text='Remove';
            obj.SignalRemoveButton.Tag='SignalRemoveButton';


            obj.SignalRemoveAllButton=uibutton(obj.GridLayout3,'push');
            obj.SignalRemoveAllButton.ButtonPushedFcn=@(~,~)SignalRemoveAllButtonPushed(obj);
            obj.SignalRemoveAllButton.Layout.Row=4;
            obj.SignalRemoveAllButton.Layout.Column=1;
            obj.SignalRemoveAllButton.Text='Remove All';
            obj.SignalRemoveAllButton.Tag='SignalRemoveAllButton';


            obj.SignalDefaultButton=uibutton(obj.GridLayout3,'push');
            obj.SignalDefaultButton.ButtonPushedFcn=@(~,~)SignalDefaultButtonPushed(obj);
            obj.SignalDefaultButton.Layout.Row=2;
            obj.SignalDefaultButton.Layout.Column=1;
            obj.SignalDefaultButton.Text='Default';
            obj.SignalDefaultButton.Tag='SignalDefaultButton';
            drawnow();
        end

        function buildSignalTree(obj,SignalListStr,parent)
            for i=1:length(SignalListStr)
                children_node=uitreenode(parent,'Text',SignalListStr(i).SignalName);
                if~isempty(SignalListStr(i).Children)
                    obj.buildSignalTree(SignalListStr(i).Children,children_node);
                end
            end
        end

        function SignalSelectButtonPushed(obj)
            SelectedNode=obj.SignalTree.SelectedNodes;
            if~isempty(SelectedNode)&&isempty(SelectedNode.Children)
                SelectedSignalName=obj.findSignalName(SelectedNode);
                SelectedSignalName(1)=[];
                obj.SelectedSignals=[obj.SelectedSignals,convertCharsToStrings(SelectedSignalName)];
                obj.SelectedSignals=unique(obj.SelectedSignals);
                obj.SelectedSignalListBox.Items=obj.SelectedSignals;
            end
        end

        function OutputName=findSignalName(obj,SelectedNode)
            OutputName=[];
            if~strcmp(SelectedNode.Text,obj.SignalList.SignalName)
                OutputName=obj.findSignalName(SelectedNode.Parent);
                OutputName=[OutputName,'.',SelectedNode.Text];
            end

        end


        function SignalRemoveButtonPushed(obj)
            selectedIndex=find(contains(obj.SelectedSignals,obj.SelectedSignalListBox.Value));
            obj.SelectedSignals(selectedIndex)=[];
            obj.SelectedSignalListBox.Items=obj.SelectedSignals;
        end


        function SignalRemoveAllButtonPushed(obj)
            obj.SelectedSignals=[];
            obj.SelectedSignalListBox.Items={};
        end


        function SignalDefaultButtonPushed(obj)
            obj.SelectedSignals=obj.DefaultSignals;
            obj.SelectedSignalListBox.Items=obj.SelectedSignals;
        end

    end

end