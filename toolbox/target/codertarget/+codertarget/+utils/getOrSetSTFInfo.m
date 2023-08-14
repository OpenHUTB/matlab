function outInfo=getOrSetSTFInfo(inInfo)




    persistent CODERTARGET_INTERNAL_STF_INFO

    if isempty(CODERTARGET_INTERNAL_STF_INFO)
        CODERTARGET_INTERNAL_STF_INFO=0;
    end

    if~isequal(nargin,0)
        CODERTARGET_INTERNAL_STF_INFO=inInfo;
    end
    outInfo=CODERTARGET_INTERNAL_STF_INFO;

end