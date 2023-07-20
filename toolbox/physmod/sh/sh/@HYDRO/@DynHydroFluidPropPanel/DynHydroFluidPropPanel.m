function hObj=DynHydroFluidPropPanel(varargin)






    hObj=HYDRO.DynHydroFluidPropPanel;
    hObj.CreateInstanceFcn=PMDialogs.DynCreateInstance;
    hObj.assignObjId();

    if(nargin>0&&ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    end
