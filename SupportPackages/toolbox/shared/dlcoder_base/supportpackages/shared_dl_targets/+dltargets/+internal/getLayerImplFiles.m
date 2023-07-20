function[csrcs,headers]=getLayerImplFiles(hN,layerSources,layerHeaders,target,libraryVersion)







    if nargin<5
        libraryVersion='';
    end

    layerComps=hN.Components;
    layerCompKeys=arrayfun(@(x)getCompKey(x),layerComps,'UniformOutput',false);

    csrcs=iSelectVersionedFiles(layerSources,libraryVersion,layerCompKeys,target);
    headers=iSelectVersionedFiles(layerHeaders,libraryVersion,layerCompKeys,target);

end







function versionedFiles=iSelectVersionedFiles(files,libraryVersion,layerCompKeys,target)
    assert(isa(files,'containers.Map'));
    versionedFiles={};
    for k=1:numel(layerCompKeys)
        layerCompKey=layerCompKeys{k};
        if isKey(files,layerCompKey)
            cellEntry=files(layerCompKey);
            if isa(cellEntry,'containers.Map')
                assert(isKey(cellEntry,libraryVersion));
                file=cellEntry(libraryVersion);
            else
                file=cellEntry;
            end
            versionedFiles=[versionedFiles,file];%#ok
        elseif~contains(layerCompKey,'gpucoder.custom_')

            assert(false,message('dlcoder_spkg:cnncodegen:unsupported_comp',layerCompKey));
        end
    end

    versionedFiles=unique(versionedFiles);
    versionedFiles=cellfun(@(x)replaceSourceDirWithMangledDir(x,target),versionedFiles,'UniformOutput',false);
end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
function newfile=replaceSourceDirWithMangledDir(ffilename,target)
    [dir,file,ext]=fileparts(ffilename);



    directoryParts=split(dir,{'/','\'});
    folderTarget=directoryParts{end};

    assert(ismember(folderTarget,{'cudnn','tensorrt','mkldnn','onednn','arm_mali','arm_neon','cmsis_nn'}),...
    'Folder containing file is not named after a supported target.');





    if strcmp(target,'tensorrt')
        assert(any(strcmp(folderTarget,{'tensorrt','cudnn'})),...
        'TensorRT files should exist in the tensorrt or cudnn folders.');
    elseif strcmp(target,'mkldnn')
        assert(any(strcmp(folderTarget,{'onednn'})),...
        'MklDNN files should exist in the onednn folder.');
    else
        assert(strcmp(target,folderTarget),...
        'Files should exist in the folder named after the 3p library target.');
    end





    precompiledFolderStructure=any(strcmp(target,{'cudnn','tensorrt','mkldnn','onednn'}));
    if precompiledFolderStructure&&strcmp(ext,'.hpp')
        sourcePattern=[fullfile(folderTarget,'export','include',folderTarget),'$'];
        targetPattern=fullfile('mangled',folderTarget);


        sourcePattern=strrep(sourcePattern,'\','\\');
        targetPattern=strrep(targetPattern,'\','\\');

        newdir=regexprep(dir,sourcePattern,targetPattern);
        assert(~isequal(newdir,dir),'expected dir pattern was not found');
    else
        targetPattern=fullfile('mangled',folderTarget);


        targetPattern=strrep(targetPattern,'\','\\');

        newdir=regexprep(dir,[folderTarget,'$'],targetPattern);
        assert(~isequal(newdir,dir),'expected dir pattern was not found');
    end

    newfile=fullfile(newdir,[file,ext]);
end
