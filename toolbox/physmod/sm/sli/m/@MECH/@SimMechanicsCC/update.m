function update(this,event)










    if nargin>1
        event=convertStringsToChars(event);
    end

    pmsl_superclassmethod(this,'MECH.SimMechanicsCC','update',event);




