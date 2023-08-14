function ret=checkEngineInterfacePath











    ret=0;
    [st,~]=dbstack('-completenames');








    if numel(st)<=1
        return
    end



    if numel(st)==2
        if contains(st(2).file,matlabroot)&&...
            strcmp(st(2).name,'EIAdapter.EIAdapter')
            ret=1;
        end
        return;
    end



    if contains(st(3).file,matlabroot)
        ret=1;
        return;
    end



    if strcmp('SLLicenseCheck_XSG',st(2).name)
        ret=1;
    end
end
