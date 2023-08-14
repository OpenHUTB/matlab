classdef GlobeOptions






























    properties
        EnableHomeButton(1,1)matlab.lang.OnOffSwitchState='off'
        EnableSceneModePicker(1,1)matlab.lang.OnOffSwitchState='off'
        EnableNavigationHelpButton(1,1)matlab.lang.OnOffSwitchState='off'
        EnableBaseLayerPicker(1,1)matlab.lang.OnOffSwitchState='off'
        EnableSelectionIndicator(1,1)matlab.lang.OnOffSwitchState='off'
        EnableAlternateCameraPosition(1,1)matlab.lang.OnOffSwitchState='off'
        EnableMapContextMenu(1,1)matlab.lang.OnOffSwitchState='off'
        EnableDayNightLighting(1,1)matlab.lang.OnOffSwitchState='off'
        EnableInertialCamera(1,1)matlab.lang.OnOffSwitchState='off'
        EnableInfoBox(1,1)matlab.lang.OnOffSwitchState='on'
        Enable2DLaunch(1,1)matlab.lang.OnOffSwitchState='off'
        EnableOSM(1,1)matlab.lang.OnOffSwitchState='on'
    end

    properties(Dependent,Hidden)
CameraPosition
    end

    properties(Hidden)
        UseDebug(1,1)logical=false
    end

    properties(Hidden,Constant)
        DefaultCameraPosition=[0,0,1.5e7]
        DefaultCameraOrientation=[0,-90,360]
        AlternateCameraPosition=[35.1576480381119,-82.5,17190457.997329]
    end

    methods
        function options=enableAll(options)
            options=setAll(options,true);
        end

        function options=disableAll(options)
            options=setAll(options,false);
        end

        function position=get.CameraPosition(options)
            if options.EnableAlternateCameraPosition
                position=options.AlternateCameraPosition;
            else
                position=options.DefaultCameraPosition;
            end
        end
    end

    methods(Access=private)
        function options=setAll(options,value)
            p=properties(options);
            for k=1:length(p)
                options.(p{k})=value;
            end
        end
    end
end
