function[tf,zmin,zmax]=useZRange(hObj)
















    cache=hObj.getContourDataCache();
    z=hObj.ZData;
    [zmin,zmax]=cache.getZDataRange(z);
    tf=zmax~=zmin;

end
