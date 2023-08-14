function[oVal1,oVal2]=modelRefUtil(modelName,info,detail,varargin)






    oVal2='';
    switch info
    case 'getBinExt'
        oVal1=loc_get_bin_ext(detail);

    case 'getSimTargetName'
        oVal1=[modelName,loc_get_bin_ext(detail),'.',mexext];

    case 'featureName'
        oVal1='ModelReference';

    case 'getHeadFileList'



        allFileList=dir(detail.SourcesDir);
        headFileList=[];
        for fileIdx=1:length(allFileList)
            if strfind(allFileList(fileIdx).name,'.h')
                headFileList{end+1}=allFileList(fileIdx).name;%#ok<AGROW>
            end
        end

        oVal1=headFileList;
        oVal2=allFileList;

    case 'getSubmodelTargetType'



        if strcmpi(detail,'accel')
            oVal1='SIM';
        else
            oVal1='RTW';
        end

    case 'getModelRefInfoFileName'
        lSystemTargetFile=varargin{1};
        if length(varargin)>1
            isSILOrPILProtected=varargin{2};
        else
            isSILOrPILProtected=false;
        end

        oVal1=get_file_name_for_MF0_Information(modelName,detail,lSystemTargetFile,isSILOrPILProtected);

    case 'copyModelRefInfoFile'
        lSystemTargetFile=varargin{1};
        if length(varargin)>1
            isSILOrPILProtected=varargin{2};
        else
            isSILOrPILProtected=false;
        end


        copy_MF0_Information(modelName,detail,lSystemTargetFile,isSILOrPILProtected)

    case 'setupFolderCacheForReferencedModel'
        topModel=detail;
        setupFolderCacheForReferencedModel(topModel,modelName);

    otherwise
        DAStudio.error('RTW:buildProcess:modelrefutilUnknownInput',info);
    end
end




function setupFolderCacheForReferencedModel(topModel,refModel)



    if~Simulink.filegen.internal.BuildFolderCache.contains(refModel)



        if bdIsLoaded(refModel)
            Simulink.filegen.internal.FolderConfiguration(refModel);
        else
            Simulink.filegen.internal.FolderConfiguration.copyCacheFrom(topModel,refModel);
        end
    end
end



function filename=get_mf0_filename(targetType)
    switch targetType
    case{'SIM','RTW'}
        filename='ModelRefCompileInfo.xml';

    case{'NONE'}
        filename='CompileInfo.xml';

    otherwise
        assert(false,['Unknown target type:  ',targetType]);
    end
end



function fileName=get_file_name_for_MF0_Information...
    (modelName,targetType,lSystemTargetFile,isSILOrPILProtected)
    rootDir=coder.internal.infoMATPostBuild...
    ('getTMWInternalDirectory','binfo',modelName,targetType,...
    lSystemTargetFile,isSILOrPILProtected);
    fileName=fullfile(rootDir,get_mf0_filename(targetType));
end






function copy_MF0_Information(modelName,targetType,lSystemTargetFile,isSILOrPILProtected)
    rootFile=get_mf0_filename(targetType);
    rootDir=coder.internal.infoMATPostBuild...
    ('getTMWInternalDirectory','binfo',modelName,targetType,...
    lSystemTargetFile,isSILOrPILProtected);
    fileName=fullfile(rootDir,rootFile);
    if(~exist(fileName,'file'))


        paDir=coder.internal.ParallelAnchorDirManager('get',targetType);
        if(~isempty(paDir))


            paRoot=coder.internal.infoMATPostBuild...
            ('getTMWInternalDirectory','binfo',modelName,targetType,...
            lSystemTargetFile,isSILOrPILProtected,paDir);
            paFile=fullfile(paRoot,rootFile);
            if(exist(paFile,'file'))


                destDir=fileparts(fileName);
                if(~exist(destDir,'dir'))


                    mkdir(destDir);
                end

                copyfile(paFile,fileName);
            end
        end
    end
end


function ext=loc_get_bin_ext(protected)
    if(protected)
        ext='_msp';
    else
        ext='_msf';
    end
end



