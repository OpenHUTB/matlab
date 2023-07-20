function out=getModelNameSuffix(obj)
    switch obj.CodeFormat
    case 'S-Function'
        out='_sf';
    case 'Accelerator_S-Function'
        out='_acc';
    otherwise
        out='';
    end
end
