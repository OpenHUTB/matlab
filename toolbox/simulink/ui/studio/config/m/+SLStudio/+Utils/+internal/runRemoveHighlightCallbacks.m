function runRemoveHighlightCallbacks(bdHandle)




    callbackPackageName="SLStudio.Utils.internal.removehighlight";
    callbackPackage=meta.package.fromName(callbackPackageName);

    for func=callbackPackage.FunctionList'
        feval(callbackPackageName+"."+func.Name,bdHandle);
    end

end
