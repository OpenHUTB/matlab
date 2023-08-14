function TflNameList=getTflNameList(lTargetRegistry,varargin)






    refreshCRL(lTargetRegistry);

    SimTflList={};
    nonSimTflList={};
    rtwCompTflList={};
    TflNameList={};

    if nargin>3
        DAStudio.error('RTW:tfl:invalidNumOfInput');
    elseif nargin==1
        group='nonSim';
    elseif nargin==2
        group=varargin{1};
        hSrc=0;
    elseif nargin==3
        group=varargin{1};
        hSrc=varargin{2};
    end


    libs=lTargetRegistry.TargetFunctionLibraries;
    for i=1:length(libs)
        Tfl=libs(i);
        if Tfl.IsSimTfl
            SimTflList=[SimTflList;Tfl.Name];%#ok<AGROW>
        else
            if Tfl.IsVisible
                if Tfl.isCompliantWithTargetLang(hSrc)
                    nonSimTflList=[nonSimTflList;Tfl.Name];%#ok<AGROW>
                end
            end
        end

        if~Tfl.IsERTOnly
            rtwCompTflList=[rtwCompTflList;Tfl.Name];%#ok<AGROW>
        end
    end



    filter=isprop(hSrc,'IsERTTarget')||isfield(hSrc,'IsERTTarget');
    if filter


        isERTTarget=hSrc.IsERTTarget;
        switch class(isERTTarget)
        case 'char'
            filter=strcmp(isERTTarget,'off');
        otherwise
            filter=~logical(isERTTarget);
        end
    end
    if filter
        switch lower(group)
        case 'nonsim'
            [~,Ia]=intersect(rtwCompTflList,nonSimTflList);
            sIa=sort(Ia);
            TflNameList=rtwCompTflList(sIa);
        case 'sim'
            [~,Ia]=intersect(rtwCompTflList,SimTflList);
            sIa=sort(Ia);
            TflNameList=rtwCompTflList(sIa);
        case 'all'
            [~,Ia]=intersect(rtwCompTflList,[nonSimTflList;SimTflList]);
            sIa=sort(Ia);
            TflNameList=rtwCompTflList(sIa);
        end
    else
        switch lower(group)
        case 'nonsim'
            TflNameList=nonSimTflList;
        case 'sim'
            TflNameList=SimTflList;
        case 'all'
            TflNameList=[nonSimTflList;SimTflList];
        end
    end


