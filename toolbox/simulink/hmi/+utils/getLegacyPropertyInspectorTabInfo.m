function desc=getLegacyPropertyInspectorTabInfo(block)






    widgetType=block.WebBlockType;
    descList={...
    'discreteknob','SimulinkHMI:dialogs:DiscreteKnobDialogDesc';...
    'sliderswitch','SimulinkHMI:dialogs:SwitchDialogDesc';...
    'circulargauge','SimulinkHMI:dialogs:CircularGaugeDialogDesc';...
    'sdiscope','SimulinkHMI:dialogs:HMIScopeDialogDesc';...
    'continuousknob','SimulinkHMI:dialogs:ContinuousKnobDialogDesc';...
    'toggleswitch','SimulinkHMI:dialogs:SwitchDialogDesc';...
    'semicirculargauge','SimulinkHMI:dialogs:SemicircularGaugeDialogDesc';...
    'ninetydegreegauge','SimulinkHMI:dialogs:NinetydegreeGaugeDialogDesc';...
    'rockerswitch','SimulinkHMI:dialogs:SwitchDialogDesc';...
    'slider','SimulinkHMI:dialogs:SliderDialogDesc';...
    'lamp','SimulinkHMI:dialogs:LampDialogDesc';...
    'lineargauge','SimulinkHMI:dialogs:LinearGaugeDialogDesc';...
    'pushbutton','SimulinkHMI:dialogs:PushButtonDialogDesc';...
    'multistateimage','SimulinkHMI:dialogs:MultiStateImageDialogDesc';...
    'headingindicator','aeroblksHMI:aeroblkhmi:HeadingIndicatorDialogDesc';...
    'altimeter','aeroblksHMI:aeroblkhmi:AltimeterDialogDesc';...
    'climbindicator','aeroblksHMI:aeroblkhmi:ClimbIndicatorDialogDesc';...
    'egtindicator','aeroblksHMI:aeroblkhmi:EGTIndicatorDialogDesc';...
    'rpmindicator','aeroblksHMI:aeroblkhmi:RPMIndicatorDialogDesc';...
    'airspeedindicator','aeroblksHMI:aeroblkhmi:AirspeedIndicatorDialogDesc';...
    'turncoordinator','aeroblksHMI:aeroblkhmi:TurnCoordinatorDialogDesc';...
    'artificialhorizon','aeroblksHMI:aeroblkhmi:ArtificialHorizonDialogDesc';...
    };
    idx=find(strcmpi(widgetType,{descList{:,1}}));%#ok<CCAT1>
    if idx~=0
        desc=descList{idx,2};
    else
        desc=block.MaskDescription;
    end