classdef LayerToCompUtils<handle





    properties(Constant)


        InvalidFileNameCharacters='<>:/\\|?*"';
    end

    methods(Static)

        function name=sanitizeName(name)


            name=regexprep(name,['['...
            ,dltargets.internal.utils.LayerToCompUtils.InvalidFileNameCharacters,']'],'_');




            name=regexprep(name,' +','_');
        end

        function isSanitized=isSanitizedName(name)

            isSanitized=~contains(name,[dltargets.internal.utils.LayerToCompUtils.InvalidFileNameCharacters,' ']);
        end

        function outName=getCompFileName(filename,parameterDirectory,codegentarget)
            filename=dltargets.internal.utils.LayerToCompUtils.sanitizeName(filename);

            if strcmpi(codegentarget,'mex')

                outName=fullfile(parameterDirectory,filename);
            else

                cdir=pwd;
                fdir=strrep(parameterDirectory,cdir,'.');
                outFileName=fullfile(fdir,filename);

                outName=strrep(outFileName,'\','/');
            end
        end


        function setCustomHeaderProperty(comp,layerHeaders)

            compType=comp.getCompKey();
            if isKey(layerHeaders,compType)
                headerFile=layerHeaders(compType);
                [~,headername,ext]=fileparts(headerFile);
                header=[headername,ext];
                comp.setCustomDesignHeaders(header);
            end

        end




        function layerInputSizes=getLayerInputSizes(layer,layerAnalyzers)

            currentLayerLogicalIdx=strcmp([layerAnalyzers.Name],layer.Name);
            currentLayerAnalyzer=layerAnalyzers(currentLayerLogicalIdx);
            layerInputSizes=currentLayerAnalyzer.Inputs.Size;
        end

    end

end
