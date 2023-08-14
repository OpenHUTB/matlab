function ConfigSet_CodeReplacementLibrary(obj)


    if isR2020aOrEarlier(obj.ver)
        sets=getConfigSets(obj.modelName);
        for i=1:length(sets)
            CSorCSR=getConfigSet(obj.modelName,sets{i});
            if isa(CSorCSR,'Simulink.ConfigSetRef')&&isR2006bOrEarlier(obj.ver)
                real_cs=CSorCSR.getRefConfigSet;
                real_cs_copy=copy(real_cs);
                locSetTargetFunctionLibrary(real_cs_copy,obj.ver);
                attachConfigSet(obj.modelName,real_cs_copy,true);
                if(CSorCSR.isActive)
                    setActiveConfigSet(obj.modelName,real_cs_copy.Name);
                end
                detachConfigSet(obj.modelName,CSorCSR.Name);
                set_param(real_cs_copy,'Name',CSorCSR.Name);
            elseif~isa(CSorCSR,'Simulink.ConfigSetRef')
                locSetTargetFunctionLibrary(CSorCSR,obj.ver);
            end
        end
    end






    function locSetTargetFunctionLibrary(configSet,saveAsVersionObj)

        if isR2020aOrEarlier(saveAsVersionObj)

            crlName=get_param(configSet,'CodeReplacementLibrary');
            crlList=coder.internal.getCrlLibraries(crlName);
            firstCrlName=crlList{1};
            set_param(configSet,'CodeReplacementLibrary',firstCrlName);
        end

        if isR2014aOrEarlier(saveAsVersionObj)
            crlName=get_param(configSet,'CodeReplacementLibrary');

            if(ismember(crlName,{'Intel IPP for x86-64 (Windows)',...
                'Intel IPP for x86/Pentium (Windows)',...
                'Intel IPP for x86-64 (Linux)'}))
                set_param(configSet,'CodeReplacementLibrary','Intel IPP');
            elseif(ismember(crlName,{'Intel IPP/SSE with GNU99 extensions for x86-64 (Windows)',...
                'Intel IPP/SSE with GNU99 extensions for x86/Pentium (Windows)',...
                'Intel IPP/SSE with GNU99 extensions for x86-64 (Linux)'}))
                set_param(configSet,'CodeReplacementLibrary','Intel IPP/SSE with GNU99 extensions');
            end
        end

        if isR2013bOrEarlier(saveAsVersionObj)



            crlName=get_param(configSet,'CodeReplacementLibrary');
            tgtLangStd=get_param(configSet,'TargetLangStandard');
            oldCrlName=crlName;
            if strcmpi(crlName,'none')

                switch tgtLangStd
                case{'C89/C90 (ANSI)','C99 (ISO)'}
                    oldCrlName=tgtLangStd;
                case 'C++03 (ISO)'
                    oldCrlName='C++ (ISO)';
                end
            elseif strcmpi(crlName,'Intel IPP/SSE with GNU99 extensions')
                oldCrlName='Intel IPP (GNU)';
            elseif strcmpi(crlName,'GNU C99 extensions')
                oldCrlName='GNU99 (GNU)';
            elseif strcmpi(crlName,'TI C28x with C99 extensions')
                oldCrlName='TI C28x (ISO)';
            elseif strcmpi(crlName,'TI C55x with C99 extensions')
                oldCrlName='TI C55x (ISO)';
            elseif strcmpi(crlName,'TI C62x with C99 extensions')
                oldCrlName='TI C62x (ISO)';
            elseif strcmpi(crlName,'ADI BF53x with C99 extensions')
                oldCrlName='ADI BF53x (ISO)';
            elseif strcmpi(crlName,'ADI SHARC with C99 extensions')
                oldCrlName='ADI SHARC (ISO)';
            end
            set_param(configSet,'CodeReplacementLibrary',oldCrlName);
        end

        if isR2009bOrEarlier(saveAsVersionObj)
            value=get_param(configSet,'CodeReplacementLibrary');

            if strcmp(value,'C++ (ISO)')||strcmp(value,'ISO_C++')
                set_param(configSet,'CodeReplacementLibrary','ISO_C')
            end
        end

        if isR2007aOrEarlier(saveAsVersionObj)
            value=get_param(configSet,'CodeReplacementLibrary');
            switch RTW.resolveTflName(value)
            case RTW.resolveTflName('GNU')
                set_param(configSet,'CodeReplacementLibrary','GNU');
                set_param(configSet,'TargetFcnLib','gnu_tfl_tmw.mat');
            case RTW.resolveTflName('ISO_C')
                set_param(configSet,'CodeReplacementLibrary','ISO_C');
                set_param(configSet,'TargetFcnLib','iso_tfl_tmw.mat');
            otherwise
                set_param(configSet,'CodeReplacementLibrary','ANSI_C');
                set_param(configSet,'TargetFcnLib','ansi_tfl_tmw.mat');
            end
        end
