function includePtx(varargin)%#codegen





    coder.extrinsic('coder.gpu.internal.getPtxFiles');
    coder.extrinsic('isunix');
    coder.extrinsic('ispc');
    coder.extrinsic('isUsingHSP');
    if~coder.target('MATLAB')
        coder.allowpcode('plain');
        coder.inline('always');

        if coder.internal.targetLang('GPU')

            [headers,sources,fullPaths]=...
            coder.const(@coder.gpu.internal.getPtxFiles,varargin);



            for i=1:length(headers)
                coder.cinclude(headers{i});
                coder.updateBuildInfo('addIncludeFiles',headers{i});
            end

            for i=1:length(sources)
                coder.updateBuildInfo('addSourceFiles',sources{i});
            end

            if~isempty(headers)||~isempty(sources)

                ctx=eml_option('CodegenBuildContext');
                if coder.const(feval('coder.gpu.internal.isUsingHSP',ctx))

                elseif coder.const(isunix)
                    coder.updateBuildInfo('addLinkFlags','-lcuda');
                elseif coder.const(ispc)
                    coder.updateBuildInfo('addLinkFlags','cuda.lib');
                end
            end


            coder.gpu.internal.includePtxImpl(fullPaths{:});
        end
    end
end
