function out=isDeviceEditable(modelHandle)




    if codertarget.target.isCoderTarget(modelHandle)
        out=false;
    else
        cs=getActiveConfigSet(modelHandle);
        stf=get_param(cs,'SystemTargetFile');
        switch stf
        case 'realtime.tlc'
            out=false;
        case{'ert.tlc','autosar.tlc'}
            out=true;
        otherwise
            out=true;
        end
    end
