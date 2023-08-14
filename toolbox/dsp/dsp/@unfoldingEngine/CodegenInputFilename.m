function[log,bcc]=CodegenInputFilename(obj,bc)





    try
        bcc=bc;

        codegen_line='codegen(obj.FunctionName,''-args'',obj.InputArgs,''-o'',[''lib'' obj.data.tempname ''original''],''-config'',bcc,''-d'',fullfile(obj.data.workdirectory,''codegen'',[obj.data.tempname ''original'']));';
        if~obj.Debugging
            [msg,log]=evalc(codegen_line);
            has_error=false;
            if~isfield(log,'summary')
                has_error=true;
            elseif~log.summary.passed
                if isempty(obj.BuildConfig)
                    bcc.DynamicMemoryAllocation='Threshold';
                    [msg,log]=evalc(codegen_line);
                    if~isfield(log,'summary')
                        has_error=true;
                    elseif~log.summary.passed
                        has_error=true;
                    end
                else
                    has_error=true;
                end
            end
            if has_error




                codegen_line='codegen(obj.FunctionName,''-args'',obj.InputArgs,''-o'',fullfile(obj.data.workdirectory,''codegen'',[obj.data.tempname ''original''],''original_mex''),''-d'',fullfile(obj.data.workdirectory,''codegen'',[obj.data.tempname ''original'']));';
                [msg2,log]=evalc(codegen_line);
                if~isfield(log,'summary')
                    error(msg2);
                elseif~log.summary.passed
                    error(msg2);
                else
                    error(msg);
                end
            end
        else
            log=eval(codegen_line);%#ok<EVLCS> 
        end

    catch err
        coder.internal.error('dsp:dspunfold:ErrorBuildInputFunction',strrep(err.message,'\','\\'));
    end
end


