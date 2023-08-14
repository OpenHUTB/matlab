function update(this,localDataRefreshed,dasObj)






    if nargin<2
        localDataRefreshed=false;
    end

    if nargin<3
        dasObj=[];
    end

    slreq.utils.assertValid(this);

    if this.isUserActionInProgress()&&isempty(dasObj)
        this.setUserActionFinishCallback('MainManager.update',@()update(this,localDataRefreshed));
        return;
    end

    if~localDataRefreshed


        this.updateRollupStatusAndChangeInformationIfNeeded();
    end

    if~isempty(this.requirementsEditor)
        this.requirementsEditor.update();
    end
    if~isempty(this.spreadsheetManager)
        this.spreadsheetManager.update();
    end

    this.refreshUI(dasObj);
end
