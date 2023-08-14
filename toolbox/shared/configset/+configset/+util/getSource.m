function cs=getSource(ref,chaseConfigSet)
















    if nargin<2

        chaseConfigSet=true;
    end
    if isa(ref,'Simulink.ConfigSetRef')
        if chaseConfigSet
            cs=ref.getRefConfigSet;
        else
            cs=ref.getRefObject;
        end
        ddname=ref.getDDName;
        cs.getDialogController.DataDictionary=ddname;
    else
        cs=ref;
    end
