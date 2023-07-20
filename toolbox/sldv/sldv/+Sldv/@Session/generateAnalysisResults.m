



function[status,msg,fileNames]=generateAnalysisResults(obj,testComp,status,msg,fileNames)
    sldvData=[];

    if(Sldv.SessionState.AnalysisSuccess==obj.mState)







        if obj.mShowUI
            if strcmpi(testComp.analysisStatus,'Stopped by user')
                assert(1==status);
                try
                    produceResults=obj.abortDialogWindow();
                catch MEx
                    produceResults=0;
                    if(strcmp(MEx.identifier,'Sldv:Session:invalidObj'))
                        rethrow(MEx);
                    end
                end
                if~produceResults
                    status=0;
                end
            end
        end


        if((1==status)||(-1==status))

            obj.mState=Sldv.SessionState.GeneratingResults;

            try
                [resGenStatus,msg,fileNames,sldvData]=obj.mSldvAnalyzer.generateResults();
            catch
                resGenStatus=0;
                if~isvalid(obj)
                    MEx=MException('Sldv:Session:invalidObj',...
                    'SLDV Session is no longer valid');
                    throw(MEx);
                end
            end

            if~resGenStatus
                status=0;
            end
        end




        if((1==status)||(-1==status))
            obj.mState=Sldv.SessionState.ResultsSuccess;
        else
            assert(0==status);
            obj.mState=Sldv.SessionState.ResultsFailure;
        end
    end


    if(Sldv.SessionState.ResultsSuccess==obj.mState)&&~isempty(sldvData)
        obj.logAnalysisResults(sldvData);
    end







    if~status
        obj.refreshInformer();
    end
end
