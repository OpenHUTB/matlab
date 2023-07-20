function writeSelfContentsForSaveVars(obj,vs)








    vs.writeProperty('Value',obj.Value);
    if ischar(obj.Dimensions)
        vs.writeProperty('Dimensions',obj.Dimensions);
    end
    vs.writeProperty('TunableSizeName',obj.TunableSizeName);

end

