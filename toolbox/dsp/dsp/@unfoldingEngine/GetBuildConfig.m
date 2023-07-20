function bc=GetBuildConfig(obj)





    bc=coder.config('lib','ECODER',false);
    bc.DynamicMemoryAllocation='Off';


    if~isempty(obj.BuildConfig)
        if isa(obj.BuildConfig,'coder.MexCodeConfig')
            targetFieldNames=fieldnames(bc);
            sourceFieldNames=fieldnames(obj.BuildConfig);
            for i=1:numel(sourceFieldNames)
                if(sum(strcmp(targetFieldNames,sourceFieldNames{i}))~=0)
                    v=getfield(obj.BuildConfig,sourceFieldNames{i});
                    if(~isempty(v))
                        bc=setfield(bc,sourceFieldNames{i},v);%#ok<SFLD>
                    end
                end
            end
        else
            bc=obj.BuildConfig;
            coder.internal.errorIf((~strcmpi(bc.OutputType,'lib')),'dsp:dspunfold:InvalidBuildConfig');
            if(~obj.Debugging)
                bc.BuildConfiguration='Faster Runs';
            else
                bc.BuildConfiguration='Debug';
            end
        end
    end

    if(~obj.Debugging)
        bc.BuildConfiguration='Faster Runs';
        bc.Verbose=false;
    else
        bc.BuildConfiguration='Debug';
        bc.Verbose=true;
    end

    bc.TargetLang='C';
    if ispc
        bc.TargetLangStandard='C89/C90 (ANSI)';
    else
        bc.TargetLangStandard='C99 (ISO)';


    end

    bc.GenerateReport=false;
    bc.PassStructByReference=true;
    bc.CodeFormattingTool='MathWorks';

end

