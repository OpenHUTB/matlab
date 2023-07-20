function out=isAnySupportPackageInstalled()











    out=false;
    try
        pluginPackage=meta.package.fromName('matlabshared.supportpkg.internal.sppkglegacy');
        allClassNames={pluginPackage.ClassList.Name};


        if numel(allClassNames)>1
            out=true;
        end
    catch

    end
end

