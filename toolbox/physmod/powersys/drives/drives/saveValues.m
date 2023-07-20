
function saveValues(driveBlock,driveType)

    cfg=getDialogConfig(driveType);
    blockHandle=driveBlock;

    [fn,pn]=uiputfile('*.mat','Save Parameters As');
    if fn==0
        return
    end
    fullName=[pn,fn];

    for p=1:length(cfg)
        matlabCell=cfg(p).matlabCell;
        for q=1:length(cfg(p).javaTab)


            if(matlabCell(q)>0)
                values{cfg(p).javaTab(q)}{cfg(p).javaIdx(q)}=get_param(blockHandle,cfg(p).MasksmlnkVarNames{q});
            end


            if strcmp(cfg(p).maskType,'Vector Controller (WFSM)')&&strcmp(cfg(p).MasksmlnkVarNames{q},'daf')
                values{cfg(p).javaTab(q)}{cfg(p).javaIdx(q)}='5';
            end


        end
    end

    drive=struct('name',driveType,'tab1','','tab2','',...
    'tab3','');

    drive.tab1=values{1}';
    drive.tab2=values{2}';
    drive.tab3=values{3}';%#ok<STRNU>

    save(fullName,'drive');


end
