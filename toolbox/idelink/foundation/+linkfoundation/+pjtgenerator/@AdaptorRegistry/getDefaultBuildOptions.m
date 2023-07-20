function opts=getDefaultBuildOptions(reg,AdaptorName)




    adaptorInfo=reg.getAdaptorInfo(AdaptorName);


    mt=struct('debug','','release','','custom','');
    mtopts=struct('compiler',mt,'linker',mt);


    if isfield(adaptorInfo,'DefaultBuildOptsFcn')
        fcn=adaptorInfo.DefaultBuildOptsFcn;
        opts=fcn();

        mtopts_flds=fields(mtopts);
        for i=1:length(mtopts_flds)
            mt_flds=fields(mtopts.(mtopts_flds{i}));
            for j=1:length(mt_flds)
                if~isfield(opts,mtopts_flds{i})||~isfield(opts.(mtopts_flds{i}),mt_flds{j})
                    opts.(mtopts_flds{i}).(mt_flds{j})=mtopts.(mtopts_flds{i}).(mt_flds{j});
                end
            end
        end
    else
        opts=mtopts;
    end

end

