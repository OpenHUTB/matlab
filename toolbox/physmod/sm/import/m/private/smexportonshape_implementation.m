













function xmlFileName=smexportonshape_implementation(url,varargin)

    if~pmsl_checklicense('simmechanics')
        pm_error('sm:smexportonshape:LicenseNotFound')
    end

    inputs=parseInputs(varargin);
    dir=inputs.FolderPath;
    ids=parseUrl(url);


    if~isempty(inputs.RefreshToken)
        persistentRefreshToken(inputs.RefreshToken);
    end

    accessToken='';

    [smiModel,accessToken]=createOnshapeSmiModel(ids,accessToken);

    hWaitbar=waitbar(0,'Processing assembly definition...',...
    'Name','Exporting Onshape Assembly...');

    finishup=onCleanup(@()closeWaitbar(hWaitbar));

    [rAssemDef,accessToken]=restAssemblyDefinition(ids,accessToken);
    rAssemDef=organizeAssemblyDefinition(rAssemDef);

    smiModel.Instance=convertInstances(rAssemDef);
    smiModel.Joint=convertJoints(rAssemDef.rootAssembly.features);
    smiModel.Constraint=convertParallelConstraints(rAssemDef.rootAssembly.features);
    [smiModel.Assembly,fixedInstances,accessToken]=...
    convertSubAssemblies(rAssemDef.subAssemblies,ids,accessToken);
    smiModel.Instance=correctGroundedInfo(smiModel.Instance,fixedInstances);




    [smiModel.Part,~]=...
    convertParts(rAssemDef.parts,ids,dir,accessToken,hWaitbar);

    if isvalid(hWaitbar)
        waitbar(0.95,hWaitbar,'Generating XML Multibody Description file...');
    end

    xmlFileName=fullfile(dir,...
    matlab.lang.makeValidName(smiModel.RootAssembly.Name));

    [xmlFullName,xmlFileName]=uniqueFileName(xmlFileName,'.xml');

    xmlConvertSmiData(smiModel,xmlFullName);

    xmlFileName=[xmlFileName,'.xml'];

end
















function contraints=convertParallelConstraints(rFeatures)

    matesIndices=find(arrayfun(@(x)strcmpi(x.featureType,'mateConstraint')&&...
    ~x.suppressed&&numel(x.featureData.matedEntities)==2,rFeatures));

    contraints=struct;

    for i=numel(matesIndices):-1:1

        featureData=rFeatures(matesIndices(i)).featureData;

        contraints(i).Name=featureData.name;
        contraints(i).Type='Parallel';

        contraints(i).Geometry(1).Position=...
        sprintf('%.9f ',featureData.matedEntities(1).matedCS.origin);
        contraints(i).Geometry(1).Axis=...
        sprintf('%.9f ',featureData.matedEntities(1).matedCS.zAxis);
        contraints(i).Geometry(1).Type='plane';
        contraints(i).Geometry(1).Uid=cell2struct(...
        featureData.matedEntities(1).matedOccurrence,'Name',2)';

        contraints(i).Geometry(2).Position=...
        sprintf('%.9f ',featureData.matedEntities(2).matedCS.origin);
        contraints(i).Geometry(2).Axis=...
        sprintf('%.9f ',featureData.matedEntities(2).matedCS.zAxis);
        contraints(i).Geometry(2).Type='plane';
        contraints(i).Geometry(2).Uid=cell2struct(...
        featureData.matedEntities(2).matedOccurrence,'Name',2)';

    end

end












function joints=convertJoints(rFeatures)

    matesIndices=find(arrayfun(@(x)strcmpi(x.featureType,'mate')&&...
    ~x.suppressed&&numel(x.featureData.matedEntities)==2,rFeatures));

    joints=struct;

    for i=numel(matesIndices):-1:1

        featureData=rFeatures(matesIndices(i)).featureData;

        jointNameMap=persistentGetJointNameMap();

        if jointNameMap.isKey(lower(featureData.mateType))
            mateType=jointNameMap(lower(featureData.mateType));
        else
            pm_warning('sm:smexportonshape:UnsupportedFeature',featureData.name)
            mateType='Weld';
        end

        axesToMatrix=@(x)[x.xAxis,x.yAxis,x.zAxis]';

        joints(i).Name=featureData.name;
        joints(i).Type=mateType;

        joints(i).FollowerFrame.Transform.Translation=...
        sprintf('%.9f ',featureData.matedEntities(1).matedCS.origin);
        joints(i).FollowerFrame.Transform.Rotation=...
        sprintf('%.9f ',axesToMatrix(featureData.matedEntities(1).matedCS));

        if isempty(featureData.matedEntities(1).matedOccurrence)
            joints(i).FollowerFrame.Uid=[];
        else
            joints(i).FollowerFrame.Uid=...
            cell2struct(featureData.matedEntities(1).matedOccurrence,'Name',2)';
        end

        joints(i).BaseFrame.Transform.Translation=...
        sprintf('%.9f ',featureData.matedEntities(2).matedCS.origin);
        joints(i).BaseFrame.Transform.Rotation=...
        sprintf('%.9f ',axesToMatrix(featureData.matedEntities(2).matedCS));

        if isempty(featureData.matedEntities(2).matedOccurrence)
            joints(i).BaseFrame.Uid=[];
        else
            joints(i).BaseFrame.Uid=...
            cell2struct(featureData.matedEntities(2).matedOccurrence,'Name',2)';
        end

    end

end


















function[assemblies,fixedUids,accessToken]=...
    convertSubAssemblies(rSubAssems,rootAssemIds,accessToken)

    assemblies=struct;

    fixedUids=cell('');
    for i=numel(rSubAssems):-1:1

        if rSubAssems{i}.suppressed
            continue;
        end

        ids.did=rSubAssems{i}.documentId;
        ids.eid=rSubAssems{i}.elementId;
        ids.linkDid=rootAssemIds.did;
        if strcmp(rootAssemIds.did,ids.did)
            ids.wvm=rootAssemIds.wvm;
            ids.wvmid=rootAssemIds.wvmid;
        else
            ids.wvm='v';
            ids.wvmid=rSubAssems{i}.documentVersion;
        end

        [rElementList,accessToken]=restElementList(ids,accessToken);
        [subAssemDef,accessToken]=restAssemblyDefinition(ids,accessToken);

        if isfield(subAssemDef.rootAssembly,'occurrences')

            fixedIndices=[subAssemDef.rootAssembly.occurrences.fixed];
            newFixed=cellfun(@(x)x(end),...
            {subAssemDef.rootAssembly.occurrences(fixedIndices).path});
            fixedUids=[fixedUids,newFixed];%#ok          
        end

        assemblies(i).Uid=rSubAssems{i}.elementId;
        assemblies(i).Name=rElementList.name;

        assemblies(i).ModelUnits.Mass=rElementList.massUnits;
        assemblies(i).ModelUnits.Length=rElementList.lengthUnits;

        assemblies(i).Joint=convertJoints(rSubAssems{i}.features);
        assemblies(i).Constraint=convertParallelConstraints(rSubAssems{i}.features);
    end

    indices=arrayfun(@(x)isfield(x,'Uid')&&~isempty(x.Uid),assemblies);
    if any(indices)
        assemblies=assemblies(indices);
    end

end






function instances=convertInstances(rAssemDef)

    root.Instance=[];
    for i=1:numel(rAssemDef.rootAssembly.occurrences)

        occurrence=rAssemDef.rootAssembly.occurrences(i);

        if occurrence.suppressed
            continue;
        end

        instance=struct;

        instance.Name=occurrence.name;

        if isempty(occurrence.pid)
            instance.EntityUid=occurrence.eid;
        else
            instance.EntityUid=[occurrence.pid,'*:*',occurrence.eid];
        end

        instance.Uid=occurrence.path{end};

        instance.Transform=occurrence.transform;

        if occurrence.fixed
            instance.Grounded='True';
        else
            instance.Grounded='False';
        end

        instance.Group='';
        instance.Instance=[];

        root=addInstanceToTree(occurrence.path,root,instance);
    end

    instances=root.Instance;
    if~isempty(instances)

        instances=correctTransform(instances,[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]);

        elementGroupsMap=gatherGroupInfo(rAssemDef);
        if~isempty(elementGroupsMap)
            instances=assignGroups(instances,...
            rAssemDef.rootAssembly.elementId,'root',elementGroupsMap);
        end
    end
end



















function[parts,accessToken]=...
    convertParts(rParts,rootAssemIds,dir,accessToken,hWaitbar)
    [partstudios,partsNum]=organizeParts(rParts,rootAssemIds);

    if partsNum==0
        parts=[];
        return;
    end
    parts(partsNum)=struct;

    ids.linkDid=rootAssemIds.did;


    p_i=1;

    partstudiosNum=numel(partstudios);
    for i=1:numel(partstudios)

        if isvalid(hWaitbar)
            waitbar(0.1+0.85*p_i/partsNum,hWaitbar,...
            sprintf('Processing part studio %d of %d...',i,partstudiosNum));
        end

        ids.eid=partstudios(i).eid;
        ids.did=partstudios(i).did;
        ids.wvmid=partstudios(i).wvmid;
        ids.wvm=partstudios(i).wvm;

        transIdMap=containers.Map;

        partIds=partstudios(i).partIds;
        for j=1:numel(partIds)

            ids.pid=partIds{j};
            [rPartTranslation,accessToken]=restPartTranslation(ids,accessToken);
            transIdMap(ids.pid)=rPartTranslation.id;

        end

        pidMap=buildPidMap(partIds);

        [rElementList,accessToken]=restElementList(ids,accessToken);
        [rMetas,accessToken]=restPartStudioMeta(ids,partIds,accessToken);
        [rawMassProps,accessToken]=restPartStudioMass(ids,partIds,accessToken);

        keys=pidMap.keys;

        for j=1:numel(keys)
            originalPartId=keys{j};
            rawMassProps=replace(rawMassProps,['"',originalPartId,'"'],...
            ['"',pidMap(originalPartId),'"']);
        end

        rMass=jsondecode(rawMassProps);

        if isstruct(rMetas)
            rMetas=num2cell(rMetas);
        end

        metaNum=numel(rMetas);
        for j=1:metaNum

            if isvalid(hWaitbar)
                waitbar(0.1+0.85*p_i/partsNum,hWaitbar,sprintf(...
                'Processing part studio %d of %d...\nPart %d of %d...',...
                i,partstudiosNum,j,metaNum));
            end

            rMeta=rMetas{j};

            partName=rMeta.name;
            visual=rMeta.appearance;
            rgba=sprintf('%.9f ',[visual.color.red,visual.color.green...
            ,visual.color.blue,visual.opacity]/255);
            parts(p_i).Name=partName;
            tempGeomName=partName;

            parts(p_i).VisualProperties.Ambient=rgba;
            parts(p_i).VisualProperties.Diffuse=rgba;
            parts(p_i).VisualProperties.Specular=rgba;
            parts(p_i).VisualProperties.Emissive='0 0 0 1';
            parts(p_i).VisualProperties.Shininess='0.5';
            parts(p_i).Uid=[rMeta.partId,'*:*',ids.eid];

            parts(p_i).ModelUnits.Mass=rElementList.massUnits;
            parts(p_i).ModelUnits.Length=rElementList.lengthUnits;


            if isvarname(rMeta.partId)
                massBodyName=rMeta.partId;
            else
                massBodyName=pidMap(rMeta.partId);
            end

            if rMass.bodies.(massBodyName).massMissingCount~=0
                pm_warning('sm:smexportonshape:MissingMassProperty',partName);
                pause(0.01);
            end

            parts(p_i).MassProperties.Mass=...
            num2str(rMass.bodies.(massBodyName).mass(1),9);
            parts(p_i).MassProperties.CenterOfMass=...
            sprintf('%.9f ',rMass.bodies.(massBodyName).centroid(1:3));

            im=rMass.bodies.(massBodyName).inertia(1:9);
            parts(p_i).MassProperties.Inertia=...
            sprintf('%.9f ',[im(1),im(5),im(9),im(6),im(3),im(2)]);
            parts(p_i).GeometryFile.Type='STEP';

            flag=false;


            for timeout=1:600
                [rTranslationStatus,accessToken]=...
                restTranslationStatus(transIdMap(rMeta.partId),accessToken);

                if strcmpi(rTranslationStatus.requestState,'ACTIVE')
                    pause(1);
                    if isvalid(hWaitbar)
                        waitbar(0.1+0.85*p_i/partsNum,hWaitbar,sprintf(...
                        'Waiting for part translation of %s',...
                        rTranslationStatus.name));
                    end
                elseif strcmpi(rTranslationStatus.requestState,'DONE')






                    if strcmp(ids.wvm,'v')
                        did=ids.linkDid;
                    else
                        did=ids.did;
                    end

                    [bytestream,accessToken]=restDownloadData(did,...
                    rTranslationStatus.resultExternalDataIds{1},...
                    accessToken);

                    [partFullName,tempGeomName]=...
                    uniqueFileName(fullfile(dir,tempGeomName),'.step');

                    fid=fopen(partFullName,'w');

                    if fid==-1
                        [partFullName,tempGeomName]=uniqueFileName(fullfile(...
                        dir,matlab.lang.makeValidName(tempGeomName)),'.step');
                        fid=fopen(partFullName,'w');
                    end

                    parts(p_i).GeometryFile.Name=[tempGeomName,'.step'];

                    fwrite(fid,bytestream);
                    fclose(fid);
                    flag=true;
                    break;
                end
            end

            if~flag
                pm_warning('sm:smexportonshape:PartDownloadFailed',...
                parts(p_i).GeometryFile.Name);
            end

            p_i=p_i+1;
        end
    end

end














function[smiModel,accessToken]=createOnshapeSmiModel(ids,accessToken)

    [rRootAssemblyElementList,accessToken]=restElementList(ids,accessToken);

    if~strcmpi(rRootAssemblyElementList.elementType,'ASSEMBLY')
        pm_error('sm:smexportonshape:InvalidElementType')
    end

    smiModel=struct;

    smiModel.ModelUnits.Mass=rRootAssemblyElementList.massUnits;
    smiModel.ModelUnits.Length=rRootAssemblyElementList.lengthUnits;


    smiModel.DataUnits.Mass='kilogram';
    smiModel.DataUnits.Length='meter';
    smiModel.RootAssembly.Name=rRootAssemblyElementList.name;
    smiModel.RootAssembly.Uid=ids.eid;
    smiModel.RootAssembly.Version=[ids.wvm,'-',ids.wvmid];

    [rSessionInfo,accessToken]=restSessionInfo(accessToken);
    if isfield(rSessionInfo,'name')
        smiModel.CreatedInfo.By=rSessionInfo.name;
    else
        smiModel.CreatedInfo.By='';
    end

    smiModel.CreatedInfo.From='Onshape';
    smiModel.CreatedInfo.Using='Simscape Multibody Exporter';

end








function closeWaitbar(hWaitbar)
    if isvalid(hWaitbar)
        close(hWaitbar);
    end
end











function[newFullName,newName]=uniqueFileName(origFileName,ext)

    [pathstr,name,~]=fileparts([origFileName,ext]);

    newName=name;
    modifier=1;

    while exist(fullfile(pathstr,[newName,ext]),'file')~=0
        newName=[name,num2str(modifier)];
        modifier=modifier+1;
    end

    newFullName=fullfile(pathstr,[newName,ext]);

end












function pidMap=buildPidMap(partIds)

    pidMap=containers.Map;

    for i=1:numel(partIds)

        partId=partIds{i};

        if isempty(partId)
            continue;
        end

        if isvarname(partId)
            continue;
        end

        validId=partId;

        validId=strrep(validId,'/','s_');
        validId=strrep(validId,'+','p_');

        if~isletter(validId(1))
            validId=['x_',validId];%#ok
        end

        pidMap(partId)=validId;

    end

end









function[partstudios,partsNum]=organizeParts(rParts,rootAssemIds)

    if~isempty(rParts)
        rParts=rParts(cellfun(@(x)~x.suppressed&&~isempty(x.partId),rParts));
    end
    partsNum=numel(rParts);

    if partsNum==0
        partstudios=[];
        return;
    end

    uniqueEids=unique(cellfun(@(x){x.elementId},rParts));

    for i=numel(uniqueEids):-1:1

        indices=cellfun(@(x)strcmp(x.elementId,uniqueEids{i}),rParts);
        partIds={cellfun(@(x){x.partId},rParts(indices))};

        firstIndex=find(indices,1);

        did=rParts{firstIndex}.documentId;
        if strcmp(rootAssemIds.did,did)
            wvm=rootAssemIds.wvm;
            wvmid=rootAssemIds.wvmid;
        else
            wvm='v';
            wvmid=rParts{firstIndex}.documentVersion;
        end

        partstudios(i)=struct('eid',uniqueEids{i},'did',did,'wvmid',wvmid,...
        'wvm',wvm,'partIds',partIds);
    end

end











function elementGroupsMap=gatherGroupInfo(rAssemDef)

    elementGroupsMap=containers.Map;

    rootFeatures=rAssemDef.rootAssembly.features;
    rootIndices=find(arrayfun(@(x)strcmpi(x.featureType,'mateGroup')&&...
    ~x.suppressed,rootFeatures));

    rootGroupMap=containers.Map;
    for i=1:numel(rootIndices)
        instanceOcc=rootFeatures(rootIndices(i)).featureData.occurrences;
        rootGroupMap(rootFeatures(rootIndices(i)).id)=instanceOcc;
    end
    if~isempty(rootGroupMap)
        elementGroupsMap(rAssemDef.rootAssembly.elementId)=rootGroupMap;
    end

    for i=1:numel(rAssemDef.subAssemblies)
        subAssemFeatures=rAssemDef.subAssemblies{i}.features;
        subAssemIndices=find(arrayfun(@(x)strcmpi(x.featureType,'mateGroup')...
        &&~x.suppressed,subAssemFeatures));

        subGroupMap=containers.Map;
        for j=1:numel(subAssemIndices)
            instanceOcc=...
            subAssemFeatures(subAssemIndices(j)).featureData.occurrences;
            subGroupMap(subAssemFeatures(j).id)=instanceOcc;
        end
        if~isempty(subGroupMap)
            elementGroupsMap(rAssemDef.subAssemblies{i}.elementId)=subGroupMap;
        end
    end

end






function inputs=parseInputs(nameValuePairs)

    persistent p;

    if isempty(p)
        p=inputParser;
        addParameter(p,'FolderPath','');
        addParameter(p,'RefreshToken','');
    end

    parse(p,nameValuePairs{:});

    if ismember('FolderPath',p.UsingDefaults)

        inputs.FolderPath='';

    else

        if isstring(p.Results.FolderPath)
            inputs.FolderPath=char(p.Results.FolderPath);
        else
            inputs.FolderPath=p.Results.FolderPath;
        end

        if isempty(dir(inputs.FolderPath))
            pm_error('sm:smexportonshape:FolderNotExist')
        end

    end

    if ismember('RefreshToken',p.UsingDefaults)

        inputs.RefreshToken='';

    else

        inputs.RefreshToken=p.Results.RefreshToken;

    end

end





function rAssemDef=organizeAssemblyDefinition(rAssemDef)

    if~isfield(rAssemDef.rootAssembly,'occurrences')||...
        isempty(rAssemDef.rootAssembly.occurrences)
        pm_error('sm:smexportonshape:EmptyAssembly');
    end


    [~,sortIndex]=sort(arrayfun(@(x)size(x.path,1),...
    rAssemDef.rootAssembly.occurrences));
    rAssemDef.rootAssembly.occurrences=...
    rAssemDef.rootAssembly.occurrences(sortIndex);



    cstsIndices=arrayfun(@(x)strcmpi(x.featureType,'mate')&&strcmpi(...
    x.featureData.mateType,'parallel'),rAssemDef.rootAssembly.features);
    [rAssemDef.rootAssembly.features(cstsIndices).featureType]=...
    deal('mateConstraint');

    if isstruct(rAssemDef.rootAssembly.instances)
        rAssemDef.rootAssembly.instances=num2cell(rAssemDef.rootAssembly.instances);
    end

    if~isempty(rAssemDef.parts)

        if isstruct(rAssemDef.parts)
            rAssemDef.parts=num2cell(rAssemDef.parts);
        end

        rAssemDef.parts=...
        rAssemDef.parts(cellfun(@(x)~isempty(x.partId),rAssemDef.parts));

        rAssemDef.parts=cellfun(@(x)setfield(x,'suppressed',false),...
        rAssemDef.parts,'UniformOutput',false);%#ok
    end

    if~isempty(rAssemDef.subAssemblies)

        if isstruct(rAssemDef.subAssemblies)
            rAssemDef.subAssemblies=num2cell(rAssemDef.subAssemblies);
        end

        rAssemDef.subAssemblies=cellfun(@(x)setfield(x,'suppressed',false),...
        rAssemDef.subAssemblies,'UniformOutput',false);%#ok
    end

    for i=1:numel(rAssemDef.subAssemblies)
        cstsIndices=arrayfun(@(x)strcmpi(x.featureType,'mate')&&strcmpi(...
        x.featureData.mateType,'parallel'),rAssemDef.subAssemblies{i}.features);
        [rAssemDef.subAssemblies{i}.features(cstsIndices).featureType]=...
        deal('mateConstraint');


        if isstruct(rAssemDef.subAssemblies{i}.instances)
            rAssemDef.subAssemblies{i}.instances=...
            num2cell(rAssemDef.subAssemblies{i}.instances);
        end
    end

    [rAssemDef.rootAssembly.occurrences.suppressed]=deal(false);
    [rAssemDef.rootAssembly.occurrences.name]=deal('');
    [rAssemDef.rootAssembly.occurrences.eid]=deal('');
    [rAssemDef.rootAssembly.occurrences.pid]=deal('');

    suppressedPartTester=containers.Map;
    suppressedAssemblyTester=containers.Map;
    for i=1:numel(rAssemDef.rootAssembly.occurrences)

        rPath=rAssemDef.rootAssembly.occurrences(i).path;

        [name,eid,isPart,pid,suppressed,hasError]=...
        getInstanceInfo(rPath,rAssemDef);
        rAssemDef.rootAssembly.occurrences(i).suppressed=...
        suppressed||rAssemDef.rootAssembly.occurrences(i).suppressed;


        if~rAssemDef.rootAssembly.occurrences(i).suppressed&&hasError
            pm_error('sm:smexportonshape:InstanceHasError',name);
        end

        rAssemDef.rootAssembly.occurrences(i).name=name;
        rAssemDef.rootAssembly.occurrences(i).eid=eid;
        rAssemDef.rootAssembly.occurrences(i).pid=pid;






        if rAssemDef.rootAssembly.occurrences(i).suppressed&&~hasError

            if isPart
                suppressedPartTester([pid,'*:*',eid])='';
            else
                suppressedAssemblyTester(eid)='';
                indices=arrayfun(@(x)ismember(rPath(end),x.path),...
                rAssemDef.rootAssembly.occurrences);

                [rAssemDef.rootAssembly.occurrences(indices).suppressed]=...
                deal(true);
            end
        end
    end

    if~isempty(suppressedPartTester)||~isempty(suppressedAssemblyTester)
        for i=1:numel(rAssemDef.rootAssembly.occurrences)

            if~rAssemDef.rootAssembly.occurrences(i).suppressed

                if~isempty(rAssemDef.rootAssembly.occurrences(i).pid)
                    partKey=[rAssemDef.rootAssembly.occurrences(i).pid...
                    ,'*:*',rAssemDef.rootAssembly.occurrences(i).eid];
                    if suppressedPartTester.isKey(partKey)
                        suppressedPartTester.remove(partKey);
                    end
                else
                    assemblyKey=rAssemDef.rootAssembly.occurrences(i).eid;
                    if suppressedAssemblyTester.isKey(assemblyKey)
                        suppressedAssemblyTester.remove(assemblyKey);
                    end
                end
            end
        end
    end


    partKeys=suppressedPartTester.keys;
    for i=1:numel(partKeys)
        id=split(partKeys{i},'*:*');
        pid=id{1};
        eid=id{2};
        index=cellfun(@(x)strcmp(x.elementId,eid)&&strcmp(x.partId,pid),...
        rAssemDef.parts);
        rAssemDef.parts{index}.suppressed=true;
    end


    assemblyKeys=suppressedAssemblyTester.keys;
    for i=1:numel(assemblyKeys)
        eid=assemblyKeys{i};
        index=cellfun(@(x)strcmp(x.elementId,eid),rAssemDef.subAssemblies);
        rAssemDef.subAssemblies{index}.suppressed=true;
    end

end














function instances=assignGroups(instances,eid,uid,elementGroupMap)

    if elementGroupMap.isKey(eid)

        groupMap=elementGroupMap(eid);
        groupIds=groupMap.keys;

        elementUids={instances.Uid};
        for i=1:groupMap.Count
            occs=groupMap(groupIds{i});
            occUids=[occs.occurrence];
            [~,loc]=ismember(occUids,elementUids);
            loc=loc(loc~=0);
            preGroupIds={instances(loc).Group};
            existingIds=unique(preGroupIds(~cellfun('isempty',preGroupIds)));

            groupId=[uid,'.',groupIds{i}];
            if~isempty(existingIds)
                groupId=[strjoin(existingIds,'..'),'..',groupId];%#ok

                eLoc=find(arrayfun(@(x)...
                ismember(x.Group,existingIds),instances));

                loc=union(loc,eLoc);
            end

            [instances(loc).Group]=deal(groupId);
        end

    end

    for i=1:numel(instances)

        if~isempty(instances(i).Instance)


            instances(i).Instance=assignGroups(instances(i).Instance,...
            instances(i).EntityUid,[uid,'-',instances(i).Uid],elementGroupMap);

        end

    end

end








function instances=correctTransform(instances,transform)

    for i=1:numel(instances)


        if~isempty(instances(i).Instance)
            newTransform=...
            reshape(transform,[4,4])'*reshape(instances(i).Transform,[4,4])';

            instances(i).Instance=correctTransform(instances(i).Instance,...
            reshape(newTransform',[1,16]));
        else
            correctedTransform=...
            reshape(transform,[4,4])'\reshape(instances(i).Transform,[4,4])';
            instances(i).Transform=reshape(correctedTransform',[1,16]);
        end

    end

end
















function[name,eid,isPart,pid,suppressed,hasError]=...
    getInstanceInfo(rPath,rAssemDef)
    hasError=false;
    isPart=false;
    pid='';

    pathSize=numel(rPath);

    if pathSize>1
        [name,eid,isPart,pid,suppressed,hasError]=...
        searchPathInSubAssems(rPath{end},rAssemDef.subAssemblies);

        if~isempty(name)&&~isempty(eid)
            return;
        end
    end


    rAssemInstances=rAssemDef.rootAssembly.instances;

    pathIndex=cellfun(@(x)strcmp(x.id,rPath{end}),rAssemInstances);

    suppressed=rAssemInstances{pathIndex}.suppressed;

    name=rAssemInstances{pathIndex}.name;

    eid=rAssemInstances{pathIndex}.elementId;
    if strcmpi(rAssemInstances{pathIndex}.type,'Part')
        isPart=true;
        pid=rAssemInstances{pathIndex}.partId;
        if isempty(pid)
            hasError=true;
        end
    else
        if isfield(rAssemInstances{pathIndex},'status')&&...
            strcmp(rAssemInstances{pathIndex}.status,'DeletedElement')
            hasError=true;
        end
    end

end















function[name,eid,isPart,pid,suppressed,hasError]=...
    searchPathInSubAssems(rPath,rSubAssemblies)

    name='';
    eid='';
    pid='';
    isPart=false;
    suppressed=false;
    hasError=false;

    for i=1:numel(rSubAssemblies)
        for j=1:numel(rSubAssemblies{i}.instances)

            if strcmp(rPath,rSubAssemblies{i}.instances{j}.id)

                suppressed=rSubAssemblies{i}.instances{j}.suppressed;

                name=rSubAssemblies{i}.instances{j}.name;
                eid=rSubAssemblies{i}.instances{j}.elementId;
                if strcmpi(rSubAssemblies{i}.instances{j}.type,'Part')
                    isPart=true;
                    pid=rSubAssemblies{i}.instances{j}.partId;
                    if isempty(pid)
                        hasError=true;
                    end
                else
                    if isfield(rSubAssemblies{i}.instances{j},'status')&&...
                        strcmp(rSubAssemblies{i}.instances{j}.status,'DeletedElement')
                        hasError=true;
                    end
                end
                return;
            end
        end
    end
end








function root=addInstanceToTree(rPath,root,instance)

    pathSize=numel(rPath);

    if pathSize>1

        pathIndex=arrayfun(@(x)strcmp(x.Uid,rPath{1}),root.Instance);

        if any(pathIndex)
            tempRoot=addInstanceToTree(...
            rPath(2:pathSize),root.Instance(pathIndex),instance);
            root.Instance(pathIndex).Instance=tempRoot.Instance;
            return;
        end
    end

    if isempty(root.Instance)
        root.Instance=instance;
    else
        root.Instance(end+1)=instance;
    end

end










function instances=correctGroundedInfo(instances,fixedUids)

    if isempty(fixedUids)
        return;
    end

    for i=1:numel(instances)

        if any(strcmp(fixedUids,instances(i).Uid))
            instances(i).Grounded='True';
        end


        if~isempty(instances(i).Instance)
            instances(i).Instance=correctGroundedInfo(...
            instances(i).Instance,fixedUids);
        end

    end

end








function ids=parseUrl(userUrl)

    exp='^.*documents/(.*)/([wv])/(.*)/e/(.*)$';
    [token,~]=regexp(userUrl,exp,'tokens','once','match');

    if isempty(token)
        pm_error('sm:smexportonshape:InvalidUrl')
    end

    ids.did=token{1};
    ids.eid=token{4};

    ids.wvm=token{2};
    ids.wvmid=token{3};

    ids.linkDid=ids.did;

end











function refreshToken=persistentRefreshToken(newRefreshToken)

    persistent p_onshape_oauth2_refresh_token;
    mlock;


    if nargin==0

        if isempty(p_onshape_oauth2_refresh_token)
            refreshToken='';
        else
            refreshToken=p_onshape_oauth2_refresh_token;
        end


    elseif nargin==1

        p_onshape_oauth2_refresh_token=newRefreshToken;

    end

end







function baseUrl=persistentGetBaseUrl()

    persistent BASE_URL;

    if isempty(BASE_URL)


        BASE_URL='https://cad.onshape.com';
    end

    baseUrl=BASE_URL;

end







function jointNameMap=persistentGetJointNameMap()

    persistent JOINT_NAME_MAP;

    if isempty(JOINT_NAME_MAP)

        jointsKeys={'revolute','fastened','ball','cylindrical',...
        'slider','planar','pin_slot'};
        jointsValues={'Revolute','Weld','Spherical','Cylindrical',...
        'Prismatic','Planar','PinSlot'};
        JOINT_NAME_MAP=containers.Map(jointsKeys,jointsValues);

    end

    jointNameMap=JOINT_NAME_MAP;

end


















function[response,accessToken]=restDownloadData(did,dataId,accessToken)

    uDownloadExtData='/api/documents/d/%s/externaldata/%s';
    [response,accessToken]=restGet([persistentGetBaseUrl(),sprintf(...
    uDownloadExtData,did,dataId)],accessToken);

end














function[response,accessToken]=restAssemblyDefinition(ids,accessToken)

    uAssembly='/api/assemblies/d/%s/%s/%s/e/%s?includeMateFeatures=true&linkDocumentId=%s';
    [response,accessToken]=restGet([persistentGetBaseUrl(),sprintf(...
    uAssembly,ids.did,ids.wvm,ids.wvmid,ids.eid,ids.linkDid)],accessToken);

end
















function[response,accessToken]=restPartTranslation(ids,accessToken)

    data=struct('formatName','STEP','partIds',ids.pid,...
    'storeInDocument',false,'linkDocumentId',ids.linkDid);
    uPartTranslation='/api/partstudios/d/%s/%s/%s/e/%s/translations';
    [response,accessToken]=restPost([persistentGetBaseUrl(),sprintf(...
    uPartTranslation,ids.did,ids.wvm,ids.wvmid,ids.eid)],accessToken,data);

end















function[response,accessToken]=restPartStudioMeta(ids,partIds,accessToken)

    uPartStudioMeta=...
    '/api/partstudios/d/%s/%s/%s/e/%s/metadata?linkDocumentId=%s&%s';
    urlencodedPartIds=cellfun(@(x){urlencode(x)},partIds);
    queryPartIds=strjoin(strcat('partIds=',urlencodedPartIds),'&');

    [response,accessToken]=restGet([persistentGetBaseUrl(),...
    sprintf(uPartStudioMeta,ids.did,ids.wvm,ids.wvmid,ids.eid,...
    ids.linkDid,queryPartIds)],accessToken);

end

















function[response,accessToken]=restPartStudioMass(ids,partIds,accessToken)

    uPartStudioMass=...
    '/api/partstudios/d/%s/%s/%s/e/%s/massproperties?massAsGroup=false&linkDocumentId=%s&%s';
    urlencodedPartIds=cellfun(@(x){urlencode(x)},partIds);
    queryPartIds=strjoin(strcat('partId=',urlencodedPartIds),'&');

    [response,accessToken]=restRawGet([persistentGetBaseUrl(),...
    sprintf(uPartStudioMass,ids.did,ids.wvm,ids.wvmid,ids.eid,...
    ids.linkDid,queryPartIds)],accessToken);

end














function[response,accessToken]=restElementList(ids,accessToken)

    uElementList='/api/documents/d/%s/%s/%s/elements?elementId=%s';
    [response,accessToken]=restGet([persistentGetBaseUrl(),sprintf(...
    uElementList,ids.did,ids.wvm,ids.wvmid,ids.eid)],accessToken);

end














function[response,accessToken]=restTranslationStatus(id,accessToken)

    uTranlationStatus='/api/translations/%s';
    [response,accessToken]=restGet([persistentGetBaseUrl(),sprintf(...
    uTranlationStatus,id)],accessToken);

end













function[response,accessToken]=restSessionInfo(accessToken)

    uSessionInfo='/api/users/sessioninfo';
    [response,accessToken]=restGet([persistentGetBaseUrl(),uSessionInfo],...
    accessToken);
end














function[response,accessToken]=restGet(url,accessToken)

    [response,accessToken]=callRestAPI(url,accessToken,false,[]);

end

















function[response,accessToken]=restRawGet(url,accessToken)

    [response,accessToken]=callRestAPI(url,accessToken,true,[]);

end















function[response,accessToken]=restPost(url,accessToken,requestData)

    [response,accessToken]=callRestAPI(url,accessToken,false,requestData);

end



















function[response,accessToken]=callRestAPI(url,accessToken,raw,requestData)

    try

        if isempty(accessToken)
            accessToken=refreshAccessToken();
        end

        options=weboptions('Timeout',Inf,'MediaType','application/json',...
        'KeyName','Authorization','KeyValue',['Bearer ',accessToken]);

        if raw
            options.ContentType='text';
        end
        if isempty(requestData)
            response=webread(url,options);
        else
            response=webwrite(url,options,requestData);
        end

    catch

        try

            newAccessToken=refreshAccessToken();



            if strcmp(newAccessToken,accessToken)
                assert(false);
            else
                accessToken=newAccessToken;
            end

        catch

            try

                [accessToken,refreshToken]=onshapeAuthorize();
                persistentRefreshToken(refreshToken);
            catch ex
                throw(ex);
            end
        end


        try
            options=weboptions('Timeout',Inf,'MediaType','application/json',...
            'KeyName','Authorization','KeyValue',['Bearer ',accessToken]);
            if raw
                options.ContentType='text';
            end
            if isempty(requestData)
                response=webread(url,options);
            else
                response=webwrite(url,options,requestData);
            end

        catch ex
            throw(ex);
        end

    end

end







function[accessToken,refreshToken]=onshapeAuthorize()







    clientid='WDQVG4FR4C3POP7HKZGTEIAWPF4VDGEB4ATH6HI=';
    requestURL=...
    ['https://oauth.onshape.com/oauth/authorize?response_type=code&client_id='...
    ,urlencode(clientid),'&redirect_uri=urn:ietf:wg:oauth:2.0:oob'];

    try
        webread(requestURL);
    catch
        pm_error('sm:smexportonshape:ConnectionFail');
    end


    webddg=DAStudio.WebDDG;
    webddg.WebKit=false;
    webddg.Geometry=[100,100,800,800];
    webddg.Url=requestURL;

    dlg=webddg.createStandaloneDDG;
    dlg.showMaximized;

    while true






        if strcmp(class(dlg),'DAStudio.Dialog')
            url2=dlg.getUrl('DDGWebBrowser');
        else
            delete(webddg);
            pm_error('sm:smexportonshape:AuthenticationFailed');
        end

        drawnow;


        if contains(url2,'chrome-error')
            delete(webddg);
            pm_error('sm:smexportonshape:ConnectionFail');
        end


        if~contains(url2,'/oauth/signin')

            if contains(url2,'/oauth/approval?error=access_denied')
                delete(webddg);
                pm_error('sm:smexportonshape:PermissionDenied');
            end


            if contains(url2,'/oauth/approval?code=')
                delete(webddg);
                break;
            end

            pause(1);
        end


    end

    splitResult=strsplit(url2,'/oauth/approval?code=');
    code=splitResult{2};





    exchangeUrl='https://oauth.onshape.com/oauth/token';
    clientsecret='YGVOLLZPZ6M5SU2UGC3IBTYIUG53WRCOWGVCTDG44RB3HDMSFXDA====';

    response=webwrite(exchangeUrl,...
    'grant_type','authorization_code','code',code,...
    'client_id',clientid,'client_secret',clientsecret,...
    'redirect_uri','urn:ietf:wg:oauth:2.0:oob');
    accessToken=response.access_token;
    refreshToken=response.refresh_token;

end





function accessToken=refreshAccessToken()






    clientid='WDQVG4FR4C3POP7HKZGTEIAWPF4VDGEB4ATH6HI=';
    clientsecret='YGVOLLZPZ6M5SU2UGC3IBTYIUG53WRCOWGVCTDG44RB3HDMSFXDA====';
    refreshUrl='https://oauth.onshape.com/oauth/token';

    response=webwrite(refreshUrl,...
    'grant_type','refresh_token','refresh_token',persistentRefreshToken(),...
    'client_id',clientid,'client_secret',clientsecret);

    accessToken=response.access_token;

end














function xmlConvertSmiData(smiModel,xmlFile)

    [xDocNode,xRootAssembly,xAssemblies,xParts]=xmlNewRoot(smiModel);




    [xInstanceTree,xRootConstraints,xRootJoints]=...
    xmlNewRootAssembly(xDocNode,xRootAssembly,smiModel);


    for k=1:1:numel(smiModel.Instance)
        xmlNewInstanceTree(xDocNode,smiModel.Instance(k),xInstanceTree);
    end


    if(isfield(smiModel,'Joint')&&~isempty(fieldnames(smiModel.Joint)))
        for k=1:numel(smiModel.Joint)
            xmlAddJoint(xDocNode,smiModel.Joint(k).Type,xRootJoints,...
            smiModel.Joint(k));
        end
    end


    if isfield(smiModel,'Constraint')&&~isempty(fieldnames(smiModel.Constraint))
        for k=1:numel(smiModel.Constraint)
            xmlAddConstraint(xDocNode,smiModel.Constraint(k).Type,...
            xRootConstraints,smiModel.Constraint(k));
        end
    end




    if(isfield(smiModel,'Assembly'))&&~isempty(fieldnames(smiModel.Assembly))
        for i=1:1:numel(smiModel.Assembly)

            [xAssemblyConstraints,xAssemblyJoints]=xmlNewAssemblies(...
            xDocNode,xAssemblies,smiModel.Assembly(i));

            if(isfield(smiModel.Assembly(i),'Joint')&&...
                ~isempty(fieldnames(smiModel.Assembly(i).Joint)))

                for k=1:numel(smiModel.Assembly(i).Joint)
                    xmlAddJoint(xDocNode,smiModel.Assembly(i).Joint(k).Type,...
                    xAssemblyJoints,smiModel.Assembly(i).Joint(k));
                end

            end

            if(isfield(smiModel.Assembly(i),'Constraint')&&...
                ~isempty(fieldnames(smiModel.Assembly(i).Constraint)))

                for k=1:numel(smiModel.Assembly(i).Constraint)
                    xmlAddConstraint(xDocNode,...
                    smiModel.Assembly(i).Constraint(k).Type,...
                    xAssemblyConstraints,smiModel.Assembly(i).Constraint(k));
                end

            end
        end
    end



    for k=1:1:numel(smiModel.Part)
        xPart=xmlNewPart(xDocNode,xParts,smiModel.Part(k));
        xmlAddMassProp(xDocNode,xPart,smiModel.Part(k).MassProperties);

        xmlNewNode(xDocNode,'GeometryFile',xPart,'ATTR','name',...
        smiModel.Part(k).GeometryFile.Name,'type',...
        smiModel.Part(k).GeometryFile.Type);

        if(isfield(smiModel.Part(k),'VisualProperties'))
            xmlAddVisualProp(xDocNode,xPart,smiModel.Part(k).VisualProperties);
        end
    end


    xmlwrite(xmlFile,xDocNode);

end










































function xNode=xmlNewNode(xDocNode,name,xParentNode,varargin)

    xNode=xDocNode.createElement(name);
    xParentNode.appendChild(xNode);
    if numel(varargin)>1
        if strcmp(varargin(1),'ATTR')
            attri_num=numel(varargin);
            for i=2:2:attri_num
                xNode.setAttribute(varargin(i),varargin(i+1));
            end
        elseif strcmp(varargin(1),'TEXT')
            xNode.appendChild(xDocNode.createTextNode(varargin(2)));
        else
            error('Please specify ATTR or TEXT first.');
        end
    end

end













function[xdocNode,xRootAssembly,xAssemblies,xParts]=xmlNewRoot(smiModel)

    xdocNode=com.mathworks.xml.XMLUtils.createDocument('SimscapeMultibodyImportXML');
    xRootNode=xdocNode.getDocumentElement;

    xRootNode.setAttribute('xmlns','urn:mathworks:SimscapeMultibody:import');
    xRootNode.setAttribute('xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
    xRootNode.setAttribute('version','2.0');

    xCreateInfo=xmlNewNode(xdocNode,'Created',xRootNode,'ATTR',...
    'by',smiModel.CreatedInfo.By,'from',smiModel.CreatedInfo.From,...
    'using',smiModel.CreatedInfo.Using);

    createdOn=char(datetime('now','Format','MM/dd/yy||HH:mm:ss'));
    xCreateInfo.setAttribute('on',createdOn);

    xmlNewNode(xdocNode,'ModelUnits',xRootNode,'ATTR','mass',...
    smiModel.ModelUnits.Mass,'length',smiModel.ModelUnits.Length);

    xmlNewNode(xdocNode,'DataUnits',xRootNode,'ATTR','mass',...
    smiModel.DataUnits.Mass,'length',smiModel.DataUnits.Length);

    xRootAssembly=xmlNewNode(xdocNode,'RootAssembly',xRootNode);
    xAssemblies=xmlNewNode(xdocNode,'Assemblies',xRootNode);
    xParts=xmlNewNode(xdocNode,'Parts',xRootNode);

end







function xmlAddJointFrame(xDocNode,frameType,xJoint,data)

    xJointFrame=xmlNewNode(xDocNode,frameType,xJoint);
    xInstancePath=xmlNewNode(xDocNode,'InstancePath',xJointFrame);

    for i=1:numel(data.(frameType).Uid)
        xmlNewNode(xDocNode,'Uid',xInstancePath,...
        'TEXT',data.(frameType).Uid(i).Name);
    end

    xTransform=xmlNewNode(xDocNode,'Transform',xJointFrame);
    xmlNewNode(xDocNode,'Rotation',xTransform,'TEXT',...
    data.(frameType).Transform.Rotation);
    xmlNewNode(xDocNode,'Translation',xTransform,'TEXT',...
    data.(frameType).Transform.Translation);

end







function xmlAddJoint(xDocNode,jointType,xJoints,data)

    xJoint=xmlNewNode(xDocNode,jointType,xJoints,'ATTR',...
    'name',matlab.lang.makeValidName(data.Name));
    xmlAddJointFrame(xDocNode,'BaseFrame',xJoint,data);
    xmlAddJointFrame(xDocNode,'FollowerFrame',xJoint,data);

end








function xmlAddConstraintGeom(xDocNode,index,xConstraint,data)

    assert(index==1||index==2)

    xGeometry=xmlNewNode(xDocNode,'ConstraintGeometry',xConstraint,...
    'ATTR','geomType',data.Geometry(index).Type);
    xInstancePath=xmlNewNode(xDocNode,'InstancePath',xGeometry);

    for i=1:1:numel(data.Geometry(index).Uid)
        xmlNewNode(xDocNode,'Uid',xInstancePath,'TEXT',...
        data.Geometry(index).Uid(i).Name);
    end

    xmlNewNode(xDocNode,'Position',xGeometry,'TEXT',data.Geometry(index).Position);


    if(isfield(data.Geometry(index),'Axis'))
        xmlNewNode(xDocNode,'Axis',xGeometry,'TEXT',data.Geometry(index).Axis);
    end

end







function xmlAddConstraint(xDocNode,constraintType,xConstraints,data)

    xConstraint=xmlNewNode(xDocNode,constraintType,xConstraints,'ATTR',...
    'name',matlab.lang.makeValidName(data.Name));
    xmlAddConstraintGeom(xDocNode,1,xConstraint,data);
    xmlAddConstraintGeom(xDocNode,2,xConstraint,data);

end










function[xInstanceTree,xRootConstraints,xRootJoints]=...
    xmlNewRootAssembly(xDocNode,xRootassembly,smiModel)

    xRootassembly.setAttribute('name',smiModel.RootAssembly.Name);
    xRootassembly.setAttribute('uid',smiModel.RootAssembly.Uid);
    xRootassembly.setAttribute('version',smiModel.RootAssembly.Version);

    xInstanceTree=xmlNewNode(xDocNode,'InstanceTree',xRootassembly);
    xRootConstraints=xmlNewNode(xDocNode,'Constraints',xRootassembly);
    xRootJoints=xmlNewNode(xDocNode,'Joints',xRootassembly);

end






function xmlNewInstanceTree(xDocNode,instanceData,xInstanceParent)

    xInstance=xmlNewNode(xDocNode,'Instance',xInstanceParent,'ATTR',...
    'name',instanceData.Name);
    xInstance.setAttribute('uid',instanceData.Uid);
    xInstance.setAttribute('entityUid',instanceData.EntityUid);

    if(isfield(instanceData,'Grounded')&&strcmpi(instanceData.Grounded,'True'))
        xInstance.setAttribute('grounded','true');
    end

    if(isfield(instanceData,'Rigid')&&strcmpi(instanceData.Rigid,'True'))
        xInstance.setAttribute('rigid','true');
    end

    if(isfield(instanceData,'Group')&&~isempty(instanceData.Group))
        xInstance.setAttribute('rigidGroup',instanceData.Group);
    end

    rotationArray=[instanceData.Transform(1:3)',instanceData.Transform(5:7)',...
    instanceData.Transform(9:11)'];
    TranslationArray=[instanceData.Transform(4),instanceData.Transform(8),...
    instanceData.Transform(12)];
    xTransform=xmlNewNode(xDocNode,'Transform',xInstance);
    xmlNewNode(xDocNode,'Rotation',xTransform,'TEXT',...
    sprintf('%.9f ',rotationArray));
    xmlNewNode(xDocNode,'Translation',xTransform,'TEXT',...
    sprintf('%.9f ',TranslationArray));

    if(isfield(instanceData,'Instance'))
        for i=1:1:numel(instanceData.Instance)
            xmlNewInstanceTree(xDocNode,instanceData.Instance(i),xInstance);
        end
    end

end











function[xAssemblyConstraints,xAssemblyJoints]=...
    xmlNewAssemblies(xDocNode,xAssemblies,data)

    xAssembly=xmlNewNode(xDocNode,'Assembly',xAssemblies,'ATTR',...
    'name',data.Name,'uid',data.Uid);
    xmlNewNode(xDocNode,'ModelUnits',xAssembly,'ATTR','mass',...
    data.ModelUnits.Mass,'length',data.ModelUnits.Length);
    xAssemblyConstraints=xmlNewNode(xDocNode,'Constraints',xAssembly);
    xAssemblyJoints=xmlNewNode(xDocNode,'Joints',xAssembly);

end









function xPart=xmlNewPart(xDocNode,xParts,data)

    xPart=xmlNewNode(xDocNode,'Part',xParts,'ATTR','name',data.Name,'uid',data.Uid);
    xmlNewNode(xDocNode,'ModelUnits',xPart,'ATTR','mass',data.ModelUnits.Mass,...
    'length',data.ModelUnits.Length);

end






function xmlAddVisualProp(xDocNode,xPart,data)

    xVis=xmlNewNode(xDocNode,'VisualProperties',xPart);
    A=regexp(data.Ambient,' ','split');
    B=regexp(data.Diffuse,' ','split');
    C=regexp(data.Specular,' ','split');
    D=regexp(data.Emissive,' ','split');
    xmlNewNode(xDocNode,'Ambient',xVis,'ATTR','r',A{1},'g',A{2},'b',A{3},'a',A{4});
    xmlNewNode(xDocNode,'Diffuse',xVis,'ATTR','r',B{1},'g',B{2},'b',B{3},'a',B{4});
    xmlNewNode(xDocNode,'Specular',xVis,'ATTR','r',C{1},'g',C{2},'b',C{3},'a',C{4});
    xmlNewNode(xDocNode,'Emissive',xVis,'ATTR','r',D{1},'g',D{2},'b',D{3},'a',D{4});
    xmlNewNode(xDocNode,'Shininess',xVis,'TEXT',data.Shininess);

end






function xmlAddMassProp(xDocNode,xPart,data)

    xMassProp=xmlNewNode(xDocNode,'MassProperties',xPart);
    xmlNewNode(xDocNode,'Mass',xMassProp,'TEXT',data.Mass);
    xmlNewNode(xDocNode,'CenterOfMass',xMassProp,'TEXT',data.CenterOfMass);
    xmlNewNode(xDocNode,'Inertia',xMassProp,'TEXT',data.Inertia);

end
