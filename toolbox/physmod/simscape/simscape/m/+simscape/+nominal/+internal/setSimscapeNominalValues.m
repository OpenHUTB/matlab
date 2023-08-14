function status=setSimscapeNominalValues(mdlName,values,units)





    status='';
    try
        nominalValues=simscape.nominal.internal.serializeSimscapeNominalValues(values,units);

        simscape.nominal.internal.validateSimscapeNominalValues(nominalValues);

        set_param(mdlName,'SimscapeNominalValues',nominalValues);
    catch ME
        msgObj=message('physmod:simscape:simscape:nominal:nominal:InvalidModelNominalValue');
        status=[msgObj.getString,' ',ME.message];

        titleMsgObj=message('physmod:simscape:simscape:nominal:nominal:NominalValuesErrorTitle');

        errordlg(status,[titleMsgObj.getString,' ',mdlName],'modal');
    end


end