function h=interfaceDefinition




    if(slfeature('SlInterfacePort')>0)
        h=Simulink.slx.PartHandler('interfaceDefinition','blockDiagram',@i_load,@i_save);
    else
        h=[];
    end
end

function i_load(modelHandle,loadOptions)
    unpacked=get_param(modelHandle,'UnpackedLocation');
    assert(~isempty(unpacked));

    parts=loadOptions.readerHandle.getMatchingPartNames(i_folder);


    templateModel=InterfaceEditor.Model();
    for i=1:numel(parts)
        pInterfaceLoadCallback(modelHandle,saveOptions,parts{i},...
        @Simulink.BlockDiagram.Internal.addInterfaceGraphicalDictionary,...
        templateModel);
    end
end

function i_save(modelHandle,saveOptions)
    modelName=get_param(modelHandle,'Name');
    intfGrp=Simulink.BlockDiagram.Internal.getInterfaceGraphicalDictionary(modelName);

    parts=i_parts(modelHandle,intfGrp);

    for i=1:length(intfGrp)
        pInterfaceSaveCallback(modelHandle,saveOptions,parts(i),...
        @Simulink.BlockDiagram.Internal.getInterfaceGraphicalDictionary);
    end

end

function parts=i_parts(modelHandle,varargin)

    if isnumeric(varargin{1})

        intfGrp={};
        numParts=varargin{1};
    else


        intfGrp=varargin{1};
        numParts=length(intfGrp);
    end

    origId='interfaceDefinition';
    origNameStrings=cell(numParts,1);


    for i=1:numParts
        origNameStrings{i}='interfaceDefinition';
    end

    partnames=genvarname(origNameStrings);

    parts=Simulink.loadsave.SLXPartDefinition.empty;
    for i=1:numParts

        name=[i_folder,partnames{i},'.xml'];
        id=[origId,num2str(i)];
        contentType='application/vnd.mathworks.simulink.systemarchitecture.views.interfaceDefinition.xml+xml';

        fragment=[];
        if~isempty(intfGrp)
            fragment=getUUID(modelHandle);
        end
        reltype=i_reltype(fragment);
        parts(i)=Simulink.loadsave.SLXPartDefinition(name,'',contentType,reltype,id);
    end
end

function reltype=i_reltype(fragment)
    reltype=['http://schemas.mathworks.com/'...
    ,'simulinkModel/2012/relationships/systemArchitecture/views/interfaceDefinition'];
    if~isempty(fragment)
        reltype=[reltype,'/element?uuid=',fragment];
    end
end

function folder=i_folder
    folder='/simulink/systemArchitecture/views/';
end

function uuid=getUUID(modelHandle)
    unpacked=get_param(modelHandle,'UnpackedLocation');
    currDir=pwd;
    cd(unpacked);




    uuid='1';
    cd(currDir);
end
