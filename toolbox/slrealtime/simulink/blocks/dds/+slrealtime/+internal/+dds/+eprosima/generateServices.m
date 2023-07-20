function filesPathsGenOrAdded=generateServices(data)





    filesPathsGenOrAdded={};
    location=fullfile((matlabroot),'toolbox','slrealtime','simulink',...
    'blocks','dds','dist');
    filesPathsGenOrAdded{end+1}=fullfile(location,'slrealtime_fastdds_adapter.cpp');
    filesPathsGenOrAdded{end+1}=fullfile(location,'slrealtime_fastdds_adapter.h');


    filesPathsGenOrAdded{end+1}=slrealtime.internal.dds.eprosima.emitDDSInitialize(data);


    typesFileName=dds.internal.simulink.Util.getDDSTypesHeaderFileName();

    tmplFile=fullfile(matlabroot,...
    'toolbox/dds/vendor/eprosima/internal/template/ddstypes.hpp.tlc');
    filePath=fullfile(data.buildDir,typesFileName);
    headerNames={};
    for i=1:length(data.xmlFiles)
        [~,name,~]=fileparts(data.xmlFiles{i});
        headerNames{end+1}=name;
    end
    headerNames=unique(headerNames);
    tdata=struct;
    tdata.fileNames=headerNames;
    tdata.modelName=data.modelName;
    tdata.typedefPairs=dds.internal.simulink.Util.getDDSTypedefPairs(data.modelName);
    tdata.namespaces=dds.internal.simulink.Util.getNamespaces(data.modelName);
    getStrAndWriteFile(tmplFile,filePath,'genTypes',tdata);
    filesPathsGenOrAdded{end+1}=filePath;

end

function getStrAndWriteFile(tmplFile,filePath,tmplFunction,data)
    str=dds.internal.coder.evalTLCWithParam(tmplFile,tmplFunction,data);
    writeFile=true;
    if isfile(filePath)
        try
            tfp=fopen(filePath,'r');
            clnUp=onCleanup(@()fclose(tfp));
            curCont=fread(tfp,'*char')';


            writeFile=~isequal(str,curCont);
        catch
            writeFile=true;
        end
    end
    if writeFile
        fp=fopen(filePath,'wt');
        if fp<0
            error(message('MATLAB:save:cantWriteFile',filePath));
        else
            fwrite(fp,str);
            fclose(fp);
        end
    end
end