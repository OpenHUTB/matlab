function retStatus=Apply(hThis)







    retStatus=true;

    try

        retStatus=hThis.applyChildren();
    catch
        retStatus=false;
    end
end

