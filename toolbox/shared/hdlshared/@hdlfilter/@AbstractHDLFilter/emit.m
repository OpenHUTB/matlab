function emit(this)







    emitValidate(this);





    emitMode=isempty(pirNetworkForFilterComp);


    if emitMode

        context=preEmit(this);
    end

    baseEmit(this);

    if emitMode

        postEmit(this,context);
    end


