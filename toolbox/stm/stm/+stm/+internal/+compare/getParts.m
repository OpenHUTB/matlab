function parts=getParts(filePath)



    parts=[];

    reader=Simulink.loadsave.SLXPackageReader(filePath);
    mParts=reader.getMatchingPartDefinitions('/')';

    pathToNameMap=containers.Map;

    for i=1:numel(mParts)
        mPart=mParts(i);
        if isFilteredOut(mPart)
            continue
        end
        [~,name,~]=fileparts(mPart.name);

        if strcmp(name,'TestSuiteInfo')==1
            rootTag='TestSuiteDefinition';
        else
            rootTag='TestCaseDefinition';
        end

        customizedName=stm.internal.getCustomizedXMLName(filePath,mPart.name,rootTag);

        if isempty(mPart.parentName)
            pathToNameMap(mPart.name)='';
        else
            parentName=pathToNameMap(mPart.parentName);
            pathToNameMap(mPart.name)=[parentName,filesep,customizedName];
        end
    end

    for i=1:numel(mParts)
        mPart=mParts(i);
        if isFilteredOut(mPart)
            continue
        end
        jPart=createJPart(mPart,pathToNameMap);
        parts=[parts,jPart];%#ok<AGROW>
    end
end

function filter=isFilteredOut(mPart)
    [path,name,~]=fileparts(mPart.name);
    filter=false;

    if length(split(path,filesep))>2
        if isempty(mPart.parentName)
            filter=true;
            return;
        end
    end

    nameParts=strsplit(name,'_');
    if strcmp(nameParts{1},'TableIteration')==1
        filter=true;
    end
end

function jPart=createJPart(mPart,pathToNameMap)


    import com.mathworks.comparisons.opc.PartBuilder;

    partBuilder=PartBuilder();
    partBuilder.setID(mPart.relationshipID);

    partBuilder.setParent(char(mPart.parentName));

    path=pathToNameMap(mPart.name);
    partBuilder.setName(path);
    partBuilder.setPath(char(mPart.name));
    jPart=partBuilder.build();
end
