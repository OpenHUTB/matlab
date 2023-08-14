function objH=resolve(modelH,id)




    if isempty(id)

        objH=get_param(modelH,'Name');

    elseif id(1)==':'

        try
            modelName=get_param(modelH,'Name');
            objH=Simulink.ID.getHandle([modelName,id]);
        catch
            objH=[];
        end
    else



        objH=rmisl.guidlookup(modelH,id);
    end

end
