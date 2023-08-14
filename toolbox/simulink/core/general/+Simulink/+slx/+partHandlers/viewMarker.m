function h=viewMarker






    h=Simulink.slx.PartHandler(i_id,'blockDiagram',[],@i_save);

end

function i_save(modelHandle,saveOptions)
    if Simulink.harness.isHarnessBD(modelHandle)
        return;
    end

    if saveOptions.isExportingToReleaseOrOlder('R2014b')



        saveOptions.writerHandle.deletePart(DAStudio.Viewmarker.getPartInfoXML());
        return;
    end

    try

        xmlFileNameToModel=slfullfile(get_param(modelHandle,'UnpackedLocation'),'simulink','viewmarks','Simulink_ViewMark.xml');
        if isempty(Simulink.loadsave.resolveFile(xmlFileNameToModel))
            return;
        end

        saveOptions.writerHandle.writePartFromFile(DAStudio.Viewmarker.getPartInfoXML,xmlFileNameToModel);

        parser=matlab.io.xml.dom.Parser;
        xmlRootModel=parseFile(parser,xmlFileNameToModel);
        parentNode=xmlRootModel.getDocumentElement;
        nodeList=parentNode.getElementsByTagName('viewmark_node');

        for idx=0:nodeList.getLength-1
            node_element=nodeList.item(idx);
            svg=node_element.getElementsByTagName('viewmark_svg');
            svg_element=svg.item(0);
            svg_value=svg_element.TextContent;


            svg_part_info=DAStudio.Viewmarker.getPartInfoSVG(svg_value);
            filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,svg_part_info.name);
            saveOptions.writerHandle.writePartFromFile(svg_part_info,filename);
        end

        vmh=DAStudio.Viewmarker.getInstance;
        map=vmh.getSvgToDeleteInModel();
        modelname=get_param(modelHandle,'name');

        if~isempty(map)&&map.models.isKey(modelname)
            indices=map.models(modelname);
            if~isempty(indices)
                for i=1:length(indices)
                    value=map.svgsToDelete{indices{i}};
                    svg_part_info=DAStudio.Viewmarker.getPartInfoSVG(value.svg_value);
                    saveOptions.writerHandle.deletePart(svg_part_info);
                end
            end

            vmh.setSvgToDeleteInModel(modelname,'');
        end
    catch ME
        disp(['Exception caught in ViewMarker part handler:  ',get_param(modelHandle,'Name'),':   ',ME.message]);
        pathToRepository=slfullfile(get_param(modelHandle,'UnpackedLocation'),'simulink','viewmarks');
        i_cleanup(pathToRepository);
        rethrow(ME);
    end
end


function id=i_id
    id='slViewMarker';
end

function i_cleanup(path)

    if exist(path,'dir')
        rmdir(path,'s');
    end
end
