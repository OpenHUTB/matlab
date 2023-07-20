

classdef IncrementalCodeGenStatus<handle
    properties
        regenModel=true;
        regenCode=true;
        hdlCodeGenStatus=struct('CodeGenStatus',[],...
        'ModelGenStatus',[],...
        'GenFileList',[]);
        newHDLCodeGenStatus=struct('CodeGenStatus',[],...
        'ModelGenStatus',[],...
        'GenFileList',[]);
    end
end
