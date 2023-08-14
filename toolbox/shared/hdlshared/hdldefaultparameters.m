function hdldefaultparameters(targetlang)





    if nargin<1
        targetlang='vhdl';
    else
        targetlang=lower(targetlang);
    end

    hprop=hdlcoderprops.HDLProps;
    PersistentHDLPropSet(hprop);
    hdlsetparameter('TargetLanguage',targetlang);



