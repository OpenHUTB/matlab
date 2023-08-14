function[result,cc,requiredcc]=isTensorRTDataTypeSupported(datatype,varargin)





    computeWarnId='parallel:gpu:device:DeviceDeprecated';
    warning('off',computeWarnId);

    if strcmp(datatype,'int8')
        requiredMaj=6;
        requiredMin=1;
    else
        if strcmp(datatype,'fp16')
            requiredMaj=7;
            requiredMin=0;
        end
    end

    requiredcc=[num2str(requiredMaj),'.',num2str(requiredMin)];

    if nargin==1
        gDev=gpuDevice();
        cc=gDev.ComputeCapability;
    else
        cc=varargin{1};
    end
    ccMaj=str2double(cc(1));
    ccMin=str2double(cc(3));

    result=ccMaj>requiredMaj||(ccMaj==requiredMaj&&ccMin>=requiredMin);

    if strcmp(datatype,'int8')&&ccMaj==6&&ccMin==2
        result=false;
    end


    warning('on',computeWarnId);

end
