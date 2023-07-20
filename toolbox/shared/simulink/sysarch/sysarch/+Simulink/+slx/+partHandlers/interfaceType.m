function h=interfaceType




    if(slfeature('SlInterfacePort')>0)
        h=Simulink.slx.PartHandler('interfaceType','blockDiagram',@i_load,@i_save);
    else
        h=[];
    end
end

function target=i_partname


    target='/simulink/systemArchitecture/semantic/interface.xml';
end

function p=i_partinfo


    parent='';


    target=i_partname;

    id='SlInterfaceType';

    relationship_type=['http://schemas.mathworks.com/'...
    ,'simulinkModel/2012/relationships/systemArchitecture/semantic/interface'];
    content_type='application/vnd.mathworks.simulink.systemarchitecture.semantic.interface.xml+xml';

    p=Simulink.loadsave.SLXPartDefinition(target,parent,content_type,relationship_type,id);
end

function i_load(modelHandle,loadOptions)

    if(slfeature('SlInterfacePort')>0)&&loadOptions.readerHandle.hasPart(i_partname)
        filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_partname);
        loadOptions.readerHandle.readPartToFile(i_partname,filename);








        Simulink.SystemArchitecture.ResolveSemanticDataForBd(modelHandle);
    end
end

function i_save(modelHandle,saveOptions)
    if(slfeature('SlInterfacePort')>0)


        pInterfaceSaveCallback(modelHandle,saveOptions,i_partinfo,...
        @Simulink.BlockDiagram.Internal.getInterfaceRepository);

    end
end


