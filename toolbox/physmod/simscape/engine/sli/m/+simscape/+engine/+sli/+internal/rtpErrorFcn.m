function newException=rtpErrorFcn(~,~,originalException)




    ud=get_param(originalException.handles{1},'UserData');
    newHandle=get_param(ud.block,'Handle');
    newException=recreateException(originalException,newHandle,ud);
end

function[errid,errmsg]=adjustErrorIdAndMessage(errid,errmsg,handle,ud)


    switch errid

    case{'Simulink:Parameters:InvParamSetting',...
        'Simulink:Parameters:InvRTParamComplexityChange',...
        'Simulink:Parameters:InvRTParamDimChange',...
        'Simulink:Parameters:InvRTParamDTypeChange'}

        err=pm_errorstruct(...
        'physmod:simscape:engine:sli:error:InvalidRTParamSetting',...
        ud.param,pmsl_sanitizename(ud.block));
        errid=err.identifier;
        errmsg=err.message;

    otherwise



        newerrmsg=strrep(errmsg,pmsl_sanitizename(getfullname(handle)),...
        pmsl_sanitizename(ud.block));
        if~strcmp(newerrmsg,errmsg)
            errmsg=strrep(newerrmsg,'''Value''',['''',ud.param,'''']);
        end
    end
end

function newEx=recreateException(oldEx,newHandle,ud)

    [errid,errmsg]=adjustErrorIdAndMessage(oldEx.identifier,oldEx.message,...
    oldEx.handles{1},ud);


    newEx=recreateTopException(oldEx,errid,errmsg,newHandle);


    causes=[oldEx.cause{:}];
    for i=1:length(causes)
        newEx=newEx.addCause(...
        recreateException(causes(i),newHandle,ud));
    end

end
