classdef TreeViewSectionView<evolutions.internal.ui.tools.ToolstripSection







    properties(Constant)
        Title=getString(message('evolutions:ui:ViewSection'));
        Name='TreeViewSection';
    end

    properties(SetAccess=protected)

FitButton
FitIcon


FullFitButton
FullFitIcon


ZoomInButton
ZoomInIcon


ZoomOutButton
ZoomOutIcon

    end


    events(NotifyAccess=?protected,ListenAccess=?evolutions.internal.app.toolstrip.manage...
        .TreeViewSectionController)


    end


    methods
        function this=TreeViewSectionView(parent)
            this@evolutions.internal.ui.tools.ToolstripSection(parent);
        end

        function enableWidget(this,enabled,widgetName)

            switch widgetName
            case 'Fit'
                this.FitButton.Enabled=enabled;
            case 'FullFit'
                this.FullFitButton.Enabled=enabled;
            case 'ZoomIn'
                this.ZoomInButton.Enabled=enabled;
            otherwise
                assert(strcmp(widgetName,'ZoomOut'));
                this.ZoomOutButton.Enabled=enabled;
            end
        end

    end

    methods(Access=protected)
        function createSectionComponents(this)
            createFitButtonGroup(this);
            createFullFitButtonGroup(this);
            createZoomInButtonGroup(this);
            createZoomOutButtonGroup(this);
        end

        function layoutSection(this)
            add(this.Section.addColumn(),this.FitButton);
            column=this.addColumn('HorizontalAlignment','left');
            add(column,this.ZoomInButton);
            add(column,this.ZoomOutButton);
            add(column,this.FullFitButton);
        end

        function createFitButtonGroup(this)
            iconsPath=this.IconsFilePath;
            this.FitIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(iconsPath,'fitWindow_24.png'));
            this.FitButton=this.createButton(...
            getString(message('evolutions:ui:FitButton')),...
            this.FitIcon,createChildTag(this,'Fit'),...
            getString(message('evolutions:ui:FitButtonToolTip')));
        end

        function createFullFitButtonGroup(this)
            iconsPath=this.IconsFilePath;
            this.FullFitIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(iconsPath,'fullFit_16.png'));
            this.FullFitButton=this.createButton(...
            getString(message('evolutions:ui:FullFitButton')),...
            this.FullFitIcon,...
            createChildTag(this,'FullFit'),...
            getString(message('evolutions:ui:FullFitButtonToolTip')));

        end

        function createZoomInButtonGroup(this)
            iconsPath=this.IconsFilePath;
            this.ZoomInIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(iconsPath,'zoomIn_16.png'));
            this.ZoomInButton=this.createButton(...
            getString(message('evolutions:ui:ZoomInButton')),...
            this.ZoomInIcon,createChildTag(this,'ZoomIn'),...
            getString(message('evolutions:ui:ZoomInButtonToolTip')));
        end

        function createZoomOutButtonGroup(this)
            iconsPath=this.IconsFilePath;
            this.ZoomOutIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(iconsPath,'zoomOut_16.png'));
            this.ZoomOutButton=this.createButton(...
            getString(message('evolutions:ui:ZoomOutButton')),...
            this.ZoomOutIcon,createChildTag(this,'ZoomOut'),...
            getString(message('evolutions:ui:ZoomOutButtonToolTip')));
        end
    end
end
