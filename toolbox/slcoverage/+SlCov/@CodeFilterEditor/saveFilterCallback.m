function saveFilterCallback(this,dlg,varargin)




    title=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveFilter'));
    [~,fileName,~]=fileparts(this.fileName);
    if this.isUnknownFile||strcmp(fileName,getString(message('Slvnv:simcoverage:cvresultsexplorer:NotSaved')))
        str=SlCov.CodeFilterEditor.defaultFileName(this.modelName);
    else
        str=fileName;
    end
    str=[str,'.cvf'];
    fullFileName=cvi.ResultsExplorer.ResultsExplorer.uiPutFile(str,title);
    if~isempty(fullFileName)


        fromApplyCallback=numel(varargin)>=1&&~isempty(varargin{1})&&varargin{1}==true;
        if~fromApplyCallback
            if~isempty(this.nameTag)
                this.filterName=dlg.getWidgetValue(this.nameTag);
            end
            if~isempty(this.descriptionTag)
                this.filterDescr=dlg.getWidgetValue(this.descriptionTag);
            end
        end

        this.fileName=fullFileName;
        this.saveAs(fullFileName);
        this.isUnknownFile=false;

        if~fromApplyCallback
            this.updateResults();

            this.hasUnappliedChanges=false;
            this.lastFilterElement={};
            if~isempty(this.nameTag)
                dlg.clearWidgetDirtyFlag(this.nameTag);
            end
            if~isempty(this.descriptionTag)
                dlg.clearWidgetDirtyFlag(this.descriptionTag);
            end
        end
    end


