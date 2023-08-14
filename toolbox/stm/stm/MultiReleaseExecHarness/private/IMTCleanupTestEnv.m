function IMTCleanupTestEnv(TestInfo,TestParams)











    try



        if~isempty(TestInfo)
            evalin('base',TestInfo.pre_model_close_action);


            if isempty(TestInfo.model_close_action)





                if~isempty(regexp(bdroot,TestInfo.ModelName,'ONCE'))
                    close_system(TestInfo.ModelName,0);
                end

                if isfield(TestParams,'SubsystemCodeGenModel')
                    close_system(TestParams.SubsystemCodeGenModel,0);
                end

                try
                    bdclose all
                catch
                    disp(lasterr);
                end
            else
                evalin('base',TestInfo.model_close_action);
            end


            evalin('base',TestInfo.post_model_close_action);

            diary off;
            tempDirName=fileparts(TestParams.diaryFileName);
            [success,msg,msgID]=rmdir(tempDirName,'s');
            if~success
                disp(msg);
            end
        end
    catch
        disp(lasterr);
    end


