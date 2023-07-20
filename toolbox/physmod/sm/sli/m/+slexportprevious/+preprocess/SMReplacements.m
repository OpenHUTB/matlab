function SMReplacements(obj)




    verobj=obj.ver;


    allVers=simulink_version.all_releases;
    idx=find(strcmpi(allVers,verobj.release));
    gtvers=allVers(end:-1:idx+1);

    for i=1:length(gtvers)


        changes=simmechanics.sli.internal.getBlockPathMapsForVersion(gtvers{i});
        for j=1:length(changes)
            cpath=strrep(changes(j).NewPath,newline,'\n');
            opath=strrep(changes(j).OldPath,newline,'\n');
            obj.appendRule(sprintf('<Block<SourceBlock|"%s":repval "%s">>',cpath,opath));
        end



        nblocks=simmechanics.sli.internal.getNewBlocksInVersion(gtvers{i});
        obj.removeLibraryLinksTo(nblocks);
    end

end
