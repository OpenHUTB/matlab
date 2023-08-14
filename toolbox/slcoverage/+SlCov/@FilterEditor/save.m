function save(this,varargin)



    if~isempty(varargin)

        fileName=varargin{1};
    else
        fileName=this.fileName;
    end
    this.needSave=false;
    ui=false;
    if numel(varargin)>1
        ui=varargin{2};
    end

    state={};
    values=this.filterState.values;
    for idx=1:numel(values)
        prop=values{idx};
        state{end+1}={prop.id,prop.value,prop.valueDesc,prop.Rationale,prop.mode};
    end

    ruleFieldName=this.savedStructFieldName;

    fullFileName=cvi.ReportUtils.appendFileExtAndPath(fileName,'.cvf');
    [outputDir,fileName,ext]=fileparts(fullFileName);
    errorReporting=1;
    if ui
        errorReporting=2;
    end
    newOutputDir=cvi.TopModelCov.checkOutputDir(outputDir,errorReporting);
    if~isempty(newOutputDir)
        fullFileName=fullfile(newOutputDir,append(fileName,ext));
    end


    if exist(fullFileName,'file')

        try
            var=load(fullFileName,'-mat');
        catch MEx %#ok<NASGU>

        end
    end


    var.(ruleFieldName){1}=state;
    var.filterName=this.filterName;
    var.filterDescr=this.filterDescr;
    var.uuid=this.getUUID;
    [path,file,ext,msg]=cvi.ReportUtils.getFilePartsWithWriteChecks(fullFileName,'.cvf',ui);
    if~isempty(msg)
        warndlg(getString(msg),getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveFilter')),'modal');
        return;
    end
    this.isReadOnly=false;
    fullFileName=fullfile(path,append(file,ext));
    save(fullFileName,'-struct','var');

