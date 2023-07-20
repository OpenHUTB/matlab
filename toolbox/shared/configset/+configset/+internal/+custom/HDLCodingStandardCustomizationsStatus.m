function[status,dscr]=HDLCodingStandardCustomizationsStatus(cs,name)



    dscr='';
    hdlcc=cs.getComponent('HDL Coder');
    cli=hdlcc.getCLI;

    standard=cli.HDLCodingStandard;
    cso=cli.HDLCodingStandardCustomizations;

    if strcmpi(standard,'None')


        status=configset.internal.data.ParamStatus.ReadOnly;
    else
        if~isa(cso,'hdlcodingstd.IndustryCustomizations')


            cso=hdlcoder.CodingStandard('Industry');
        end
        nameParts=split(name,'_');
        csoName=nameParts{1}(4:end);
        enable=cso.(csoName).enable;
        if enable
            status=configset.internal.data.ParamStatus.Normal;
        else
            status=configset.internal.data.ParamStatus.ReadOnly;
        end

    end


