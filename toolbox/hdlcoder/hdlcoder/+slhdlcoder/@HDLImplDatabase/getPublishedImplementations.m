function[newImpls,implpvpairs]=getPublishedImplementations(this,blockLibPath)





    publishImpls={};
    implpvpairs={};

    newImpls=this.getImplementationsFromBlock(blockLibPath);
    for jj=1:length(newImpls)
        impl=eval(newImpls{jj});

        if impl.getPublish
            archName=impl.getPreferredArchitectureName();
            publishImpls=[publishImpls;archName];%#ok<AGROW>
            newPVPairs=impl.implParamNames;
            implpvpairs={implpvpairs{:},newPVPairs};
        end
    end
    newImpls=publishImpls;
end
