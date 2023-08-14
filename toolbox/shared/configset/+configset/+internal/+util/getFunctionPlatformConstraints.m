function out=getFunctionPlatformConstraints(dictionary)





    file=fullfile(matlabroot,'toolbox','shared','configset','resources',...
    'constraints_sdp.xml');
    out=configset.internal.Constraints(file);
    if nargin>0
        out.DialogTooltip=message('RTW:configSet:DisabledByPlatform',dictionary).getString;
    end


