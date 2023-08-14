function[libMdls,libNames,libPaths,libSubsystems,libIsTree,libIsTopLevel,libParents,libPaletteFcns]=findLibraryInfo(input)










    mlock;

    narginchk(0,1);

    libMdls=cell(0);
    libNames=cell(0);
    libPaths=cell(0);
    libSubsystems=cell(0);
    libIsTree=cell(0);
    libIsTopLevel=cell(0);
    libParents=cell(0);
    libPaletteFcns=cell(0);
    idx=0;
    j=0;


    isProduct=true;

    dir=LibraryBrowser.ReposDlg.getInstance().tempDir;

    persistent force;%#ok


    persistent libsChoicesMap;
    if isempty(libsChoicesMap)


        libsChoicesMap=containers.Map;
    end

    if nargin==0||iscell(input)
        if nargin==0

            files=union(which('-all','slblocks'),which('-all','SLBLOCKS'),'stable');
            files=files(cellfun('isempty',regexp(files,'\.p$')));
        else
            files=input;
        end


        LibraryBrowser.ReposDlg.getInstance().clearMissingList();



        nameLibsMap=containers.Map;
        newParentLibsMap=containers.Map;
        for i=1:length(files)

            slBlocksFile=files{i};
            [names,libs,isFlats,roots,types,choices,~,newParents,fcns]=LibraryBrowser.internal.getLibInfo(slBlocksFile);
            for j=1:length(names)
                path='';
                hasTree=-1;
                name=names{j};
                lib=libs{j};
                isFlat=isFlats(j);
                if isFlat>-1

                    hasTree=~(isFlat);



                end
                topLevel=all(roots);

                lib=strrep(lib,';','');
                type=types{j};
                choice=choices(j);
                newParent=newParents{j};
                fcn=fcns{j};
                if~isnumeric(choice)
                    if ischar(choice)||(isstring(choice)&&isscalar(choice))

                        choice=str2double(choice);
                    else



                        choice=-1;
                    end
                end
                try
                    if isempty(name)||isempty(lib)
                        continue;
                    end
                    if(strcmpi(type,'Palette'))
                        isProduct=false;


                        if hasTree<0


                            hasTree=1;
                        end
                        if~isempty(fcn)
                            if isa(fcn,'function_handle')
                                libPaletteFcns={fcn};
                            else
                                i_dispMException(lib,slBlocksFile);
                            end
                        else



                        end
                    else




                        if choice>-1
                            libsChoicesMap(lib)=choice;
                        end
                        path=i_retrieveReposInfo(dir,lib,libsChoicesMap);
                    end
                catch
                    continue;
                end


                if~isempty(path)||~isProduct


                    subsytem=lib;
                    if isempty(newParent)
                        nameLibsMap(name)={lib,path,subsytem,hasTree,topLevel,'',fcn};
                    else
                        newParentLibsMap(name)={lib,path,subsytem,hasTree,topLevel,newParent,fcn};
                    end
                end
            end
        end


        name='Simulink';
        if isKey(nameLibsMap,name)
            libValues=nameLibsMap(name);
            libNames={name};
            libMdls=libValues(1);
            libPaths=libValues(2);
            libSubsystems=libValues(3);
            libIsTree=libValues(4);
            libIsTopLevel=libValues(5);
            libParents=libValues(6);
            libPaletteFcns=libValues(7);
            remove(nameLibsMap,name);
            idx=1;
        end


        nameKeys=keys(nameLibsMap);
        for i=1:length(nameKeys)
            name=nameKeys{i};
            libValues=nameLibsMap(name);
            j=i+idx;
            libMdls{j}=libValues{1};
            libNames{j}=name;
            libPaths{j}=libValues{2};
            libSubsystems{j}=libValues{3};
            libIsTree{j}=libValues{4};
            libIsTopLevel{j}=libValues{5};
            libParents{j}=libValues{6};
            libPaletteFcns{j}=libValues{7};
        end


        idx=j;
        nameKeys=keys(newParentLibsMap);
        for i=1:length(nameKeys)
            name=nameKeys{i};
            libValues=newParentLibsMap(name);
            j=i+idx;
            libMdls{j}=libValues{1};
            libNames{j}=name;
            libPaths{j}=libValues{2};
            libSubsystems{j}=libValues{3};
            libIsTree{j}=libValues{4};
            libIsTopLevel{j}=libValues{5};
            libParents{j}=libValues{6};
            libPaletteFcns{j}=libValues{7};
        end
    else

        libMdl=strrep(input,';','');
        libMdls={libMdl};
        subsystem=libMdl;
        type='Product';
        valid=true;
        if exist(libMdl,'file')~=4&&~strcmpi(libMdl,'simulink')

            [lib,subsystem]=i_findLibraryAndSubsystem(libMdl);
            if isempty(subsystem)
                if isempty(lib)
                    valid=false;

                    libMdls=cell(0);
                else
                    subsystem=lib;
                end
            else
                subsystem=strrep(subsystem,char(10),'\n');
            end
        else
            lib=libMdl;
        end
        if valid
            libSubsystems={i_returnSubsystem(subsystem)};
            slBlocksFile=LibraryBrowser.internal.getSLBlocksFile(lib);
            if~isempty(slBlocksFile)
                [libName,~,isFlat,isTopLevel,type,~,~,~,libPaletteFcn]=LibraryBrowser.internal.getLibInfo(slBlocksFile);
                if isempty(isTopLevel)
                    isTopLevel=0;
                end
                libNames={libName};
                if isFlat>-1


                    libIsTree={~isFlat};
                else



                    libIsTree={-1};
                end
                libIsTopLevel={isTopLevel};
                libParents={''};
                libPaletteFcn=cell2mat(libPaletteFcn);
                libPaletteFcns={libPaletteFcn};
            end
            if(strcmpi(type,'Palette'))
                isProduct=false;


                libIsTree={1};
                if~isempty(libPaletteFcn)
                    if isa(libPaletteFcn,'function_handle')
                        libPaletteFcns={libPaletteFcn};
                    else
                        i_dispMException(lib,slBlocksFile);
                    end
                end
            end


            if isProduct
                path=i_retrieveReposInfo(dir,lib,libsChoicesMap);
                if~isempty(path)
                    libPaths={path};
                else


                    libNames=cell(0);
                    libMdls=cell(0);
                    libIsTree=cell(0);
                    libIsTopLevel=cell(0);
                    libParents=cell(0);
                    libPaletteFcns=cell(0);
                end
            end
        end
    end
end

function i_dispMException(libMdlName,slBlockFile)
    id='sl_lib_browse2:sl_lib_browse2:SLLB_InvalidFunctionHandle';
    disp(DAStudio.message(id,libMdlName,slBlockFile));






end

function subsystem=i_returnSubsystem(subsystem)
    if isempty(subsystem)
        subsystem='';
    end
end

function[varargout]=i_parseArgs(varargin)%#ok
    [varargout{1:nargin}]=varargin{:};
    i=nargin+1;
    while i<(nargout+1)
        varargout{i}=[];
        i=i+1;
    end
end

function[lib,subsystem]=i_findLibraryAndSubsystem(graphOpenFcn)
    lib=[];
    subsystem=[];
    functionmatch='load_open_subsystem';
    if isempty(strfind(graphOpenFcn,functionmatch))
        functionmatch='open_system';
        if isempty(strfind(graphOpenFcn,functionmatch))
            return;
        end
    end
    cmd=strrep(graphOpenFcn,functionmatch,'i_parseArgs');
    try
        [lib,subsystem]=eval(cmd);
    catch

    end
end



function path=i_retrieveReposInfo(dir,lib,libsChoicesMap)
    path=dir;

    if exist(lib,'file')==4||...
        strcmpi(lib,'simulink')
        try
            pathToDir=fullfile(dir,lib);


            attempt=1;

            reposPath=[];

            slxFile=LibraryBrowser.LibraryBrowserUtils.i_getSLXFile(lib);

            if~(exist(pathToDir,'file')==7)
                mkdir(pathToDir);
            end



            [slxFile,option,attempt]=i_validateFile(lib,slxFile,libsChoicesMap,attempt,'');


            if isempty(slxFile)
                path=[];
                return;
            elseif exist(slxFile,'file')~=7





                rpsFile=i_extractParts(slxFile,pathToDir);




                [rpsFile,option,~]=i_validateFile(lib,rpsFile,libsChoicesMap,attempt,pathToDir);
            else



                reposPath=slxFile;
            end





            if attempt&&~isempty(option)&&option==1
                if isempty(reposPath)
                    reposPath=rpsFile;
                end
                path=reposPath;
            elseif isempty(rpsFile)
                path=[];
            end
        catch E



            disp(E.message);
            path=[];
            return;
        end
    else
        path=[];
    end
end
function[fileOut,option,attempt]=i_validateFile(lib,fileIn,libsChoicesMap,attempt,pathIfRPS)
    fileOut='';
    option={};
    wasLoaded=bdIsLoaded(lib);

    force=[];

    if~isempty(force)||...
        ~(exist(fileIn,'file')==4||...
        exist(fileIn,'file')==2)
        if isempty(attempt)



            rps_option=1;
        else
            if attempt>1


                if~isempty(force)&&exist(fileIn,'file')==2
                    fileOut=fileIn;
                end
                return;
            end


            returnLibsList=false;
            if isKey(libsChoicesMap,lib)


                option=libsChoicesMap(lib);
                returnLibsList=true;
            else


                repos_dlg=LibraryBrowser.ReposDlg.getInstance();
                if repos_dlg.HasChoice
                    option=repos_dlg.Choice;
                else
                    option=LibraryBrowser.ReposDlg.SKIP;
                end


                repos_dlg.addToMissingList(lib);
            end
            attempt=attempt+1;




            if option==2
                return;
            end
            rps_option=option;
        end


        if~wasLoaded
            load_system(lib);
            closesys=onCleanup(@()close_system(lib,0));
        end
        libH=get_param(lib,'Handle');





        set_param(libH,'Lock','off');
        switch rps_option,
        case 0,





            slxFile=LibraryBrowser.LibraryBrowserUtils.saveAsSLX(lib,fileIn);



            if~isempty(pathIfRPS)
                fileOut=i_extractParts(slxFile,pathIfRPS);
            else
                fileOut=slxFile;
            end
        case 1,


            release='';
            [fileOut,~,libsList]=LibraryBrowser.internal.generateRepository(libH,release,false,returnLibsList);


            if~isempty(libsList)
                for i=1:length(libsList)
                    libsChoicesMap(libsList{i})=option;
                end
            end
        case 2,


        end
    else

        fileOut=fileIn;
    end
end

function xmlfile=i_extractParts(slxFile,folder)
    r=Simulink.loadsave.SLXPackageReader(slxFile);
    rps_partname='/metadata/slLibraryBrowser.rps';
    xml_partname='/simulink/libraryBrowser/slLibraryBrowser.xml';
    xmlfile='';
    if r.hasPart(rps_partname)
        tmp_rps=fullfile(folder,'tmp.rps');
        r.readPartToFile(rps_partname,tmp_rps);
        unzip(tmp_rps,folder);
        delete(tmp_rps);
        xmlfile=fullfile(folder,'slLibraryBrowser.xml');
    elseif r.hasPart(xml_partname)


        prefix='/simulink/libraryBrowser/';
        parts=r.getMatchingPartNames(prefix);
        prevdir='';
        s=filesep;
        if ispc
            rparts=strrep(parts,'/',s);
        else
            rparts=parts;
        end
        for i=1:numel(parts)
            p=rparts{i};
            suffix=p(numel(prefix)+1:end);
            f=[folder,s,suffix];
            j=find(f==s,1,'last');
            dir=f(1:j-1);
            if~strcmp(dir,prevdir)
                if~exist(dir,'dir')
                    mkdir(dir);
                end
                prevdir=dir;
            end
            r.readPartToFile(parts{i},f);
        end
        xmlfile=fullfile(folder,'slLibraryBrowser.xml');
    end
end
