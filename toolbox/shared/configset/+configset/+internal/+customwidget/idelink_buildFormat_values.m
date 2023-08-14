function out=idelink_buildFormat_values(cs,name,direction,widgetVals)



    cs=cs.getConfigSet;

    if direction==0
        if isempty(cs)
            out={'',''};
        else
            buildFormat=cs.get_param(name);
            error=DAStudio.message('ERRORHANDLER:pjtgenerator:NoSupportPackageInstalled');
            out={buildFormat,error};
        end
    elseif direction==1
        out=widgetVals{1};
    end

