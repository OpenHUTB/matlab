function h=libraryBrowser






    h=Simulink.slx.PartHandler(i_id,'blockDiagram',@i_load,@i_save);

end

function i_load(modelHandle,loadOptions)
    if~bdIsLibrary(modelHandle)
        return;
    end
    prmValue='off';


    if loadOptions.readerHandle.hasPart(i_xmlpartname)||loadOptions.readerHandle.hasPart(i_rpspartname)
        prmValue='on';
    end
    set_param(modelHandle,'EnableLBRepository',prmValue);
end

function i_save(modelHandle,saveOptions)
    if~bdIsLibrary(modelHandle)


        return;
    end




    if strcmpi(get_param(modelHandle,'EnableLBRepository'),'off')
        i_deleteParts(saveOptions);
        i_deleteRPS(saveOptions);
        return;
    end

    if saveOptions.isExportingToReleaseOrOlder('R2014a')



        i_deleteParts(saveOptions);
        i_deleteRPS(saveOptions);
        return;
    end

    targetRelease=saveOptions.targetRelease;
    if~isempty(targetRelease)
        targetRelease=saveas_version(targetRelease);
    end
    rg=LibraryBrowser.internal.RepositoryGenerator(modelHandle,targetRelease);
    rg.generate;

    if isempty(rg.mRepositoryFiles)
        i_deleteParts(saveOptions);
        i_deleteRPS(saveOptions);
        return;
    end

    if saveOptions.isExportingToReleaseOrOlder('R2015b')
        i_deleteParts(saveOptions);
        i_createRPS(modelHandle,saveOptions,rg.mRepositoryFiles);
    else
        i_writeParts(saveOptions,rg.mRepositoryFiles);
    end
end


function partprefix=i_partprefix
    partprefix='/simulink/libraryBrowser/';
end

function partname=i_xmlpartname
    partname=[i_partprefix,'slLibraryBrowser.xml'];
end

function partname=i_rpspartname
    partname='/metadata/slLibraryBrowser.rps';
end

function id=i_id
    id='slLibraryBrowser';
end

function p=i_partinfo_xml
    relationship_type=...
    'http://schemas.mathworks.com/simulink/2015/relationships/slLibraryBrowser';
    content_type='application/vnd.mathworks.simulink.libraryBrowserRepository+xml';
    p=Simulink.loadsave.SLXPartDefinition([i_partprefix,'slLibraryBrowser.xml'],...
    '/simulink/blockdiagram.xml',...
    content_type,...
    relationship_type,...
    i_id);
end

function p=i_partinfo_svg(suffix)
    relationship_type=...
    'http://schemas.mathworks.com/simulink/2015/relationships/slLibraryBrowserImage';
    if ispc
        suffix=strrep(suffix,filesep,'/');
    end

    content_type='image/svg+xml';



    p=Simulink.loadsave.SLXPartDefinition([i_partprefix,suffix],...
    '/simulink/libraryBrowser/slLibraryBrowser.xml',...
    content_type,...
    relationship_type,...
    '');
end

function i_deleteParts(saveOptions)
    writer=saveOptions.writerHandle;
    existing_parts=writer.getMatchingPartDefinitions(i_partprefix);
    for i=1:numel(existing_parts)
        writer.deletePart(existing_parts(i));
    end
end

function i_writeParts(saveOptions,files)



    xmlfile=files{end};
    assert(strcmp(xmlfile(end-3:end),'.xml'))

    folder=fileparts(xmlfile);
    writer=saveOptions.writerHandle;

    xml_partdef=i_partinfo_xml;
    existing_parts=writer.getMatchingPartDefinitions(i_partprefix);
    new_parts=cell(size(files));
    new_parts{end}=xml_partdef.name;

    writer.writePartFromFile(xml_partdef,slfullfile(folder,'slLibraryBrowser.xml'));


    n=numel(folder)+2;
    for i=1:numel(files)-1
        f=files{i};
        suffix=f(n:end);
        assert(strcmp(suffix(end-3:end),'.svg'))
        partinfo=i_partinfo_svg(suffix);
        writer.writePartFromFile(partinfo,f);
        new_parts{i}=partinfo.name;
    end

    [~,parts_to_delete]=setdiff(lower({existing_parts.name}),lower(new_parts));
    for i=1:numel(parts_to_delete)
        saveOptions.writerHandle.deletePart(existing_parts(parts_to_delete(i)))
    end
    i_deleteRPS(saveOptions);
end

function i_deleteRPS(saveOptions)
    writer=saveOptions.writerHandle;
    rps_part=writer.getMatchingPartDefinitions(i_rpspartname);
    if~isempty(rps_part)
        writer.deletePart(rps_part);
    end
end

function i_createRPS(modelHandle,saveOptions,files)

    partname='/metadata/slLibraryBrowser.rps';
    rpsfilename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,partname);


    xmlfile=files{end};
    assert(strcmp(xmlfile(end-3:end),'.xml'))
    folder=fileparts(xmlfile);

    n=numel(folder)+2;
    for i=1:numel(files)
        f=files{i};
        files{i}=f(n:end);
    end

    zip(rpsfilename,files,folder);


    movefile([rpsfilename,'.zip'],rpsfilename);
    relationship_type=...
    'http://schemas.mathworks.com/simulink/2013/relationships/slLibraryBrowser';
    content_type='application/zip+rps';
    partinfo=Simulink.loadsave.SLXPartDefinition(partname,...
    '/simulink/blockdiagram.xml',...
    content_type,...
    relationship_type,...
    'slLibraryBrowser');
    saveOptions.writerHandle.writePartFromFile(partinfo,rpsfilename);
end

