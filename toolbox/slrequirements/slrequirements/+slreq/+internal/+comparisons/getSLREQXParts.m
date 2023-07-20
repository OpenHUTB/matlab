function parts=getSLREQXParts(filePath)



    parts=[];

    try
        reader=Simulink.loadsave.SLXPackageReader(filePath);
    catch ME
        if(strcmp(ME.identifier,'Simulink:LoadSave:InvalidModelPackage'))
            msg=getString(message('Slvnv:slreq:InvalidCorruptSLREQXFile',filePath));
            msg=strrep(msg,'\','\\');
            ME=MException('Slvnv:slreq:InvalidCorruptSLREQXFile',msg);
            throw(ME);
        else
            rethrow(ME);
        end
    end
    mParts=reader.getMatchingPartDefinitions('/');

    for i=1:numel(mParts)
        mPart=mParts(i);
        if isFilteredOut(mPart.name)
            continue
        end
        jPart=createJPart(mPart);

        parts=[parts,jPart];%#ok<AGROW>
    end
end

function filter=isFilteredOut(partName)
    filter=~isempty(regexp(partName,'thumbnail','once'));
end

function jPart=createJPart(mPart)

    import com.mathworks.comparisons.opc.*;
    partBuilder=PartBuilder();
    partBuilder.setID(mPart.relationshipID);
    partBuilder.setParent(char(mPart.parentName));
    partBuilder.setPath(char(mPart.name));

    jPart=partBuilder.build();
end

