function h=ioLib






    h=Simulink.slx.PartHandler('iolib','blockDiagram',[],@i_save);

end

function i_save(modelHandle,saveOptions)

    if i_isIOLibrary(modelHandle)
        ioLibPart=i_iolib_partinfo;


        if saveOptions.isExportingToReleaseOrOlder('R2013b')
            saveOptions.writerHandle.deletePart(ioLibPart);
            return;
        end


        filename=i_create_iolibinfo(modelHandle);
        saveOptions.writerHandle.writePartFromFile(ioLibPart,filename);
    end
end


function flag=i_isIOLibrary(modelHandle)
    flag=false;
    if bdIsLibrary(modelHandle)
        libType=get_param(modelHandle,'LibraryType');
        if strcmpi(libType,'SSMgrViewerLibrary')||strcmpi(libType,'SSMgrGenLibrary')
            flag=true;
        end
    end
end


function id=i_iolib_partname
    id='/simulink/libinfo.mat';
end

function ioLibPart=i_iolib_partinfo



    parent='/simulink/blockdiagram.xml';



    name=i_iolib_partname();

    rel_type=['http://schemas.mathworks.com/'...
    ,'simulinkModel/2010/relationships/ioLibInfo'];




    id='IOLibInfo';

    content_type='application/vnd.mathworks.matlab.mat+binary';

    ioLibPart=Simulink.loadsave.SLXPartDefinition(name,parent,content_type,rel_type,id);
end

function filename=i_create_iolibinfo(modelHandle)


    libinfo=Simulink.scopes.ViewerUtil.GetLibInfoForIOLibrary(modelHandle);

    filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_iolib_partname);
    save(filename,'libinfo');
end
