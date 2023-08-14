function dialogCB(this,action,hDlg)




    switch lower(action)
    case 'select'
        resDir=regexp(this.selectedItem,'.*(\(.*\))$','tokens');
        if isempty(resDir)

            idx=find(strcmpi(this.selectedItem,this.treeItemsList));
            if~isempty(idx)
                gIdx=find(this.goodTreeItems);

                goodIdx=find(gIdx<idx,1,'last');
                if~isempty(goodIdx)
                    parentName='';
                    goodIdx=gIdx(goodIdx);
                    if goodIdx>idx
                        parentName=[this.selectedItem,'/'];
                    end
                    this.selectedItem=[parentName,strrep(this.treeItemsList{goodIdx},'/','//')];

                    hDlg.refresh();
                    return
                end
            end
        end
    otherwise

    end

