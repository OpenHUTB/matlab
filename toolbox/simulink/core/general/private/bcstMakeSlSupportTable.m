function h=bcstMakeSlSupportTable(model,do_unknown,topModel,allLibs)




    closeLibs=false;
    libData=[];

    if iscell(model)
        modelType=-1;
    else
        modelType=exist(model);%#ok<EXIST>
    end
    if modelType==4
        allCaps=bcstExtractBlockCaps(model);
    elseif modelType~=-1&&strcmp(model,'simulink')
        load_system('simulink_hmi_blocks');
        allCaps=cat(2,bcstExtractBlockCaps(model),bcstExtractBlockCaps('simulink_hmi_blocks'));
    elseif modelType==2||modelType==6||modelType==-1

        if~iscell(model)
            model={model};
            allCaps=Capabilities;allCaps(1)=[];
            multiLib=false;
        else
            allCaps=bcstExtractBlockCaps('simulink');
            multiLib=true;
        end
        libData.current=cell(0,0);
        libData.open=[];
        libData.hasLong=false;
        dataIdx=0;
        for modIdx=1:length(model)
            oneModel=model{modIdx};
            oneModel=regexprep(oneModel,'\.[pm]$','');
            libInfo=eval(oneModel);
            doLongName=isfield(libInfo,'formalNames');
            if isfield(libInfo,'formalName')
                if multiLib
                    libData.longs.(allLibs{modIdx})=libInfo.formalName;
                else
                    libData.longs.(topModel)=libInfo.formalName;
                end
            end
            for libIdx=1:length(libInfo.current)
                dataIdx=dataIdx+1;
                libName=libInfo.current{libIdx};
                libData.current{dataIdx}=libName;
                libData.open(dataIdx)=isempty(find_system(...
                'SearchDepth',0,'CaseSensitive','off',...
                'Name',libName));

                if doLongName
                    if multiLib
                        libData.longs.(libName)=[libInfo.formalName,'/'...
                        ,libInfo.formalNames{libIdx}];
                    else
                        libData.longs.(libName)=libInfo.formalNames{libIdx};
                    end
                    libData.hasLong=true;
                end
            end
        end

        for libIdx=1:length(libData.current)
            if libData.open(libIdx)
                load_system(libData.current{libIdx});
            end
            someCaps=bcstExtractBlockCaps(libData.current{libIdx});
            if~isempty(someCaps)
                allCaps(end+1:end+length(someCaps))=someCaps;
            end
        end

        closeLibs=true;
        model=topModel;
    else
        allCaps=[];
    end

    if isempty(allCaps)
        disp(DAStudio.message('Simulink:bcst:NoDataFound',regexprep(model,'\s',' ')));
        return;
    end

    if nargin>=2&&do_unknown
        show_unknown=true;
    else
        show_unknown=false;
    end

    h=bcstMakeHtmlTable(model,allCaps,show_unknown,libData);

    if closeLibs
        for libIdx=1:length(libData.current)
            if libData.open(libIdx)
                close_system(libData.current{libIdx},0);
            end
        end
    end

    if true
        hfile=['text://',h];






    end

    status=web(hfile,'-new');

    switch status
    case 1
        errordlg(DAStudio.message('Simulink:bcst:ErrNoBrowser'));
    case 2
        errordlg(DAStudio.message('Simulink:bcst:ErrNoBrowserLaunch'));
    otherwise

    end

end
