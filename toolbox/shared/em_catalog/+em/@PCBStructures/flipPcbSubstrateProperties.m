function flipPcbSubstrateProperties(obj,temp)%#ok<INUSL>


    if iscell(temp.Name)
        temp.Name=fliplr(temp.Name);
        temp.EpsilonR=fliplr(temp.EpsilonR);
        temp.LossTangent=fliplr(temp.LossTangent);
        temp.Thickness=fliplr(temp.Thickness);
    end
end