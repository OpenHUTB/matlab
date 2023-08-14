function commGroup=CreateCommWidget(this)

    ddgDecidesMax=10000;
    ddgDecidesMin=0;%#ok
    column1Width=300;

    cbInfo.ObjectMethod='OnWidgetChangeCB';
    cbInfo.MethodArgs={'%tag','%dialog','%value'};
    cbInfo.ArgDataTypes={'string','handle','mxArray'};

    commGroup.Type='panel';
    commGroup.Tag='commWidget';
    commGroup.LayoutGrid=[6,2];



    cosimBypass=l_CreateMaskParamWidget(...
    'radiobutton','Connection Mode',this.BypassTag,'CosimBypass',...
    [1,1],[1,1],cbInfo);
    cosimBypass.Entries={'Full Simulation','Confirm Interface Only','No Connection'};
    cosimBypass.ToolTip=[...
    'Full Simulation: Confirm interface and run HDL simulation.<br>',...
    'Confirm Interface Only: Check HDL simulator for proper signal names, ',...
    'dimensions, and datatypes, but do not run HDL simulation.<br>',...
    'No Connection: Do not communicate with the HDL simulator.  ',...
'The HDL simulator does not need to be started.'...
    ];


    cosimBypass.Alignment=2;



    commLocal=l_CreateMaskParamWidget('checkbox',...
    'The HDL simulator is running on this computer.',...
    this.LocalTag,'CommLocal',[2,2],[1,2],cbInfo);

    commShTxt=l_CreateTxtWidget('Connection method:',...
    this.SharedMemTxtTag,[3,3],[1,1],7);
    commShMemLocal=l_CreateMaskParamWidget('combobox',...
    '',this.SharedMemTag,'CommSharedMemory',[3,3],[2,2],cbInfo);
    commShMemLocal.Alignment=5;
    commShMemLocal.Entries={'Socket','Shared Memory'};

    commHostNameTxt=l_CreateTxtWidget('Host name:',...
    this.HostNameTxtTag,[4,4],[1,1],7);
    commHostName=l_CreateMaskParamWidget('edit',...
    '',this.HostNameTag,'CommHostName',[4,4],[2,2],cbInfo);
    commHostName.Alignment=5;

    commPortTxt=l_CreateTxtWidget('Port number or service:',...
    this.PortNumberTxtTag,[5,5],[1,1],7);
    commPortNumber=l_CreateMaskParamWidget('edit',...
    '',this.PortNumberTag,'CommPortNumber',[5,5],[2,2]);
    commPortNumber.Alignment=5;

    commShowInfo=l_CreateMaskParamWidget('checkbox',...
    'Show connection info on icon.',this.ShowInfoTag,...
    'CommShowInfo',[6,6],[1,2],cbInfo);

    cosimBypass.MaximumSize=[ddgDecidesMax,100];
    [commShTxt.MaximumSize,commHostNameTxt.MaximumSize,commPortTxt.MaximumSize]=...
    deal([column1Width,ddgDecidesMax]);

    [ens,vis]=this.GetEnablesAndVisibilities;
    commLocal.Enabled=ens.CommLocal;
    commShMemLocal.Enabled=ens.CommSharedMemory;
    commHostName.Enabled=ens.CommHostName;
    commPortNumber.Enabled=ens.CommPortNumber;
    cosimBypass.Enabled=ens.CosimBypass;
    commShowInfo.Enabled=ens.CommShowInfo;

    commLocal.Visible=vis.CommLocal;
    commShMemLocal.Visible=vis.CommSharedMemory;
    commHostName.Visible=vis.CommHostName;
    commPortNumber.Visible=vis.CommPortNumber;
    cosimBypass.Visible=vis.CosimBypass;
    commShowInfo.Visible=vis.CommShowInfo;

    commShTxt.Visible=vis.CommSharedMemoryTxt;
    commHostNameTxt.Visible=vis.CommHostNameTxt;
    commPortTxt.Visible=vis.CommPortNumberTxt;

    [cosimBypass.Source,commLocal.Source,commShMemLocal.Source,...
    commHostName.Source,commPortNumber.Source,commShowInfo.Source]=deal(this);

    commGroup.Items={cosimBypass,...
    commLocal,commShTxt,commShMemLocal,...
    commHostNameTxt,commHostName,...
    commPortTxt,commPortNumber,...
    commShowInfo};
end

function widget=l_CreateMaskParamWidget(type,name,tag,prop,...
    rowSpan,colSpan,cbInfo)
    widget.Type=type;
    widget.Name=name;
    widget.Tag=tag;
    widget.ObjectProperty=prop;
    widget.Mode=1;
    widget.RowSpan=rowSpan;
    widget.ColSpan=colSpan;
    if nargin==7
        widget.ObjectMethod=cbInfo.ObjectMethod;
        widget.MethodArgs=cbInfo.MethodArgs;
        widget.ArgDataTypes=cbInfo.ArgDataTypes;
    end
end

function widget=l_CreateTxtWidget(name,tag,rowSpan,colSpan,alignment)


    widget.Type='text';
    widget.Name=name;
    widget.Tag=tag;
    widget.RowSpan=rowSpan;
    widget.ColSpan=colSpan;
    widget.Alignment=alignment;
end
