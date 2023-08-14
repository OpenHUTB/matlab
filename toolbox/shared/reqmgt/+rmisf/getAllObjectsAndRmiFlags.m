function[sfHs,sfFlags,sfObjs]=getAllObjectsAndRmiFlags(modelObj,filterSettings,slHs)



    sfFilter=rmisf.sfisa('isaFilter');
    sfObjs=find(modelObj,sfFilter);

    sfHs=get(sfObjs,'Id');
    if iscell(sfHs)
        sfHs=cell2mat(sfHs);
    end

    sfFlags=false(length(sfHs),1);
    for i=1:length(sfHs)
        if rmi.objHasReqs(sfHs(i),filterSettings)
            sfFlags(i)=true;
        end
    end





    if nargin>2&&~isempty(slHs)
        slfObjs=find(modelObj,'-isa','Stateflow.SLFunction');
        if~isempty(slfObjs)
            if iscell(slfObjs)
                slfObjs=cell2mat(slfObjs);
            end
            for i=1:length(slfObjs)
                subSys=slfObjs(i).getDialogProxy();
                subBlocks=find(subSys,'-isa','Simulink.Block');
                subHs=get(subBlocks,'Handle');
                if iscell(subHs)
                    subHs=cell2mat(subHs);
                end
                if~isempty(intersect(subHs,slHs))


                    slfId=slfObjs(i).Id;
                    sfFlags(sfHs==slfId)=true;
                end
            end
        end
    end
end
