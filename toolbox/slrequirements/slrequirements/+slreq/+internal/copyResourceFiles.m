


function imagePaths=copyResourceFiles(reqifFile,reqSetName)
    unzippedName=slreq.uri.getShortNameExt(reqifFile);
    unzippedDir=fileparts(reqifFile);











    imagePaths=copyContents(ensureEndingSlash(unzippedDir),...
    unzippedDir,reqSetName,{'.','..',unzippedName});
end



function paths=copyContents(baseDir,srcDir,reqSetName,skip)
    paths={};

    imageMgr=slreq.opc.ImageManager(reqSetName);



    reqifCacheDir=slreq.import.resourceCachePaths('REQIF');

    resourceBaseDir=slreq.opc.getUsrTempDir();

    entries=dir(srcDir);


    for i=1:numel(entries)
        entry=entries(i);
        if any(strcmp(entry.name,skip))
            continue;
        elseif entry.isdir



            src=fullfile(srcDir,entry.name);
            paths=[paths,copyContents(baseDir,src,reqSetName,skip)];%#ok<AGROW>
        else



            destName=strrep(entry.name,' ','_');
            destDir=extractAfter(srcDir,baseDir);
            [destDir,macroUsed]=imageMgr.unpackImages(destDir);
            if isempty(macroUsed)




                destDir=strrep(destDir,' ','_');





                destDir=fullfile(reqifCacheDir,destDir);


                if~exist(destDir,'dir')
                    mkdir(destDir);
                end
            end

            dest=fullfile(destDir,destName);



            if exist(destDir,'dir')~=7
                mkdir(destDir);
            end


            paths{end+1}=getOPCpath(resourceBaseDir,dest);%#ok<AGROW>

            try
                copyfile(fullfile(srcDir,entry.name),dest);
            catch ex

                debug=0;
            end
        end
    end
end


function out=getOPCpath(resourceBaseDir,in)
    out=strrep(in,'\','/');
    out=strrep(out,resourceBaseDir,'SLREQ_RESOURCE');
end


function out=ensureEndingSlash(in)

    if in(end)=='\'||in(end)=='/'
        out=in;
    else
        out=[in,filesep];
    end
end
