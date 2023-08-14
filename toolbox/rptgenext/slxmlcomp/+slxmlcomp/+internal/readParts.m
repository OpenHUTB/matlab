function parts=readParts(mdlPath)










    import com.mathworks.comparisons.opc.PartBuilder;

    corePropertyPaths={
'/metadata/coreProperties.xml'
'/metadata/mwcoreProperties.xml'
    '/metadata/mwcorePropertiesExtension.xml'};

    reader=Simulink.loadsave.SLXPackageReader(mdlPath);
    mParts=reader.getMatchingPartDefinitions('/');
    parts=java.util.ArrayList(numel(mParts)+numel(corePropertyPaths));
    partBuilder=PartBuilder();
    for i=1:numel(mParts)
        jPart=createJPart(partBuilder,mParts(i));
        parts.add(jPart);
    end

    for i=1:numel(corePropertyPaths)
        jPart=createJPartFromPath(partBuilder,corePropertyPaths{i});
        parts.add(jPart);
    end

end

function jPart=createJPart(partBuilder,mPart)

    partBuilder.setID(mPart.relationshipID);
    partBuilder.setParent(char(mPart.parentName));
    partBuilder.setPath(char(mPart.name));

    jPart=partBuilder.build();
end

function jPart=createJPartFromPath(partBuilder,path)

    partBuilder.setID(extractAfter(path,'/metadata/'));
    partBuilder.setParent('');
    partBuilder.setPath(path);

    jPart=partBuilder.build();
end