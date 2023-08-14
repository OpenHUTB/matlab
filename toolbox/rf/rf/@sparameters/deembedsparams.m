function dut_sobj=deembedsparams(total_sobj,left_sobj,right_sobj)




    narginchk(3,3)

    validateattributes(total_sobj,{'numeric','sparameters'},{},...
    'deembedsparams','',1)
    validateattributes(left_sobj,{'numeric','sparameters'},{},...
    'deembedsparams','',2)
    validateattributes(right_sobj,{'numeric','sparameters'},{},...
    'deembedsparams','',3)

    if isnumeric(total_sobj)||isnumeric(left_sobj)||isnumeric(right_sobj)

        error(message('rf:shared:ObjVsNumericNonUniform'))
    end


    freq=total_sobj.Frequencies;
    z0=total_sobj.Impedance;

    if(~isequal(freq,left_sobj.Frequencies))||...
        (z0~=left_sobj.Impedance)||...
        (~isequal(freq,right_sobj.Frequencies))||...
        (z0~=right_sobj.Impedance)

        error(message('rf:shared:AllSparamObjsUseSameProps'))
    end

    dut_sdata=rf.internal.deembedsparams(total_sobj.Parameters,...
    left_sobj.Parameters,right_sobj.Parameters);
    dut_sobj=sparameters(dut_sdata,freq,z0);