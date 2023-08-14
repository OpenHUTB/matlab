function nesl_slpostprocess(libHandle,libraryStruct)




    fNames=fieldnames(libraryStruct);
    for idx=1:numel(fNames)

        theField=fNames{idx};
        if any(strcmp(theField,{'lib','sl_postprocess'}))
            continue;
        end
        subLibStruct=libraryStruct.(theField);
        if~isstruct(subLibStruct)
            continue;
        end
        lib=subLibStruct.lib;
        if lib.Hidden
            continue;
        end
        subLibHandle=get_param([getfullname(libHandle),'/',pmsl_sanitizename(lib.Name)],'Handle');
        nesl_slpostprocess(subLibHandle,subLibStruct);

    end

    if isfield(libraryStruct,'sl_postprocess')


        feval(libraryStruct.sl_postprocess,libHandle);
    end

end

