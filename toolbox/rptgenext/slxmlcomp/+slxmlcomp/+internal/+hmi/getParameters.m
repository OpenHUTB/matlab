function results=getParameters(file,partPath)



    HMI_VARIABLE='Bindings';
    DATA_JSON_FIELD='Widget';
    SOURCE_FIELD='Source';

    hmiDataStruct=extractHMIDataFromPart(file,partPath);

    hmiDataStruct=hmiDataStruct.(HMI_VARIABLE);

    import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.plugins.blockdiagram.units.hmi.HMINodeBuilder
    import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.plugins.blockdiagram.units.hmi.HMINodeListBuilder
    nodeListBuilder=HMINodeListBuilder();

    for i=1:length(hmiDataStruct)
        nodeBuilder=HMINodeBuilder();
        addWidgetParameters(nodeBuilder,hmiDataStruct(i).(DATA_JSON_FIELD));
        addSourceBlockParameters(nodeBuilder,hmiDataStruct(i).(SOURCE_FIELD));
        nodeListBuilder.addHMINode(nodeBuilder.build());
    end
    results=nodeListBuilder.build();
end


function hmiResults=extractHMIDataFromPart(file,partPath)
    tempDir=tempname;
    if(~exist(tempDir,'dir'))
        mkdir(tempDir);
        deleteDir=onCleanup(@()rmdir(tempDir,'s'));
    end
    tempMat=fullfile(tempDir,'webhmi.mat');

    reader=Simulink.loadsave.SLXPackageReader(char(file));

    reader.readPartToFile(partPath,tempMat);
    hmiResults=load(tempMat);
end

function addWidgetParameters(nodeBuilder,hmiWidgetData)
    nodeBuilder.addJson(hmiWidgetData);
end

function addSourceBlockParameters(nodeBuilder,sourceStruct)
    if(~isempty(sourceStruct))
        fieldNames=fieldnames(sourceStruct);
        for j=1:length(fieldNames)
            nodeBuilder.addSourceParam(fieldNames{j},string(sourceStruct.(fieldNames{j})));
        end
    end
end

