classdef VehClassDoc<matlab.mixin.SetGet&matlab.mixin.Heterogeneous

    properties

Doc

        FigDoc matlab.ui.Figure

AppContainer
    end

    events
PassengerCarImgSelected
MotorcycleImgSelected
    end

    methods
        function obj=VehClassDoc(AppContainer)
            obj.AppContainer=AppContainer;

            [doc,fig]=addDocumentFigures(obj);
            obj.Doc=doc;
            obj.FigDoc=fig;

            obj.setVehClassDoc();

        end

    end

    methods(Access=private)

        function[doc,fig]=addDocumentFigures(obj)

            name='VehicleClass';
            tag='Configuration';

            docOptions.Title=name;
            docOptions.DocumentGroupTag=tag;

            doc=matlab.ui.internal.FigureDocument(docOptions);

            doc.Closable=true;

            doc.Figure.AutoResizeChildren='on';

            obj.AppContainer.add(doc);
            drawnow();

            fig=doc.Figure;
            fig.Tag=name;
            fig.AutoResizeChildren='on';
            fig.Interruptible='off';
            fig.BusyAction='cancel';
        end

        function setVehClassDoc(obj)



            GridLayout2=uigridlayout(obj.FigDoc);
            GridLayout2.ColumnWidth={'1x'};
            GridLayout2.RowHeight={'1x'};
            GridLayout2.BackgroundColor=[1,1,1];
            GridLayout2.Padding=[10,40,10,10];


            GridLayout4=uigridlayout(GridLayout2);
            GridLayout4.ColumnWidth={'1x','0.2x','1x','0.2x','1x','0.2x'};
            GridLayout4.RowHeight={'0.3x','0.2x','1x','0.2x','1x'};
            GridLayout4.ColumnSpacing=0;
            GridLayout4.RowSpacing=0;
            GridLayout4.Padding=[0,0,0,0];
            GridLayout4.Layout.Row=1;
            GridLayout4.Layout.Column=1;
            GridLayout4.BackgroundColor=[1,1,1];


            SelectYourVehicleLabel=uilabel(GridLayout4);
            SelectYourVehicleLabel.FontSize=20;
            SelectYourVehicleLabel.FontWeight='bold';
            SelectYourVehicleLabel.FontColor=[0,0.4471,0.7412];
            SelectYourVehicleLabel.Layout.Row=1;
            SelectYourVehicleLabel.Layout.Column=1;
            SelectYourVehicleLabel.Text=' Select Your Vehicle';


            PassengerCarLabel=uilabel(GridLayout4);
            PassengerCarLabel.HorizontalAlignment='center';
            PassengerCarLabel.FontSize=16;
            PassengerCarLabel.FontWeight='bold';
            PassengerCarLabel.Layout.Row=2;
            PassengerCarLabel.Layout.Column=1;
            PassengerCarLabel.Text='Passenger Car';


            PassCarImage=uiimage(GridLayout4);
            PassCarImage.ImageClickedFcn=@(~,event)PassCarImageClicked(obj);
            PassCarImage.Layout.Row=3;
            PassCarImage.Layout.Column=1;
            PassCarImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','Sedan.png');
            PassCarImage.Tag='PassCarImage';


            MotorcycleLabel=uilabel(GridLayout4);
            MotorcycleLabel.HorizontalAlignment='center';
            MotorcycleLabel.FontSize=16;
            MotorcycleLabel.FontWeight='bold';
            MotorcycleLabel.Layout.Row=2;
            MotorcycleLabel.Layout.Column=3;
            MotorcycleLabel.Text='Motorcycle';


            MotorcycleImage=uiimage(GridLayout4);
            MotorcycleImage.ImageClickedFcn=@(~,event)MotorcycleImageClicked(obj);
            MotorcycleImage.Layout.Row=3;
            MotorcycleImage.Layout.Column=3;
            MotorcycleImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','Motorcycle.png');
            MotorcycleImage.Tag='MotorcycleImage';
        end

        function PassCarImageClicked(obj)
            value=struct('VehClass','PassengerCar');
            data=VirtualAssembly.VirtualAssemblyEventData(value);
            notify(obj,'PassengerCarImgSelected',data);
        end

        function MotorcycleImageClicked(obj)
            value=struct('VehClass','Motorcycle');
            data=VirtualAssembly.VirtualAssemblyEventData(value);
            notify(obj,'MotorcycleImgSelected',data);
        end


    end

end