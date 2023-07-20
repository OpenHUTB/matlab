function getSimscapeNominalValues(mdlName)







    values={};
    units={};

    try
        nominalValueStr=get_param(mdlName,'SimscapeNominalValues');

        nominalValues=simscape.nominal.internal.deserializeSimscapeNominalValues(nominalValueStr);
        values={nominalValues.value};
        units={nominalValues.unit};
        pm_assert(numel(values)==numel(units));

        simscape.nominal.internal.addRenameCallback(mdlName);

        simscape.nominal.internal.addCloseCallback(mdlName);

    catch ME
        exceptionCause=ME.cause;
        msg='';
        if~isempty(exceptionCause)
            msg=[' ',exceptionCause{1}.message];
        end

        msgObj=message('physmod:simscape:simscape:nominal:nominal:InvalidModelNominalValue');
        status=[msgObj.getString,msg];

        titleMsgObj=message('physmod:simscape:simscape:nominal:nominal:NominalValuesErrorTitle');
        errordlg(status,[titleMsgObj.getString,' ',mdlName],'modal');
    end


    try

        import simscape.nominal.internal.viewer.*
        model=NominalValueModel(mdlName,values,units);
        view=NominalValueView();
        NominalValueController(model,view);

    catch ME
        ME.throwAsCaller();
    end

end
