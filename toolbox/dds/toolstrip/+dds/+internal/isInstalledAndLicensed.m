function[value,msg]=isInstalledAndLicensed(varargin)








    if~dig.isProductInstalled('DDS Blockset')
        value=false;
        msg=message('dds:toolstrip:NotInstalled').getString();
    else
        if nargin>0
            method=varargin{1};
            value=license(method,'DDS_Blockset');
            msg='';
        else
            ret=builtin('_license_checkout','DDS_Blockset','quiet');

            if ret
                value=false;
                msg=message('dds:toolstrip:NotLicensed').getString();
            else
                value=true;
                msg='';
            end
        end
    end
