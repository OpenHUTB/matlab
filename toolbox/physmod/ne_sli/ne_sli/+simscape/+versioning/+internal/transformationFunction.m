function outData=transformationFunction(inData)






    outData.NewInstanceData=inData.InstanceData;
    outData.NewBlockPath=inData.ForwardingTableEntry.('__slOldName__');

    if isempty(outData.NewInstanceData)
        return;
    end

    ov=inData.ForwardingTableEntry.('__slOldVersion__');

    blockVer=simscape.versioning.version(ov.ModelVersion);
    blockVer.type='simulink';

    outData=lImpl(outData,blockVer);

end











function data=lImpl(data,blockVer)
    SourceFile=lGetInstanceValue(data.NewInstanceData,'SourceFile');

    dotparts=strsplit(SourceFile,'.');
    libname=dotparts{1};
    [~,forwards]=simscape.versioning.internal.libversion(libname);

    if blockVer.type==simscape.versioning.VersionType.simulink
        fwds=sortedForwards(forwards.sl,SourceFile);
        for fwd=fwds
            if blockVer<fwd.Version
                data=lApplyForward(data,fwd);
                return;
            end
        end
    end



    if~simscape.versioning.internal.enabled
        return;
    end

    blockVer=simscape.versioning.version;
    slv=lGetInstanceValue(data.NewInstanceData,'SimscapeLibraryVersion');
    if~isempty(slv)
        blockVer=simscape.versioning.version(slv);
    end

    fwds=sortedForwards(forwards.ssc,SourceFile);
    for fwd=fwds
        if blockVer<fwd.Version
            data=lApplyForward(data,fwd);
            return;
        end
    end
end

function data=lApplyForward(data,fwd)

    data.NewInstanceData=lModify(data.NewInstanceData,...
    fwd.Modify);


    if~isempty(fwd.NewVersion)
        blockVer=fwd.NewVersion;
    else
        blockVer=fwd.Version;
    end

    if blockVer.type==simscape.versioning.VersionType.simscape
        data.NewInstanceData=lSetInstanceValue(data.NewInstanceData,...
        'SimscapeLibraryVersion',...
        char(blockVer));
    end


    data.NewInstanceData=lSetInstanceValue(data.NewInstanceData,...
    'SourceFile',...
    fwd.NewSimscapePath);


    if~isempty(fwd.NewSimulinkPath)
        data.NewBlockPath=fwd.NewSimulinkPath;
    end


    data=lImpl(data,blockVer);
end

function InstanceData=lModify(InstanceData,modify)

    if isempty(modify)
        return;
    elseif isa(modify,'function_handle')
        InstanceData=modify(InstanceData);
    elseif isa(modify,'struct')
        InstanceData=lModify_struct(InstanceData,modify);
    end
end



function out=lModify_struct(InstanceData,modify)
    out=InstanceData;
    idents=fields(modify);

    for idx=1:numel(idents)
        newident=idents{idx};
        expr=char(modify.(newident));

        newIDs=simscape.versioning.internal.ModifyExpr(expr,InstanceData);
        for newID=newIDs'
            out=lSetInstanceValue(out,[newident,newID.Name],newID.Value);
        end
    end
end




function value=lGetInstanceValue(InstanceData,name)
    value='';

    idx=find(strcmp({InstanceData.Name},name),1);
    if isempty(idx)
        return;
    end
    value=InstanceData(idx).Value;
end




function InstanceData=lSetInstanceValue(InstanceData,name,value)
    idx=find(strcmp({InstanceData.Name},name),1);
    if~isempty(idx)
        InstanceData(idx).Value=value;
    else
        InstanceData(end+1)=struct('Name',name,'Value',value);
    end
end