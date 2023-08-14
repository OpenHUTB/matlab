function[libMdls,libNames,libPaths,libIsTree,iconPaths]=getPaletteInfo(lib)






    libDb=PmSli.LibraryDatabase;
    libMdls=libDb.getLibraryNames(lib);
    numLibEntries=numel(libMdls);

    libPaths=cell(numLibEntries,1);
    iconPaths=cell(numLibEntries,1);
    libIsTree=cell(numLibEntries,1);
    if numLibEntries>0

        libEntries=libDb.getLibraryEntry(libMdls);

        libNames=get(libEntries,{'Descriptor'});


        for i=1:numLibEntries
            libPaths{i}=strcat(lib,'/',libNames{i});

            entry=libEntries(i);
            icon=entry.Icon.Display;
            tmp=strsplit(icon,{'imread(',')'});
            iconPaths{i}=eval(tmp{2});


            libMdl=libMdls{i};
            num=libDb.getLibraryNames(libMdl);
            if~isempty(num)
                num=numel(num);
                if num>0
                    libIsTree{i}=1;
                else
                    libIsTree{i}=0;
                end
            else

                libIsTree{i}=i_isTree(libMdl);
            end
        end
    end
end

function isTree=i_isTree(lib)
    isTree=true;

    slblocks=LibraryBrowser.internal.getSLBlocksFile(lib);
    if~isempty(slblocks)
        [~,~,isFlat,~,~,~,children,~,~]=LibraryBrowser.internal.getLibInfo(slblocks);
        if isFlat&&isempty(children)
            isTree=false;
            return;
        end
    end




    slx=which(lib);
    if~exist(slx,'file')
        return;
    end

    rps_partname='/metadata/slLibraryBrowser.rps';
    xml_partname='/simulink/libraryBrowser/slLibraryBrowser.xml';

    r=Simulink.loadsave.SLXPackageReader(slx);
    if r.hasPart(rps_partname)

        dir=tempname;
        mkdir(dir);
        cleanup=onCleanup(@()rmdir(dir,'s'));

        tmp_rps=fullfile(dir,'tmp.rps');
        r.readPartToFile(rps_partname,tmp_rps);
        unzip(tmp_rps,dir);
        delete(tmp_rps);
        xmlfile=fullfile(dir,'slLibraryBrowser.xml');
        isTree=i_readxml(xmlfile);
    elseif r.hasPart(xml_partname)
        xmlfile=[tempname,'.xml'];
        r.readPartToFile(xml_partname,xmlfile);
        cleanup=onCleanup(@()delete(xmlfile));
        isTree=i_readxml(xmlfile);
    end
end

function isTree=i_readxml(filename)

    xmlDoc=parseFile(matlab.io.xml.dom.Parser,filename);
    isTree=str2double(xmlDoc.getFirstChild.getAttribute('hasTree'));
end

