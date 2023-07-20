
function success=connect(obj,FileLocation)
    if nargin>1
        FileLocation=convertStringsToChars(FileLocation);
    end

    PerfTools.Tracer.logMATLABData('MAGroup','Database Connect',true);
    if obj.keepConnectionAlive&&isa(obj.DatabaseHandle,'sdi.Repository')
        return;
    end

    obj.disconnect;
    try
        PerfTools.Tracer.logMATLABData('MAGroup','sdi.Repository constructor',true);
        schemaPath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private','repository_schema.xml');
        tsr=sdi.Repository(schemaPath,FileLocation);

        PerfTools.Tracer.logMATLABData('MAGroup','sdi.Repository constructor',false);
    catch E
        rethrow(E);
    end

    if isa(tsr,'sdi.Repository')
        success=true;
        obj.FileLocation=FileLocation;
        obj.DatabaseHandle=tsr;
    else
        success=false;
    end
    PerfTools.Tracer.logMATLABData('MAGroup','Database Connect',false);
end
