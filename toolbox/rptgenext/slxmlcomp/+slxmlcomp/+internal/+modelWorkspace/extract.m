function contents=extract(slxPartEntry)




    parent=getOwningSLXFile(slxPartEntry);
    partPath=getPartPath(slxPartEntry);
    contents=readPart(parent,partPath);
end

function filename=getOwningSLXFile(slxPart)
    import com.mathworks.comparisons.source.property.CSPropertyReadableLocation;

    parent=slxPart.getParentSource();
    location=CSPropertyReadableLocation.getInstance();
    filename=string(parent.getPropertyValue(location,[]));
end

function partPath=getPartPath(slxPart)
    import com.mathworks.comparisons.source.property.CSPropertyName;

    name=CSPropertyName.getInstance();
    suffix=slxPart.getPropertyValue(name,[]);
    partPath="/"+string(suffix);
end

function contents=readPart(parentSLX,partPath)
    import Simulink.loadsave.SLXPackageReader;

    reader=SLXPackageReader(parentSLX);
    contents=reader.readPartToVariable(partPath);
end
