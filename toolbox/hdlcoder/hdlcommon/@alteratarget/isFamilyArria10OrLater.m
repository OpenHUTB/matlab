function newFamily=isFamilyArria10OrLater(family)



    oldDevices={...
    '',...
    'Stratix III',...
    'Stratix V',...
    'Stratix IV',...
    'Cyclone V',...
    'Cyclone IV GX',...
    'Cyclone IV E',...
    'Arria V GZ',...
    'Arria V',...
    'Arria II GZ',...
    'Arria II GX',...
    'Max 10',...
    };
    newFamily=~sum(strcmpi(family,oldDevices));
end