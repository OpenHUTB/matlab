function out=zcs(s)
    import simscape.statistics.data.internal.Statistic







    out=Statistic(...
    'Data',lZCTable(s.Children),...
    'Name',s.Name,...
    'Description',s.Description);
    out.Data.Properties.Description=s.Description;
end

function t=lZCTable(zcs)
    t=repmat(struct('SignalName',{},'BlockName',{},'ComponentName',{},'File',{},'Line',{},'Column',{}),1,0);
    for iBlock=1:numel(zcs)
        blockName=zcs(iBlock).Name;
        sid=zcs(iBlock).Sources.Object;
        cmps=zcs(iBlock).Children;
        for iComp=1:numel(cmps)
            cmpName=cmps(iComp).Name;
            signals=cmps(iComp).Children;
            if isempty(signals)
                t(end+1)=lAddEntry(cmps(iComp),blockName,'');
            else
                for iSignal=1:numel(signals)
                    t(end+1)=lAddEntry(signals(iSignal),blockName,cmpName);%#ok<AGROW>
                end
            end
        end
    end
    t=lFilterEmptySource(struct2table(t));
end

function t=lAddEntry(signal,blockName,cmpName)


    if~isempty(signal.Sources)
        src=signal.Sources;
        t.File=src(1).Path;
        dStart=strsplit(src(1).Object,'|');
        pm_assert(strcmp(src(1).Path,src(2).Path));
        dStop=strsplit(src(2).Object,'|');
        t.Line=[str2double(dStart{2}),str2double(dStop{2})];
        t.Column=[str2double(dStart{3}),str2double(dStop{3})];
    else
        t.File='';
        t.Line=[];
        t.Column=[];
    end
    t.BlockName=blockName;
    if isempty(cmpName)&&~isempty(t.File)
        [~,cmpName]=fileparts(t.File);
    end
    t.ComponentName=cmpName;
    t.SignalName=signal.ID;


end

function out=lFilterEmptySource(tbl)
    if isempty(tbl)
        ns=table([],'VariableNames',{'nSignals'});
        out=[tbl,ns];
        return
    end
    noSource=cellfun(@(f)isempty(f),tbl.File);
    tblNoSource=tbl(noSource,:);
    [~,a,b]=unique(tblNoSource(:,{'BlockName','ComponentName'}),'rows');

    n=hist(b,unique(b));%#ok<HIST> 
    tblNoSource=tblNoSource(a,:);
    tblNoSource.nSignals=n(:);
    tblSrc=tbl(~noSource,:);
    tblSrc.nSignals=ones(size(tblSrc,1),1);
    out=[tblSrc;tblNoSource];
end