classdef VehSetupDoc<matlab.mixin.SetGet&matlab.mixin.Heterogeneous





    properties
HAppContainer

Doc

        FigDoc matlab.ui.Figure

ProjNameText

ProjFolderText

ModelNameText

PlantModel

VehClass

VehArch

VehDyn
    end

    properties(SetAccess=private)

MainGridLayout
VehClassGrid
VehClassLabel
PassCarImage
MotorCycleImage
PowertrainLabel
PowertrainDpdn
PMLLabel
PMLDpdn
VehDynLabel
VehDynGrid
VehDynLongImage
VehDynLatImage

        VehCreateButton matlab.ui.control.Button
ProjName
ProjNameLabel
ProjPath
ProjPathLabel
ModelName
ModelNameLabel
        ProjPathBrowser matlab.ui.control.Button
PowertrainImage
vdbs_install
ptbs_install
ssc_install
product
    end

    events
CreateNewButtClicked
VehDynBoxSetup
VehArctChanged
PlantModelSetup
    end


    methods

        function obj=VehSetupDoc(varargin)
            import matlab.internal.project.util.generateFolderGroupNames;

            if~isempty(varargin)
                set(obj,varargin{:});
            end


            obj.ProjNameText='';

            if isempty(obj.ProjFolderText)
                if matlab.ui.internal.desktop.isMOTW
                    workFolder=matlab.internal.examples.getExamplesDir();


                    exampleFolderRoot=fullfile(workFolder,'projects');
                else

                    workFolder=matlab.internal.project.util.getDefaultProjectFolder();

                    exampleFolderRoot=fullfile(workFolder,'examples');
                end
                obj.ProjFolderText=exampleFolderRoot;
            end

            if isempty(obj.ModelNameText)
                obj.ModelNameText='ConfiguredVirtualVehicleModel';
            end

            if isempty(obj.PlantModel)
                obj.PlantModel='Simulink';
            end

            if isempty(obj.VehDyn)
                obj.VehDyn=false;
            end

            [doc,fig]=addDocumentFigures(obj,'Setup');
            obj.Doc=doc;
            obj.FigDoc=fig;

            obj.product=ver;

            checkLicenseandProduct2(obj);

            obj.setupDocLyt();
        end

    end

    methods
        function set.ProjNameText(obj,val)
            obj.ProjNameText=val;

            obj.setProjName(val);

        end

        function set.ProjFolderText(obj,val)
            obj.ProjFolderText=val;
            obj.setProjPath(val);
        end

        function set.ModelNameText(obj,val)
            obj.ModelNameText=val;
            obj.setModelName(val);
        end



        function selectVehClass(obj,value)
            obj.VehClass=value;

            obj.selectPasscar();
            obj.VehCreateButton.Enable='off';




        end

        function selectVehArchitecture(obj,value)
            if~obj.ptbs_install&&(~strcmp(value,'Conventional Vehicle')&&~strcmp(value,'Electric Vehicle 1EM'))
                warndlg(message('autoblks_reference:autoerrVirtualAssembly:InvalidPTBSLicense').getString);
            end
            obj.PowertrainDpdn.Value=value;
            setPowertrain(obj);
        end

        function selectVehDyn(obj,value)
            if~obj.vdbs_install&&value~=0
                warndlg(message('autoblks_reference:autoerrVirtualAssembly:InvalidVDBSLicense').getString);
            end
            setVehDynVisibility(obj,value);
            obj.VehDynBoxChanged(value);
        end

        function setVehDynVisibility(obj,value)

            obj.VehDyn=logical(value);

            if obj.VehDyn==0
                obj.VehDynLongImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','VehDynLong.png');
                obj.VehDynLatImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','VehDynLatGray.png');
            else
                obj.VehDynLongImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','VehDynLongGray.png');
                obj.VehDynLatImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','VehDynLat.png');
            end

        end

        function selectModelLanguage(obj,value)
            obj.PMLDpdn.Value=value;
            obj.PlantModelChanged();
        end

        function setPowertrain(obj)
            obj.VehArch=obj.PowertrainDpdn.Value;
            switch obj.PowertrainDpdn.Value
            case 'Conventional Vehicle'
                obj.PowertrainImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','ConVeh.svg');
            case 'Electric Vehicle 1EM'
                obj.PowertrainImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','EV.svg');
            case 'Hybrid Electric Vehicle IPS'
                obj.PowertrainImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','HEVIPS.svg');
            case 'Hybrid Electric Vehicle MM'
                obj.PowertrainImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','HEVMM.svg');
            case 'Hybrid Electric Vehicle P0'
                obj.PowertrainImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','HEVP0.svg');
            case 'Hybrid Electric Vehicle P1'
                obj.PowertrainImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','HEVP1.svg');
            case 'Hybrid Electric Vehicle P2'
                obj.PowertrainImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','HEVP2.svg');
            case 'Hybrid Electric Vehicle P3'
                obj.PowertrainImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','HEVP3.svg');
            case 'Hybrid Electric Vehicle P4'
                obj.PowertrainImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','HEVP4.svg');
            otherwise
                obj.PowertrainImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','Drivetrain.png');
            end
        end

        function PlantModelChanged(obj)

            if~obj.ssc_install&&~strcmp(obj.PMLDpdn.Value,'Simulink')
                warndlg(message('autoblks_reference:autoerrVirtualAssembly:InvalidSSCLicense').getString);
            end

            obj.PlantModel=obj.PMLDpdn.Value;
            if strcmp(obj.PlantModel,'Simscape')


                obj.VehDynLatImage.Visible=false;
                obj.VehDynLongImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','VehDynLong.png');
                obj.VehDyn=0;

            else
                obj.VehDynLatImage.Visible=true;
                obj.VehDynLatImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
                'images','VehDynLatGray.png');
            end

            value=struct('PlantModel',obj.PlantModel,'VehDyn',obj.VehDyn);
            data=VirtualAssembly.VirtualAssemblyEventData(value);

            notify(obj,'PlantModelSetup',data);

        end


        function setProjSettings(obj,status)
            obj.ProjName.Enable=status;
            obj.ProjPath.Enable=status;
            obj.ModelName.Enable=status;
            obj.ProjPathBrowser.Enable=status;

        end
    end


    methods(Access=private)
        function[doc,fig]=addDocumentFigures(obj,name)


            docOptions.Title=name;
            docOptions.DocumentGroupTag='Configuration';

            doc=matlab.ui.internal.FigureDocument(docOptions);

            doc.Closable=false;

            doc.Figure.AutoResizeChildren='on';

            fig=doc.Figure;
            fig.Tag=name;
            fig.AutoResizeChildren='on';
            fig.Interruptible='off';
            fig.BusyAction='cancel';
        end

        function setupDocLyt(obj)

            obj.MainGridLayout=uigridlayout(obj.FigDoc,[4,2]);
            obj.MainGridLayout.ColumnWidth={'0.3x','1x','0.2x'};
            obj.MainGridLayout.RowHeight={'fit','fit','0.1x','fit','0.2x','fit','0.1x','fit','fit'};
            obj.MainGridLayout.Padding=[10,10,10,10];
            obj.MainGridLayout.BackgroundColor=[1,1,1];















            obj.ProjPathLabel=uilabel(obj.MainGridLayout,...
            'Text','Project path:',...
            'FontWeight','bold');
            obj.ProjPathLabel.Layout.Row=1;
            obj.ProjPathLabel.Layout.Column=1;

            obj.ProjPath=uieditfield(obj.MainGridLayout,...
            'Value',obj.ProjFolderText,...
            'ValueChangedFcn',@(src,event)obj.ProjPathChangedFcn(src,event));
            obj.ProjPath.Layout.Row=1;
            obj.ProjPath.Layout.Column=2;
            obj.ProjPath.Tag='ProjPath';

            obj.ProjPathBrowser=uibutton(obj.MainGridLayout,'push');
            obj.ProjPathBrowser.Text='Browse';
            obj.ProjPathBrowser.Tag='BrowserButton';
            obj.ProjPathBrowser.Layout.Row=1;
            obj.ProjPathBrowser.Layout.Column=3;
            obj.ProjPathBrowser.ButtonPushedFcn=@(~,~)ProjPathBrowserPushed(obj);

            obj.ModelNameLabel=uilabel(obj.MainGridLayout,...
            'Text','Model name:',...
            'FontWeight','bold');
            obj.ModelNameLabel.Layout.Row=2;
            obj.ModelNameLabel.Layout.Column=1;

            obj.ModelName=uieditfield(obj.MainGridLayout,...
            'Value',obj.ModelNameText,...
            'ValueChangedFcn',@(src,event)obj.ModelNameChangedFcn(src,event));
            obj.ModelName.Layout.Row=2;
            obj.ModelName.Layout.Column=2;
            obj.ModelName.Tag='ModelName';


            obj.VehClassLabel=uilabel(obj.MainGridLayout,...
            'Text','Vehicle class:',...
            'FontWeight','bold');
            obj.VehClassLabel.Layout.Row=3;
            obj.VehClassLabel.Layout.Column=1;

            obj.VehClassGrid=uigridlayout(obj.MainGridLayout,...
            'ColumnWidth',{'1x','1x'},...
            'RowHeight',{'1x'},...
            'BackgroundColor',[1,1,1],...
            'ColumnSpacing',10);
            obj.VehClassGrid.Layout.Row=3;
            obj.VehClassGrid.Layout.Column=2;

            obj.PassCarImage=uiimage(obj.VehClassGrid);
            obj.PassCarImage.Layout.Row=1;
            obj.PassCarImage.Layout.Column=1;
            obj.PassCarImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','SedanGray.png');
            obj.PassCarImage.Tag='PassCarImage';

            obj.PassCarImage.Tooltip='Passenger car';
            obj.PassCarImage.Enable=true;


            obj.PowertrainLabel=uilabel(obj.MainGridLayout,...
            'Text','Powertrain architecture:',...
            'FontWeight','bold');
            obj.PowertrainLabel.Layout.Row=4;
            obj.PowertrainLabel.Layout.Column=1;

            obj.PowertrainDpdn=uidropdown(obj.MainGridLayout,...
            'Items',{'None'});

            obj.PowertrainDpdn.Layout.Row=4;
            obj.PowertrainDpdn.Layout.Column=2;
            obj.PowertrainDpdn.Enable='off';
            obj.PowertrainDpdn.Tag='PowertrainDpdn';
            obj.PowertrainDpdn.ValueChangedFcn=@(src,event)PowertrainSelected(obj,src,event);


            obj.PowertrainImage=uiimage(obj.MainGridLayout);
            obj.PowertrainImage.Layout.Row=5;
            obj.PowertrainImage.Layout.Column=2;
            obj.PowertrainImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','Drivetrain.png');
            obj.PowertrainImage.Tag='PowertrainImage';


            obj.PMLLabel=uilabel(obj.MainGridLayout,...
            'Text','Model template:',...
            'FontWeight','bold');
            obj.PMLLabel.Layout.Row=6;
            obj.PMLLabel.Layout.Column=1;

            obj.PMLDpdn=uidropdown(obj.MainGridLayout,...
            'Items',{'Simulink','Simscape'},...
            'Value',obj.PlantModel,'ValueChangedFcn',@(~,~)PlantModelChanged(obj));


            obj.PMLDpdn.Layout.Row=6;
            obj.PMLDpdn.Layout.Column=2;
            obj.PMLDpdn.Enable='off';
            obj.PMLDpdn.Tag='ModelDpdn';


            obj.VehDynLabel=uilabel(obj.MainGridLayout,...
            'Text','Vehicle dynamics:',...
            'FontWeight','bold');
            obj.VehDynLabel.Layout.Row=7;
            obj.VehDynLabel.Layout.Column=1;

            obj.VehDynGrid=uigridlayout(obj.MainGridLayout,...
            'ColumnWidth',{'1x','1x'},...
            'RowHeight',{'1x'},...
            'BackgroundColor',[1,1,1],...
            'ColumnSpacing',10);
            obj.VehDynGrid.Layout.Row=7;
            obj.VehDynGrid.Layout.Column=2;

            obj.VehDynLongImage=uiimage(obj.VehDynGrid);
            obj.VehDynLongImage.Layout.Row=1;
            obj.VehDynLongImage.Layout.Column=1;
            obj.VehDynLongImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','VehDynLongGray.png');
            obj.VehDynLongImage.Tag='LongImage';
            obj.VehDynLongImage.ImageClickedFcn=@(~,~)VehLongClicked(obj);
            obj.VehDynLongImage.Tooltip='Longitudinal vehicle dynamics';
            obj.VehDynLongImage.Enable='off';

            obj.VehDynLatImage=uiimage(obj.VehDynGrid);
            obj.VehDynLatImage.Layout.Row=1;
            obj.VehDynLatImage.Layout.Column=2;
            obj.VehDynLatImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','VehDynLatGray.png');
            obj.VehDynLatImage.Tooltip='Combined longitudinal and lateral vehicle dynamics';
            obj.VehDynLatImage.Tag='LatImage';
            obj.VehDynLatImage.ImageClickedFcn=@(~,~)VehLatClicked(obj);
            obj.VehDynLatImage.Enable='off';


            obj.VehCreateButton=uibutton(obj.MainGridLayout,'push');
            obj.VehCreateButton.ButtonPushedFcn=@(~,~)VehCreateButtonPushed(obj);
            obj.VehCreateButton.Layout.Row=8;
            obj.VehCreateButton.Layout.Column=3;
            obj.VehCreateButton.Text='Create';
            obj.VehCreateButton.Tag='VehCreateButton';
            obj.VehCreateButton.Enable='off';

            drawnow();
            obj.PassCarClassClicked();
        end

        function checkLicenseandProduct2(obj)






















            obj.ptbs_install=dig.isProductInstalled('Powertrain Blockset');
            obj.vdbs_install=dig.isProductInstalled('Vehicle Dynamics Blockset');
            sc_install=dig.isProductInstalled('Simscape');
            sscd_install=dig.isProductInstalled('Simscape Driveline');
            ssce_install=dig.isProductInstalled('Simscape Electrical');
            sscf_install=dig.isProductInstalled('Simscape Fluids');

            if(~sc_install||~sscd_install||~ssce_install||~sscf_install)
                obj.ssc_install=false;
            else
                obj.ssc_install=true;
            end

        end

        function ok=checkLicenseandProduct(obj,lic)
            ok=true;
            switch lic
            case 'vdbs'

                if~obj.vdbs_install
                    warndlg(message('autoblks_reference:autoerrVirtualAssembly:InvalidVDBSLicense').getString);
                    ok=false;
                    return;
                end
            case 'ptbs'

                if~obj.ptbs_install
                    warndlg(message('autoblks_reference:autoerrVirtualAssembly:InvalidPTBSLicense').getString);
                    ok=false;
                    return;
                end
            case 'ssc'
                if~obj.ssc_install
                    warndlg(message('autoblks_reference:autoerrVirtualAssembly:InvalidSSCLicense').getString);
                    ok=false;
                    return;
                end
            otherwise
                return;
            end
        end

        function PowertrainSelected(obj,src,event)

            if~strcmp(event.Value,'Conventional Vehicle')&&~strcmp(event.Value,'Electric Vehicle 1EM')
                obj.checkLicenseandProduct('ptbs');
            end

            setPowertrain(obj);

            value=struct('Powertrain',obj.PowertrainDpdn.Value,...
            'PreviousPowertrain',event.PreviousValue);
            data=VirtualAssembly.VirtualAssemblyEventData(value);
            notify(obj,'VehArctChanged',data);

        end

        function VehLongClicked(obj)

            prev=obj.VehDyn;
            obj.VehDyn=0;
            obj.VehDynLongImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','VehDynLong.png');
            obj.VehDynLatImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','VehDynLatGray.png');

            obj.VehDynBoxChanged(prev);
        end

        function VehLatClicked(obj)

            obj.checkLicenseandProduct('vdbs');
            prev=obj.VehDyn;
            obj.VehDyn=1;
            obj.VehDynLongImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','VehDynLongGray.png');
            obj.VehDynLatImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','VehDynLat.png');

            obj.VehDynBoxChanged(prev);

        end

        function VehDynBoxChanged(obj,prev)

            value=struct('VehDyn',obj.VehDyn,...
            'PrevVehDyn',prev);
            data=VirtualAssembly.VirtualAssemblyEventData(value);
            notify(obj,'VehDynBoxSetup',data);
        end


        function VehCreateButtonPushed(obj)
            max_dir_length=80;
            cur_dir_length=length(obj.ProjPath.Value);
            if cur_dir_length>max_dir_length
                warndlg('The combined directory and project name must be less than 80 characters.','warning');
                return;
            end

            if obj.VehDyn==1
                VehDynOut='Lateral Vehicle Dyanmics';
            else
                VehDynOut='Vehicle Body 3DOF Longitudinal';
            end

            obj.setProjSettings(false);














            ProjDir=obj.ProjPath.Value;

            value=struct('VehClass',obj.VehClass,'Powertrain',obj.VehArch,'Model',obj.PlantModel,'VehDyn',VehDynOut,'PlantModel',obj.PlantModel,'ProjDir',ProjDir,'ModelName',obj.ModelNameText);
            data=VirtualAssembly.VirtualAssemblyEventData(value);
            notify(obj,'CreateNewButtClicked',data);
            obj.VehCreateButton.Enable='off';
        end


        function ProjPathBrowserPushed(obj)
            pathvalue=uigetdir(pwd,'Select your project directory');
            if pathvalue
                obj.ProjPath.Value=pathvalue;
                obj.ProjFolderText=pathvalue;
            end

            obj.HAppContainer.App.bringToFront();

        end

        function ProjNameChangedFcn(obj,~,event)
            obj.ProjNameText=event.Value;
        end

        function ProjPathChangedFcn(obj,~,event)
            obj.ProjFolderText=event.Value;
        end

        function ModelNameChangedFcn(obj,~,event)
            obj.ModelNameText=event.Value;
        end

        function PassCarClassClicked(obj)
            obj.VehClass='PassengerCar';
            obj.selectPasscar();
            obj.selectVehArchitecture('Conventional Vehicle');
        end

        function selectPasscar(obj)
            obj.PassCarImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','Sedan.png');



            obj.PowertrainDpdn.Items={'Conventional Vehicle','Electric Vehicle 1EM','Hybrid Electric Vehicle P0',...
            'Hybrid Electric Vehicle P1','Hybrid Electric Vehicle P2','Hybrid Electric Vehicle P3','Hybrid Electric Vehicle P4','Hybrid Electric Vehicle MM','Hybrid Electric Vehicle IPS'};
            obj.PowertrainDpdn.Enable='on';
            obj.VehDynLongImage.Enable='on';
            obj.VehDynLongImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','VehDynLong.png');
            obj.VehDyn=0;
            obj.VehDynLatImage.Enable='on';
            obj.VehCreateButton.Enable='on';

            obj.PMLDpdn.Enable='on';

        end

        function MotorcycleClassClicked(obj)
            obj.PassCarImage.ImageSource=fullfile(matlabroot,'toolbox','autoblks','autoblksreference',...
            'images','SedanGray.png');


            obj.VehClass='Motorcycle';
            obj.PowertrainDpdn.Items={'Conventional Mortorcycle','Electric Mortorcycle'};
            obj.PowertrainDpdn.Enable='on';


            obj.VehCreateButton.Enable='on';
            obj.PMLDpdn.Enable='on';

            obj.selectVehArchitecture('Conventional Mortorcycle');
        end

        function setProjName(obj,val)
            if~isempty(obj.ProjName)
                obj.ProjName.Value=val;
            end
        end

        function setProjPath(obj,val)
            if~isempty(obj.ProjPath)
                obj.ProjPath.Value=val;
            end
        end

        function setModelName(obj,val)
            if~isempty(obj.ModelName)
                obj.ModelName.Value=val;
            end
        end

    end

end