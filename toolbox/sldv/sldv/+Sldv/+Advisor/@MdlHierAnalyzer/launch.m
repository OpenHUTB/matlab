function launch(this)






    pi=Sldv.Utils.ScopedProgressIndicator('Sldv:ComponentAdvisor:LoadingCAIndicator');
    try

        this.setup();

        root=this.MdlHierInfo.CompGraph;



        meNode=root.addUIProxy([]);



        if slavteng('feature','TGALoadSavePrevResults')
            pi.updateTitle('Sldv:ComponentAdvisor:SearchingData');
            [hasValidPrevResults,modelEdited,modelList]=this.Store.readFromDB();
            if hasValidPrevResults
                pi.updateTitle('Sldv:ComponentAdvisor:LoadingData');
                try
                    this.Store.load();

                    if modelEdited
                        MSLDiagnostic('Sldv:ComponentAdvisor:ModelEditedAfterPreviousRun',modelList).reportAsWarning;
                    end
                catch Mex
                    if modelEdited
                        new_mex=MException('Sldv:ComponentAdvisor:ModelEditedAfterPreviousRun',...
                        getString(message('Sldv:ComponentAdvisor:ModelEditedAfterPreviousRun',modelList)));
                        new_mex=new_mex.addCause(Mex);
                        MSLDiagnostic(new_mex).reportAsWarning;
                    else
                        MSLDiagnostic(Mex).reportAsWarning;
                    end
                end
            end
        end


        pi.updateTitle('Sldv:ComponentAdvisor:CreatingApp');
        this.Explorer=this.createExplorer(meNode);



        this.Explorer.show;

        this.updateTimeStamp();

        this.updateStatusMessage(message('Sldv:ComponentAdvisor:StatusInitialized'));
    catch Mex
        Exp=MException('Sldv:ComponentAdvisor:ErrorLoadingComponentAdvisor',...
        getString(message('Sldv:ComponentAdvisor:ErrorLoadingComponentAdvisor')));
        Exp=Exp.addCause(Mex);
        throw(Exp);
    end

end

