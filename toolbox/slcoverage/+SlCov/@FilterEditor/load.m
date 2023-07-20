function load(this,fileName)




    if isempty(fileName)
        return;
    end

    foundFileName=SlCov.FilterEditor.findFile(fileName,this.modelName);
    if isempty(foundFileName)
        return;
    elseif isa(foundFileName,'message')
        error(foundFileName);
    end
    [~,userWrite]=cvi.ReportUtils.checkUserWrite(foundFileName);
    this.isReadOnly=~userWrite;
    state=loadFilter(this,foundFileName);
    allPropMap=SlCov.FilterEditor.getPropertyDB;
    for idx=1:numel(state)
        id=state{idx}{1};
        if allPropMap.isKey(id)
            newProp=allPropMap(id);
            newProp.value=state{idx}{2};
            newProp.valueDesc=state{idx}{3};
            newProp.Rationale=state{idx}{4};
            newProp.mode=0;
            if numel(state{idx})>4
                newProp.mode=state{idx}{5};
            end

            validProp=true;
            if this.hasSSID(newProp)
                validProp=~isempty(this.getPropSSID(newProp));
            elseif newProp.isCode

                [~,ssid]=SlCov.FilterEditor.decodeCodeFilterInfo(newProp.value);
                validProp=isempty(ssid);
            end
            if validProp
                this.addProp(newProp);
            end
        end
    end


    function state=loadFilter(this,fileName)
        ruleFieldName=this.savedStructFieldName;

        try
            var=load(fileName,'-mat');
        catch e
            if strcmp(e.identifier,'MATLAB:load:notBinaryFile')
                error(message('Slvnv:simcoverage:filterEditor:NotValidFilter',fileName));
            else
                rethrow(e);
            end
        end

        if isfield(var,ruleFieldName)

            state=var.(ruleFieldName){1};

            if isfield(var,'filterName')
                this.filterName=var.filterName;
                this.filterDescr=var.filterDescr;
                this.uuid=var.uuid;
            end
        else
            error(message('Slvnv:simcoverage:filterEditor:NotValidFilter',fileName));
        end



