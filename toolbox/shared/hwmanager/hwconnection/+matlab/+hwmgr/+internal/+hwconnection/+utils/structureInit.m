function emptyStruct=structureInit(varargin)






    if isempty(varargin)
        emptyStruct=struct('VendorID',[],'ProductID',[],'Manufacturer',[],'ProductName',[],'SerialNumber',[]);
    else
        emptyStruct=struct('VendorID',[],'ProductID',[],'Manufacturer',[],'ProductName',[],'SerialNumber',[],'SerialPort',[],'MountPoint',[]);
    end