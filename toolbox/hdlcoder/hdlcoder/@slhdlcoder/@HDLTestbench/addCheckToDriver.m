function addCheckToDriver(this,mdlName,varargin)%#ok<INUSL>



    hDrv=hdlcurrentdriver;
    if~isempty(hDrv)
        if isempty(mdlName)
            mdlName=hDrv.ModelName;
        end
        opts=[{mdlName},varargin];
        hDrv.addTestbenchCheck(opts{:});
    end
end
