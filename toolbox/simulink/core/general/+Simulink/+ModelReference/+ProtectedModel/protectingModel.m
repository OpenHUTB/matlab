
function out=protectingModel(topModelName)




    out=false;
    if~isempty(topModelName)&&bdIsLoaded(topModelName)
        out=~isempty(Simulink.ModelReference.ProtectedModel.getCreatorDuringProtection(topModelName));
    end
end