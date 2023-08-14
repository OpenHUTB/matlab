function loadValues(driveBlock,driveType)

    cfg=getDialogConfig(driveType);
    blockHandle=driveBlock;

    electricDrivesParamsRoot=fullfile(matlabroot,'toolbox','physmod',...
    'powersys','drives','DrivesParameters');

    if getenv('ELECTRICDRIVES_ROOT')

        electricDrivesParamsRoot=fullfile(getenv('ELECTRICDRIVES_ROOT'),...
        'DrivesParameters');
    end


    [fn,pn]=uigetfile(electricDrivesParamsRoot,'Load Parameters');
    if fn==0
        return
    end
    fullName=[pn,fn];

    temp=load(fullName);

    paramErrorFlag=0;
    if isstruct(temp)
        if isfield(temp,'drive')
            drive=temp.drive;
            if(~isfield(drive,'name')||~isfield(drive,'tab1')||...
                ~isfield(drive,'tab2')||~isfield(drive,'tab3'))
                paramErrorFlag=1;
            end
        else
            paramErrorFlag=1;
        end
    else
        paramErrorFlag=1;
    end

    if paramErrorFlag
        error(message('physmod:powersys:drives:BadParameters',fullName,''));
    end

    if~strcmp(driveType,drive.name)
        error(message('physmod:powersys:drives:IncompatibleDrives',drive.name,type));
    end

    nbBlock=length(cfg);
    tabCells=[];
    for k=1:nbBlock
        tabCells=[tabCells,cfg(k).loadIdx];%#ok<AGROW>
    end
    nbTab=length(unique(tabCells));
    for k=1:nbTab
        idx=find(tabCells==k);
        maxIndex(k)=length(tabCells(idx));%#ok<FNDSB,AGROW>
    end




    if(strcmp(driveType,'AC1')||strcmp(driveType,'AC2')||strcmp(driveType,'AC3')...
        ||strcmp(driveType,'AC4'))


        drive.tab1{21}='Forward Euler';
    end




    if(strcmp(driveType,'AC6')||strcmp(driveType,'AC7'))
        if strcmp(drive.tab1{8},'Flux induced by magnets (Wb)')
            drive.tab1{8}='Flux linkage established by magnets (V.s)';
        end
    end

    if(length(maxIndex)==3)

        if(size(drive.tab1,1)==maxIndex(1)&&...
            size(drive.tab2,1)==maxIndex(2)&&...
            size(drive.tab3,1)==maxIndex(3))

            drive.tabs{1}=drive.tab1;
            drive.tabs{2}=drive.tab2;
            drive.tabs{3}=drive.tab3;


            for p=1:length(cfg)
                matlabCell=cfg(p).matlabCell;
                for q=1:length(cfg(p).javaTab)


                    if(matlabCell(q)>0)
                        set_param(blockHandle,cfg(p).MasksmlnkVarNames{q},drive.tabs{cfg(p).javaTab(q)}{cfg(p).javaIdx(q)});
                    end
                end
            end

        else
            error(message('physmod:powersys:drives:BadParameters',fullName,...
            'The size of the data structure does not match the expected size.'));
        end

    else
        error(message('physmod:powersys:drives:BadParameters',fullName,...
        'The size of the data structure does not match the expected size.'));
    end
end
