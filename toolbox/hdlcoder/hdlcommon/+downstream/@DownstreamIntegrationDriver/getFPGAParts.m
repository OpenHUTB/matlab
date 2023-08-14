function[FPGAFamily,FPGADevice,FPGAPackage,FPGASpeed]=getFPGAParts(obj)

    FPGAFamily=obj.get('Family');
    FPGADevice=obj.get('Device');
    FPGAPackage=obj.get('Package');
    FPGASpeed=obj.get('Speed');

end