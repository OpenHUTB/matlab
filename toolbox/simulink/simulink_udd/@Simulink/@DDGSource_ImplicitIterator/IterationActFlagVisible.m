function visible=IterationActFlagVisible(this)




    if bitand(slsvTestingHook('ImplicitIteratorSubsystem'),2)
        visible=true;
    else
        visible=false;
    end

end
