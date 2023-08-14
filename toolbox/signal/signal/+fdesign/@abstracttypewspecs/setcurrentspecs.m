function newspecs=setcurrentspecs(this,newspecs)





    checkoutfdtbxlicense(this);


    oldspecs=this.CurrentSpecs;


    rmprops(this,oldspecs);

    if isempty(newspecs)
        return;
    end

    syncspecs(this,newspecs);


    addprops(this,newspecs);



