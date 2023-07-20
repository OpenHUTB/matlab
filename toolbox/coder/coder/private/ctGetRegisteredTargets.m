function[targets,versionMappings,vendorsAndTypes]=ctGetRegisteredTargets(targetVersionMap)








    try
        targetNames=projectCoderHardware();
    catch
        targetNames={};
    end

    targets=cell(numel(targetNames),1);
    versionMappings=cell(numel(targetNames),1);
    emptyJavaMap=java.util.Collections.emptyMap();

    if~isa(targetVersionMap,'java.util.Map')
        targetVersionMap=emptyJavaMap;
    end



    for i=1:numel(targetNames)
        try
            hardware=projectCoderHardware(targetNames{i});
            if isempty(hardware)
                continue
            end

            version=hardware.Version;
            assert(~isprop(hardware,'ParameterFilter'));


            [valid,error]=coder.internal.checkHardwareGuiCompliance(hardware);
            if~valid
                coder.internal.gui.asyncDebugPrint(error);
                continue
            end



            targets{i}=flattenForJava(hardware.HardwareInfo);
            targets{i}.ParameterInfo=flattenForJava(hardware.ParameterInfo);

            if~isfield(targets{i},'Version')
                targets{i}.Version=version;
            end

            if not(contains(hardware.Name,'nvidia','IgnoreCase',true))
                targets{i}.GpuCoderSupported=false;
            else
                targets{i}.GpuCoderSupported=true;
            end


            targets{i}.ParameterFilter=properties(hardware);

            if targetVersionMap.containsKey(hardware.Name)&&~isempty(targetVersionMap.get(hardware.Name))
                mMap=mapLegacyTargetSettings(hardware.Name,char(targetVersionMap.get(hardware.Name)));
                versionMappings{i}=mapToJavaMap(mMap);
            else
                versionMappings{i}=emptyJavaMap;
            end
        catch me
            coder.internal.gui.asyncDebugPrint(me);
        end
    end


    coder.make.internal.guicallback.getToolchains();


    typesMap=containers.Map();
    vendorsAndTypes=struct('Target',createHardwareStruct('Target',typesMap),...
    'Production',createHardwareStruct('Production',typesMap),...
    'GpuCoderVendors',{getGpuCoderHardwareVendors()},...
    'DeviceTypes',flattenTypesMap(typesMap));
end



function hwStruct=createHardwareStruct(instanceKey,typesMap)
    [vendors,defaultVendor]=getHardwareVendorNames(instanceKey);
    hardwareImpl=coder.HardwareImplementation;

    for i=1:numel(vendors)
        vendor=vendors{i};
        [vendorTypes,vendorDefaultType,vendorSelectableTypes]=getHardwareTypeNames(vendor,hardwareImpl);

        if~typesMap.isKey(vendor)
            typesMap(vendor)=struct('Types',{vendorTypes},'DefaultType',vendorDefaultType,'SelectableTypes',{vendorSelectableTypes});
        end
    end

    hwStruct=struct('Vendors',{vendors},...
    'DefaultVendor',defaultVendor);
end


function vendors=getGpuCoderHardwareVendors()
    vendors={'AMD','ARM Compatible','Intel','Generic'};
end


function typesStruct=flattenTypesMap(typesMap)
    vendors=cell(typesMap.size());
    types=cell(typesMap.size());
    defaults=cell(typesMap.size());
    selectableTypes=cell(typesMap.size());
    keys=typesMap.keys();
    for i=1:numel(keys)
        vendors{i}=keys{i};
        valueStruct=typesMap(keys{i});
        types{i}=valueStruct.Types;
        defaults{i}=valueStruct.DefaultType;
        selectableTypes{i}=valueStruct.SelectableTypes;
    end

    typesStruct=struct('Vendors',{vendors},'Types',{types},'DefaultTypes',{defaults},'SelectableTypes',{selectableTypes});
end



function javaMap=mapToJavaMap(map)
    assert(isa(map,'containers.Map'));
    javaMap=java.util.HashMap();
    keys=map.keys();

    for i=1:numel(keys)
        value=map(keys{i});

        if~isempty(value)
            javaMap.put(keys{i},value);
        end
    end
end


