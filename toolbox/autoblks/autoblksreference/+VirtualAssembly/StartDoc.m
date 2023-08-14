classdef StartDoc<matlab.mixin.SetGet&matlab.mixin.Heterogeneous

    properties

Doc

        FigDoc matlab.ui.Figure
    end

    properties(Access=private)
GridLayout1
GridLayout2
BuildYourVirtualVehicleLabel2
Image2
    end

    methods
        function obj=StartDoc(varargin)

            [doc,fig]=addDocumentFigures(obj);
            obj.Doc=doc;
            obj.FigDoc=fig;

            obj.setStartDoc();

        end

    end

    methods(Access=private)

        function[doc,fig]=addDocumentFigures(obj)

            name='Start';
            tag='Configuration';

            docOptions.Title=name;
            docOptions.DocumentGroupTag=tag;

            doc=matlab.ui.internal.FigureDocument(docOptions);

            doc.Closable=true;

            doc.Figure.AutoResizeChildren='on';
            doc.Opened=true;

            fig=doc.Figure;
            fig.Tag=name;
            fig.AutoResizeChildren='on';
            fig.Interruptible='off';
            fig.BusyAction='cancel';
        end

        function setStartDoc(obj)
            obj.GridLayout1=uigridlayout(obj.FigDoc);
            obj.GridLayout1.ColumnWidth={'1x'};
            obj.GridLayout1.RowHeight={'0.25x','0.02x','1x'};
            obj.GridLayout1.BackgroundColor=[1,1,1];
            obj.GridLayout1.Padding=[10,40,10,40];


            obj.BuildYourVirtualVehicleLabel2=uilabel(obj.GridLayout1);
            obj.BuildYourVirtualVehicleLabel2.FontSize=24;
            obj.BuildYourVirtualVehicleLabel2.FontWeight='bold';
            obj.BuildYourVirtualVehicleLabel2.FontColor=[0,0.4471,0.7412];
            obj.BuildYourVirtualVehicleLabel2.Layout.Row=1;
            obj.BuildYourVirtualVehicleLabel2.Layout.Column=1;
            obj.BuildYourVirtualVehicleLabel2.Text='Build Your Virtual Vehicle ';


            obj.Image2=uiimage(obj.GridLayout1);
            obj.Image2.Layout.Row=3;
            obj.Image2.Layout.Column=1;
            obj.Image2.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','Frontpage.png');
            drawnow();
        end


    end

end