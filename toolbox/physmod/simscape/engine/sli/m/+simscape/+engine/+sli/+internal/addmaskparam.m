function b=addmaskparam(pstruct,param,varargin)

















    narginchk(2,nargin);


    cTempMaskParam=[];
    MaskStruct=[];


    if isfield(pstruct,'maskedProps')
        MaskStruct=pstruct.maskedProps;
        if isfield(MaskStruct,param)
            cTempMaskParam=getfield(MaskStruct,param);
        end
    end


    if isempty(cTempMaskParam)

        pm=getappdata(0,'pmGlobals');
        cTempMaskParam=pm.MASK_PARAM;
        cTempMaskParam{pm.VAR_NAME}=param;
        cTempMaskParam{pm.VAR_LABEL}=param;
    end



    for(idx=1:2:length(varargin)),
        cTempMaskParam{varargin{idx}}=varargin{idx+1};
    end

    if isempty(MaskStruct)


        pstruct.maskedProps=struct(param,{cTempMaskParam});
    else

        pstruct.maskedProps=setfield(MaskStruct,param,cTempMaskParam);
    end

    b=pstruct;
