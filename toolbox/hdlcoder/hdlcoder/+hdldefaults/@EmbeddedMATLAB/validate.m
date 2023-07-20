function v=validate(this,hC)



    if useML2PIR(this,hC)
        v=hdldefaults.MATLABDatapath.ml2pirValidate(this,hC);
    else
        v=baseSFValidate(this,hC);
    end

end
