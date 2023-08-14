function privateupdatelibrary(libtype)
















    try
        updateLibrary(libtype);
    catch exception
        warning(message('SimBiology:privateupdatelibrary:SB_ROOT_LIBRARY_MAY_BE_OUT_OF_SYNC',...
        libtype,exception.getReport));
    end
end

function updateLibrary(libtype)

    persistent simbio_ver
    if isempty(simbio_ver)
        simbio_ver=ver('simbio');
    end


    if~ischar(libtype)
        error(message('SimBiology:privateupdatelibrary:INVALIDLIBTYPE'));
    end


    rootobj=SimBiology.Root.getroot;

    switch libtype
    case 'kineticlaw'
        basename='userdefkinlaws.sbklib';

        variableData={rootobj.UserDefinedLibrary.KineticLaws};
        variableNames={'mw_aklarray'};
    case 'unit'
        basename='userdefunits.sbulib';

        variableData={rootobj.UserDefinedLibrary.Units,rootobj.UserDefinedLibrary.UnitPrefixes};
        variableNames={'mw_unitarray','mw_prefixarray'};
    otherwise
        error(message('SimBiology:privateupdatelibrary:INVALIDLIBTYPE'));
    end



    saveStruct=struct;
    variableNames{end+1}='simbio_ver';
    variableData{end+1}=simbio_ver;
    for i=1:numel(variableNames)
        saveStruct.(variableNames{i})=variableData{i};
    end





    tempfile=[tempname,'.mat'];

    save('-mat','-V7',tempfile,'-struct','saveStruct',variableNames{:});


    simbioprefdir=fullfile(prefdir,'SimBiology');
    if~exist(simbioprefdir,'dir')
        mkdir(simbioprefdir);
    end

    libfile=fullfile(simbioprefdir,basename);
    [status,msg]=robustMovefile(tempfile,libfile);
    if~status



        error(message('SimBiology:privateupdatelibrary:MOVEFILE_FAILED',libfile,tempfile,msg));
    end
end

function[status,msg]=robustMovefile(src,dest)


    [status,msg]=movefile(src,dest,'f');
    if~status
        pause(rand/10);
        [status,msg]=movefile(src,dest,'f');
    end
end