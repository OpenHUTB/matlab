function SlreqImportDlg_Preview_callback(this,~)



    switch this.srcType
    case{1,2}
        if isempty(this.docObj)&&~isempty(this.srcDoc)
            this.docObj=rmidotnet.docUtilObj(this.srcDoc);
        end

        if isempty(this.docObj)
            return;
        end

        importOptions=this.msOptionsStruct();
        [~,shortName]=fileparts(this.srcDoc);
        rmiut.progressBarFcn('set',0.1,...
        getString(message('Slvnv:slreq_import:LookingForMatchesIn',shortName)));
        clb=onCleanup(@()rmiut.progressBarFcn('delete'));
        matchedItems=this.docObj.getItems(importOptions);
        rmiut.progressBarFcn('delete');
        if isempty(matchedItems)
            if isfield(importOptions,'match')
                errorMsg={getString(message('Slvnv:slreq_import:NoMatchesFor',importOptions.match)),...
                getString(message('Slvnv:slreq_import:TryAdjustPattern'))};
            else
                errorMsg=getString(message('Slvnv:slreq_import:NoBookmarksInDocument'));
            end

            errordlg(errorMsg,...
            getString(message('Slvnv:slreq_import:ContentSelection')));
        else
            this.docObj.updateScratchCopy();
            for i=1:length(matchedItems)
                item=matchedItems(i);
                switch item.type
                case 'parent'
                    this.docObj.highlightInScratch(item,'green');
                case{'match','bookmark'}
                    if this.srcType==1
                        this.docObj.highlightInScratch(item,'yellow');
                    else
                        this.docObj.highlightInScratch(item,'red');
                    end
                otherwise

                end
            end
        end

        [~,tempName]=fileparts(this.docObj.sTempDocPath);
        reqmgt('winFocus',tempName);
    otherwise
        errordlg('"Preview" not yet supported, see g1555408','UNDER CONSTRUCTION');
    end
end
