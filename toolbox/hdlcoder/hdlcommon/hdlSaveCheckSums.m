function hdlSaveCheckSums(modelName,nameChecksums)






    mytable=struct2table(nameChecksums,'AsArray',true);
    mytable.checksum=join(string(mytable.checksum),2);
    mytable=sortrows(mytable,{'checksum','name'});
    [~,ia,~]=unique(mytable.checksum);
    ia=vertcat(ia,length(mytable.checksum)+1);

    clones={};
    for i=2:length(ia)
        a=ia(i-1);
        b=ia(i);
        if b-a>1
            clones{end+1}=mytable.name(a:(b-1));
        end
    end






    hDrv=hdlcurrentdriver;
    if isempty(hDrv)||~hDrv.CalledFromMakehdl||isempty(hDrv.hdlGetCodegendir)



        return;
    end
    codegendir=hDrv.hdlMakeCodegendir;


    folderName=fullfile(codegendir,'HDL_Checksums');
    if~exist(folderName,'dir')
        mkdir(folderName)
    end

    fileName=fullfile(folderName,[modelName,'_chks.mat']);
    chks={modelName,clones,mytable};
    save(fileName,'chks')


end