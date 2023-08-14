function device=getDevice(this,PartInfo)%#ok<INUSL>



    device=eval([class(PartInfo),'(''Device'',''',PartInfo.FPGADevice,''',''Speed'',''',PartInfo.FPGASpeed,''',''Package'',''',PartInfo.FPGAPackage,''', ''Frequency'',''',PartInfo.SynthesisFrequency,''')']);
end

