function hObj=PmHydroFluidPropPanel(varargin)








    hObj=HYDRO.PmHydroFluidPropPanel;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    if((nargin<1))
        error('Wrong number of input arguments (need only one arguments)');
    end

    if(ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    else
        error('Expecting handle for first argument.');
    end

    hSlBlk=pmsl_getdoublehandle(hObj.BlockHandle);




    paramPanel=PMDialogs.PmGroupPanel(hSlBlk,'Parameters','Box');






    fluidDb=sh_stockfluidproperties();
    fluidCell=struct2cell(fluidDb);
    for i=1:length(fluidCell)
        fluidIndices{i}=num2str(i);
        fluidNames{i}=fluidCell{i}.name;
    end


    fluidDropDown=PMDialogs.PmDropDown(hSlBlk,...
    'Hydraulic fluid',...
    'SelFluid',...
    fluidNames,...
    1,...
    '',...
    [],...
    fluidIndices);
    paramPanel.Items=fluidDropDown;




    airEdit=PMDialogs.PmEditBox(hSlBlk,...
    'Relative amount of trapped air',...
    'TrapAir',1);
    paramPanel.Items(end+1)=airEdit;




    sysTempEdit=PMDialogs.PmEditBox(hSlBlk,...
    'System temperature (C)',...
    'SysTemp',1);
    paramPanel.Items(end+1)=sysTempEdit;




    derateViscEdit=PMDialogs.PmEditBox(hSlBlk,...
    'Viscosity derating factor',...
    'ViscDerFactor',1);
    paramPanel.Items(end+1)=derateViscEdit;




    rangeDropDown=PMDialogs.PmDropDown(hSlBlk,...
    'Pressure below absolute zero',...
    'range_error',...
    {'Warning','Error'},...
    1,...
    '',...
    [],...
    {'1','2'});
    paramPanel.Items(end+1)=rangeDropDown;




    displayPanel=PMDialogs.PmGroupPanel(hSlBlk,'dummy','NoBoxNoTitle');




    densityDisp=PMDialogs.PmDisplayBox(hSlBlk,'Density (kg/m^3):',1);
    displayPanel.Items=densityDisp;




    viscosityDisp=PMDialogs.PmDisplayBox(hSlBlk,'Viscosity (cSt):',1);
    displayPanel.Items(end+1)=viscosityDisp;




    modulusDisp=PMDialogs.PmDisplayBox(hSlBlk,sprintf('Bulk modulus (Pa) at atm. pressure and no gas:'),1);
    displayPanel.Items(end+1)=modulusDisp;




    errorTxt=PMDialogs.PmDisplayBox(hSlBlk,'Error:',2);




    hybridPanel=PMDialogs.PmGroupPanel(hSlBlk,'Fluid Properties:','flat');
    hybridPanel.Items=[displayPanel,errorTxt];

    paramPanel.Items(end+1)=hybridPanel;




    hObj.Items=paramPanel;

end
