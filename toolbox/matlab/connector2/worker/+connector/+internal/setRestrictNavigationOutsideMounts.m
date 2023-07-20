function setRestrictNavigationOutsideMounts(flag)




    cdAnywhereDisabled='false';
    if(islogical(flag))
        if flag
            cdAnywhereDisabled='true';
        end

        setenv('MW_CD_ANYWHERE_DISABLED',cdAnywhereDisabled);
        if usejava('jvm')
            f=java.lang.System.getenv().getClass().getDeclaredField('m');
            f.get(java.lang.System.getenv()).put('MW_CD_ANYWHERE_DISABLED',cdAnywhereDisabled);
        end
    end
end

