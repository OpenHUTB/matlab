function title=getFunctionTitle(obj,fcn,fcnName)
    ccm=obj.Data;
    title='';
    if ccm.FcnInfoMap(fcn).IsStatic
        [~,file,ext]=fileparts(ccm.FcnInfoMap(fcn).File{1});
        title=sprintf(obj.msgs.staticFcn_tooltip,fcnName,[file,ext]);
    end
end
