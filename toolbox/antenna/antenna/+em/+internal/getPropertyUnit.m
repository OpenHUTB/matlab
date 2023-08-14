function unit=getPropertyUnit(propName)




    dimensionKeys={'length','width','radius','height','thickness','spacing',...
    'feedoffset','diameter','position','gap','side','radii','SlotToTop',...
    'SlotOffset','BoomOffset','PatchCenterOffset','FractalCenterOffset',...
    'CavityOffset','TaperOffset','MainReflectorOffset','MinorAxis',...
    'MajorAxis','SlotCenter','depth','location','distance','pitch',...
    'MainReflector','SubReflector','ReflectorOffset'};

    angleKeys={'elevation','tilt','angle','phase','Azimuth'};

    if contains(propName,dimensionKeys,'IgnoreCase',true)
        unit='m';
        return;
    elseif contains(propName,'tiltaxis','IgnoreCase',true)
        unit=' ';
        return;
    elseif contains(propName,angleKeys,'IgnoreCase',true)
        unit='deg';
        return
    elseif contains(propName,{'AmplitudeTaper','voltage'},'IgnoreCase',true)
        unit='V';
        return
    elseif contains(propName,{'frequency'},'IgnoreCase',true)
        unit='Hz';
        return
    elseif contains(propName,{'impedance'},'IgnoreCase',true)
        unit='ohms';
        return
    elseif contains(propName,{'conductivity'},'IgnoreCase',true)
        unit='S/m';
        return
    else
        unit=' ';
    end
end
