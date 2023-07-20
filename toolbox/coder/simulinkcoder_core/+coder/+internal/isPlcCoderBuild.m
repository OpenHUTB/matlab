function val=isPlcCoderBuild(lSystemTargetFile)



    [~,sysFileName]=fileparts(lSystemTargetFile);
    val=strcmp(sysFileName,'plc');
