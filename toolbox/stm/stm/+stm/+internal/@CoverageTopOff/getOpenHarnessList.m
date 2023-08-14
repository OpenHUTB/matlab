function harnessList=getOpenHarnessList(topModel)
    tmpList=sltest.harness.find(topModel,'OpenOnly','on');
    harnessList=repmat(struct('harnessName','','harnessOwner',''),length(tmpList));
    for k=1:length(tmpList)
        harnessList(k).harnessName=tmpList(k).name;
        harnessList(k).harnessOwner=tmpList(k).ownerFullPath;
        harnessList(k).rebuildOnOpen=tmpList(k).rebuildOnOpen;
        harnessList(k).saveExternally=tmpList(k).saveExternally;
    end
end