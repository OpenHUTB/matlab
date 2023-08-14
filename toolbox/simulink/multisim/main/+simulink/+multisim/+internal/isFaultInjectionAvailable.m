function isAvailable=isFaultInjectionAvailable()






    isAvailable=false;







    if slfeature('SysSafetyApp')==0
        return
    end




    if slfeature('SLMultiSimFaults')==0
        return
    end


    isAvailable=true;
end
