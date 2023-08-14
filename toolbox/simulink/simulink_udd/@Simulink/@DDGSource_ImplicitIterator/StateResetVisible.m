function visible=StateResetVisible(this)




    if bitand(slsvTestingHook('ImplicitIteratorSubsystem'),4)
        visible=true;
    else
        visible=false;
    end

end
