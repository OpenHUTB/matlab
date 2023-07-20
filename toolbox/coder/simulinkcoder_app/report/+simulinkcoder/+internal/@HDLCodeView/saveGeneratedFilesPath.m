function saveGeneratedFilesPath(pir,codegenDir,varargin)





    if nargin>2
        isRef=varargin{1};
    end

    if nargin>3
        rootDir=varargin{2};
    end

    if nargin>4
        traceStyle=varargin{3};
    else
        traceStyle=pir.getParamValue('TraceabilityStyle');
    end

    ext=pir.getHDLFileExtension;

    if~isRef
        topName=pir.getTopNetwork.Name;
        codeForPath=pir.getTopNetwork.FullPath;
    else
        topName=pir.ModelName;
        codeForPath=topName;
    end

    codeViewInfo=struct;
    codeViewInfo.codeFor=topName;
    codeViewInfo.codeForPath=codeForPath;
    codeViewInfo.codegenDir=codegenDir;
    codeViewInfo.traceStyleFromBuild=traceStyle;


    entityNames=pir.getEntityNames;
    entityPath=pir.getEntityPaths;


    if(hdlgetparameter('split_entity_arch')&&hdlgetparameter('isvhdl'))
        entityPostFix=hdlgetparameter('split_entity_file_postfix');
        archPostFix=hdlgetparameter('split_arch_file_postfix');
        isPackageGen=pir.VhdlPackageGenerated;

        codeInfo=cell((length(entityNames)*2-isPackageGen),1);
        for i=1:(length(entityNames)-isPackageGen)
            currEntityPath=entityPath{i};
            codeInfo{i*2-1}=getCodeInfoStruct([entityNames{i},entityPostFix],ext,codegenDir,...
            currEntityPath);
            codeInfo{i*2}=getCodeInfoStruct([entityNames{i},archPostFix],ext,codegenDir,...
            currEntityPath);
        end

        if(isPackageGen)
            codeInfo{end}=getCodeInfoStruct(entityNames{end},ext,codegenDir,...
            entityPath{end});
        end
    else
        codeInfo=cell(length(entityNames),1);
        for i=1:length(entityNames)
            entityInfo=getCodeInfoStruct(entityNames{i},ext,codegenDir,...
            entityPath{i});
            codeInfo{i}=entityInfo;
        end
    end
    codeViewInfo.codeInfo=codeInfo;


    scripts={};
    compDoFile.name=[topName,hdlgetparameter('hdlcompilefilepostfix')];
    compDoFile.loc=fullfile(codegenDir,compDoFile.name);
    scripts{end+1}=compDoFile;

    simDoFile.name=[topName,hdlgetparameter('hdlsimfilepostfix')];
    simDoFile.loc=fullfile(codegenDir,simDoFile.name);
    scripts{end+1}=simDoFile;

    simProjFile.name=[topName,hdlgetparameter('hdlsimprojectfilepostfix')];
    simProjFile.loc=fullfile(codegenDir,simProjFile.name);
    scripts{end+1}=simProjFile;

    synthesisFile.name=[topName,hdlgetparameter('hdlsynthfilepostfix')];
    synthesisFile.loc=fullfile(codegenDir,synthesisFile.name);
    scripts{end+1}=synthesisFile;

    mapFile.name=[topName,hdlgetparameter('hdlmapfilepostfix')];
    mapFile.loc=fullfile(codegenDir,mapFile.name);
    scripts{end+1}=mapFile;

    codeViewInfo.scripts=scripts;

    saveLoc=fullfile(codegenDir,'hcv');
    save(saveLoc,'codeViewInfo','rootDir','-mat');

end
function codeInfoStruct=getCodeInfoStruct(currEntityName,ext,...
    codegenDir,entityPath)
    codeInfoStruct.enName=currEntityName;
    codeInfoStruct.enFileName=[currEntityName,ext];
    codeInfoStruct.enCodePath=fullfile(codegenDir,[currEntityName,ext]);
    codeInfoStruct.subsysPath=entityPath;
end


