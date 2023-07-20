function linkSet=getLoadedLinkSetByName(this,fileShortName)











    linkSet=[];
    linkSets=this.repository.linkSets.toArray();
    for i=1:length(linkSets)


        filePathBase=linkSets(i).filepath;

        if reqmgt('rmiFeature','IncArtExtInLinkFile')
            filePathBase=regexprep(filePathBase,'~\w*\.slmx$','.slmx');
        end

        [~,sName]=fileparts(filePathBase);
        if strcmp(sName,fileShortName)
            linkSet=this.wrap(linkSets(i));
            return;
        end
    end
end
