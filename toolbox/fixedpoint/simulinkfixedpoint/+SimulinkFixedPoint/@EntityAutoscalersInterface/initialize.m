function initialize(this,filePath)





    import matlab.io.xml.dom.*

    files=which(filePath,'-all');
    for fileID=1:numel(files)
        xmlFile=files{fileID};
        xDoc=parseFile(Parser,xmlFile);
        root=xDoc.getDocumentElement;
        k=0;
        while(~isempty(root.item(k)))
            if strcmp(char(root.item(k).getNodeName),'map')

                maskName=char(root.item(k).getAttribute('mask'));


                className=char(root.item(k).getAttribute('class'));



                entityAutoscalerClassName=char(root.item(k).getAttribute('value'));



                keyForMap=[maskName,':',className];
                this.AutoscalerMap(keyForMap)=eval(entityAutoscalerClassName);
            end
            k=k+1;
        end
    end


    this.AutoscalersCell=this.AutoscalerMap.keys;
end
