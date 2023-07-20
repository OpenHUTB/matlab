function processPLogData(this)




    pLogData=cvi.SimscapeCov.handlePrototypeLogData();
    if isempty(pLogData)
        return;
    end
    logData=simscape.coverage.extractModeInfo(pLogData);
    this.covData=[];
    for idx=1:numel(logData)
        cld=logData(idx);

        fidx=[];
        if~isempty(this.covData)
            fidx=({this.covData.block_path}==string(cld.block_path));
        end
        if~isempty(fidx)
            if isempty(this.covData(fidx).modes)
                this.covData(fidx).modes=cld;
            else
                this.covData(fidx).modes(end+1)=cld;
            end
        else
            ns=struct('block_path',cld.block_path,'modes',cld,'allOutcomes',[]);
            if isempty(this.covData)
                this.covData=ns;
            else
                this.covData(end+1)=ns;
            end
        end
    end
    if cvi.SimscapeCov.handlePrototypeId()==0
        getOutcomesP0(this);
        getDescr0(this);
        getOutcomeHitCountsP0(this);
    elseif cvi.SimscapeCov.handlePrototypeId()==1
        getOutcomesP1(this);
        getDescr1(this);
        getOutcomeHitCountsP1(this);
    end
end

function getOutcomesP1(this)
    for idx=1:numel(this.covData)
        for mIdx=1:numel(this.covData(idx).modes)
            this.covData(idx).modes(mIdx).outcomes=[0,1];
            this.covData(idx).modes(mIdx).hitCounts=[];
        end
    end
    for idx=1:numel(this.covData)
        outcomes={this.covData(idx).modes.outcomes};
        this.covData(idx).outcomes=allComb(outcomes{:});
        this.covData(idx).hitCounts=[];
    end
end

function res=allComb(varargin)
    args=varargin;
    n=nargin;
    [F{1:n}]=ndgrid(args{:});
    for i=n:-1:1
        G(:,i)=F{i}(:);
    end
    res=unique(G,'rows');
end

function getDescr1(this)
    links={};
    for idx=1:numel(this.covData)
        for mIdx=1:numel(this.covData(idx).modes)
            mode=this.covData(idx).modes(mIdx);
            fileFullPath=which(mode.file_path);
            links{mIdx}=sprintf('<a href="matlab:opentoline(''''%s'''', %d, %d);">%s</a>',fileFullPath,mode.row,mode.col,mode.name);
        end
        links=strjoin(links,',');
        this.covData(idx).descr=strcat('(',links,')');
    end

end

function getOutcomeHitCountsP1(this)
    for bIdx=1:numel(this.covData)
        allOutcomes=[this.covData(bIdx).modes.value];
        for oIdx=1:size(this.covData(bIdx).outcomes,1)
            co=[this.covData(bIdx).outcomes(oIdx,:)];
            mathcingRows=ismember(allOutcomes,co,'rows');
            hitCounts=numel(find(mathcingRows==1));
            if isempty(this.covData(bIdx).hitCounts)
                this.covData(bIdx).hitCounts=hitCounts;
            else
                this.covData(bIdx).hitCounts(end+1)=hitCounts;
            end
        end
    end
end

function getOutcomesP0(this)
    for idx=1:numel(this.covData)
        for mIdx=1:numel(this.covData(idx).modes)
            this.covData(idx).modes(mIdx).outcomes=[0,1];
            this.covData(idx).modes(mIdx).hitCounts=[];
        end
    end
end

function getDescr0(this)
    for idx=1:numel(this.covData)
        for mIdx=1:numel(this.covData(idx).modes)
            mode=this.covData(idx).modes(mIdx);
            fileFullPath=which(mode.file_path);
            this.covData(idx).modes(mIdx).descr=sprintf('<a href="matlab:opentoline(''''%s'''', %d, %d);">%s</a>',fileFullPath,mode.row,mode.col,mode.name);
        end

    end
end

function getOutcomeHitCountsP0(this)
    for bIdx=1:numel(this.covData)
        for mIdx=1:numel(this.covData(bIdx).modes)
            for oIdx=1:numel(this.covData(bIdx).modes(mIdx).outcomes)
                hitCounts=numel(find(this.covData(bIdx).modes(mIdx).value==this.covData(bIdx).modes(mIdx).outcomes(oIdx)));
                if isempty(this.covData(bIdx).modes(mIdx).hitCounts)
                    this.covData(bIdx).modes(mIdx).hitCounts=hitCounts;
                else
                    this.covData(bIdx).modes(mIdx).hitCounts(end+1)=hitCounts;
                end
            end
        end
    end
end


