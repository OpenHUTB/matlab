function[success,pim]=getHDLWAPluginManager(varargin)











    hasInstall=(exist('hdlwaplugin.internal.SLHDLWAPluginManager','class'));
    if hasInstall
        try
            success=true;
            if nargin==0
                pim=hdlwaplugin.internal.SLHDLWAPluginManager.getInstance();
            else
                pim=hdlwaplugin.internal.SLHDLWAPluginManager.getInstance(varargin{:});
            end
        catch ME
            success=false;
            pim=[];
        end
    else
        success=false;
        pim=[];
    end
