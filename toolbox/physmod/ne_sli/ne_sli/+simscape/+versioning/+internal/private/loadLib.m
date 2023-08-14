function[libver,forwards]=loadLib(libm)









    libinfo=simscape.Library('');
    feval(libm,libinfo);

    libver=libinfo.version;

    isSscType=@(x)x.Version.type==...
    simscape.versioning.VersionType.simscape;
    sscVersion=cellfun(isSscType,libinfo.forwards);

    forwards.ssc=lMakeForwardImpl(libinfo.forwards(sscVersion));
    forwards.sl=lMakeForwardImpl(libinfo.forwards(~sscVersion));
end






function out=lMakeForwardImpl(forwards)
    out=simscape.versioning.internal.ForwardImpl.empty;

    isTransform=@(x)isa(x,'simscape.versioning.Transform');
    transforms=cellfun(isTransform,forwards);


    for cellobj=forwards(transforms)
        obj=cellobj{1};
        idx=lLookup(out,obj.SimscapePath,obj.Version);

        if~isempty(idx)
            pm_error('physmod:ne_sli:versioning:MultipleTransforms',...
            obj.SimscapePath,char(obj.Version));
        end
        out(end+1)=simscape.versioning.internal.ForwardImpl;%#ok
        idx=numel(out);

        out(idx).OldSimscapePath=obj.SimscapePath;
        out(idx).NewSimscapePath=obj.SimscapePath;
        out(idx).LegacySimscapePath=obj.LegacySimscapePath;
        out(idx).Version=obj.Version;
        out(idx).Modify=obj.Modify;
        lValidateModify(obj.Modify,obj.SimscapePath,char(obj.Version));
    end


    for cellobj=forwards(~transforms)
        obj=cellobj{1};
        idx=lLookup(out,obj.OldSimscapePath,obj.Version);

        if isempty(idx)

            out(end+1)=simscape.versioning.internal.ForwardImpl;%#ok
            idx=numel(out);
        end

        if~isempty(out(idx).OldSimulinkPath)
            pm_error('physmod:ne_sli:versioning:MultipleForwards',...
            obj.OldSimscapePath,char(obj.Version));
        end

        out(idx).OldSimscapePath=obj.OldSimscapePath;
        out(idx).NewSimscapePath=obj.NewSimscapePath;
        out(idx).OldSimulinkPath=obj.OldSimulinkPath;
        out(idx).NewSimulinkPath=obj.NewSimulinkPath;
        out(idx).Version=obj.Version;
        if~isempty(obj.NewVersion)
            out(idx).NewVersion=obj.NewVersion(1);
        end

        if isempty(out(idx).LegacySimscapePath)


            out(idx).LegacySimscapePath=obj.NewSimscapePath;
        end
    end
end



function idx=lLookup(forwards,path,version)
    idx=strcmp({forwards.OldSimscapePath},path)&...
    arrayfun(@(x)x==version,[forwards.Version]);
    idx=find(idx);
    assert(numel(idx)<=1);
end


function lValidateModify(modify,pth,version)
    if isempty(modify)||~isstruct(modify)
        return;
    end
    idents=fieldnames(modify);
    for idx=1:numel(idents)
        try
            expr=char(modify.(idents{idx}));
            simscape.versioning.internal.ModifyExpr(expr,...
            struct('Name',{},'Value',{}),true);
        catch ME
            exe=MException(message('physmod:ne_sli:versioning:InvalidModifyEntry',...
            idents{idx},pth,version));
            exe=exe.addCause(ME);
            throw(exe);
        end
    end
end