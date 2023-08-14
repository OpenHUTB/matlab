
function CodingStdCustomization=CodingStandard(coding_std_mode,varargin)



    coding_std_mode=upper(coding_std_mode);
    N=length(coding_std_mode);
    matches=@(mode)strncmpi(mode,coding_std_mode,N);

    if(matches('NONE'))
        CodingStdCustomization=hdlcodingstd.BaseCustomizations();
    elseif(matches('INDUSTRY'))
        CodingStdCustomization=hdlcodingstd.IndustryCustomizations(varargin{:});
    else
        error('Currently customizations are supported only for HDLCodingStandard=''Industry'' mode');
    end
end
