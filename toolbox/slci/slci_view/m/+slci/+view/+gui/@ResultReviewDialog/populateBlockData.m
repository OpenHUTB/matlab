



function populateBlockData(obj)


    dm=obj.getDataManager();
    if isempty(dm)
        return;
    end


    obj.fBlockData.remove(keys(obj.fBlockData));

    src=slci.view.internal.getSource(obj.getStudio);
    vm=slci.view.Manager.getInstance;
    dmgr=vm.getData(src.modelH);

    subsystems=containers.Map();
    parentStatus=containers.Map();
    reportConfig=slci.internal.ReportConfig;
    blockObjects=slci.results.getBlockObjects(dm);
    for i=1:numel(blockObjects)
        bObj=blockObjects{i};
        if isa(bObj,'slci.results.StateflowObject')
            sid=bObj.getSID;
        else
            sid=bObj.getBlockSID;
        end

        if~bObj.getIsVisible

            continue;
        end

        rtwName=Simulink.ID.getFullName(sid);
        if isempty(rtwName)


            continue;
        end

        status=bObj.getStatus;

        if isa(bObj,'slci.results.BlockObject')

            if isSourceBlock(sid)&&strcmpi(status,'VERIFIED')

                continue;
            end
        end


        codeLines='';
        blockTraceArray=bObj.getTraceArray;

        codeTrace=slci.view.data.CodeTrace();
        if~isempty(blockTraceArray)
            for j=1:numel(blockTraceArray)
                cj=blockTraceArray{j};
                lineTrace=strsplit(cj,filesep);
                lineTrace=strsplit(lineTrace{end},':');
                codeTrace.addTrace(lineTrace{1},lineTrace{2});
                codeLines=codeTrace.toString();
            end
            dmgr.populateTraceCaches(sid,codeTrace);
        end

        if isa(bObj,'slci.results.BlockObject')...
            ||isa(bObj,'slci.results.ChartObject')
            parent=get_param(rtwName,'parent');
        else
            parent=Simulink.ID.getFullName(bObj.getParent);
        end
        data={};

        data.codelines=codeLines;
        data.parent=parent;
        data.status=status;
        data.sid=sid;
        obj.fBlockData(rtwName)=data;
        if isKey(parentStatus,parent)
            parentStatus(parent)=reportConfig.getHeaviestStatus(status,parentStatus(parent));
        else
            parentStatus(parent)=status;
        end
    end

    ksubs=keys(subsystems);
    for i=1:numel(ksubs)
        key=ksubs{i};
        if~isKey(obj.fBlockData,key)
            data={};
            data.codelines='';
            parent=get_param(key,'parent');
            data.parent=parent;
            if isKey(parentStatus,key)
                data.status=parentStatus(key);
            else
                data.status='';
            end
            data.sid=Simulink.ID.getSID(key);
            obj.fBlockData(key)=data;
        end
    end



    if~isempty(parentStatus)
        data={};
        data.codelines='';
        data.parent='';
        data.sid=Simulink.ID.getSID(src.modelName);
        data.status=reportConfig.getHeaviest(values(parentStatus));
        obj.fBlockData(src.modelName)=data;
    end

end


function out=isSourceBlock(blksid)
    blktype=get_param(blksid,'BlockType');
    switch blktype
    case{'Inport','Constant','From','Goto'}
        out=true;
    otherwise
        out=false;
    end
end
