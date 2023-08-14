function lcs=getLowestCommonAncestor(sids)







    lcs=[];
    if~iscell(sids)
        lcs=sids;
        return;
    elseif numel(sids)==1
        lcs=sids{1};
        return;
    end

    if isempty(sids),return;end

    [h,~,blockH,~,~]=Simulink.ID.getHandle(sids);

    for i=1:numel(h)
        if isa(h{i},'Stateflow.Object')
            sids{i}=Simulink.ID.getSID(blockH{i});
        end
    end


    pathElems=cell(1,numel(sids));
    minLeng=intmax;
    for i=1:numel(sids)


        pathElems{i}=strsplit(Simulink.ID.getFullName(sids{i}),...
        '(?<!/)/(?!/)','DelimiterType','RegularExpression');
        if(minLeng>numel(pathElems{i}))
            minLeng=numel(pathElems{i});
        end
    end


    idx=0;
    for i=1:minLeng
        isSame=true;
        for j=2:numel(pathElems)
            if~strcmp(pathElems{j}{i},pathElems{1}{i})
                isSame=false;
                break;
            end
        end

        if isSame
            idx=i;
        else
            break;
        end
    end

    if idx>0
        lcs=Simulink.ID.getSID(strjoin(pathElems{1}(1:idx),'/'));
    end

