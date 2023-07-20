function exclusions=showExclusion(this)



    exclusion=struct('Block',[],'Handle',[]);
    exclusions=repmat(exclusion,1,length(this.fExcludedBlks));
    for i=1:length(this.fExcludedBlks)
        fullname=getfullname(this.fExcludedBlks(i));
        exclusions(i).Handle=get_param(fullname,'handle');
        exclusions(i).Block=fullname;
    end
end
