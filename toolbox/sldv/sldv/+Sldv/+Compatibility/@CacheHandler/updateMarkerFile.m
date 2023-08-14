




function updateMarkerFile(obj,componentChecksum)
    componentName=obj.mCacheDirName;

    if~isfile(obj.mMarkerFileNameFull)
        obj.createMarkerFile();
    end


    import matlab.io.xml.dom.*

    xmlDoc=parseFile(Parser,obj.mMarkerFileNameFull);
    allComponents=xmlDoc.getElementsByTagName(obj.mMarkerNodeName_Component);
    dvoChecksum=componentChecksum.dvoChecksum;
    modelMapChecksum=componentChecksum.modelMapChecksum;

    if obj.mIsXIL&&slavteng('feature','SILReuseTranslation')
        xilDbCheckSum=componentChecksum.xilDBCheckSum;
    end


    hasChanged=false;
    for k=0:allComponents.getLength-1
        thisComponent=allComponents.item(k);
        thisName=thisComponent.getElementsByTagName(obj.mMarkerNodeName_ComponentName);
        thisName=thisName.item(0);
        if~isempty(thisName.getFirstChild)&&strcmp(thisName.getFirstChild.getData,componentName)
            thisChecksum=thisComponent.getElementsByTagName(obj.mMarkerNodeName_Checksum);
            thisChecksum=thisChecksum.item(0);


            thisDvoChecksum=thisChecksum.getElementsByTagName(obj.mMarkerNodeName_DVO);
            thisDvoChecksum=thisDvoChecksum.item(0);
            if isempty(thisDvoChecksum.getFirstChild)||~strcmp(thisDvoChecksum.getFirstChild.getData,dvoChecksum)
                hasChanged=true;
                thisDvoChecksum.getFirstChild.setData(dvoChecksum);
            end


            thisModelMapChecksum=thisChecksum.getElementsByTagName(obj.mMarkerNodeName_ModelMap);
            thisModelMapChecksum=thisModelMapChecksum.item(0);
            if isempty(thisModelMapChecksum.getFirstChild)||~strcmp(thisModelMapChecksum.getFirstChild.getData,modelMapChecksum)
                hasChanged=true;
                thisModelMapChecksum.getFirstChild.setData(modelMapChecksum);
            end


            if obj.mIsXIL&&slavteng('feature','SILReuseTranslation')
                thisxilDBChecksum=thisChecksum.getElementsByTagName(obj.mMarkerNodeName_xilDB);
                thisxilDBChecksum=thisxilDBChecksum.item(0);
                if isempty(thisxilDBChecksum.getFirstChild)||~strcmp(thisxilDBChecksum.getFirstChild.getData,xilDbCheckSum)
                    hasChanged=true;
                    thisxilDBChecksum.getFirstChild.setData(xilDbCheckSum);
                end
            end

            if hasChanged
                writeToFile(DOMWriter,xmlDoc,obj.mMarkerFileNameFull);
            end
            return;
        end
    end



    thisComponent=xmlDoc.createElement(obj.mMarkerNodeName_Component);
    thisName=thisComponent.appendChild(xmlDoc.createElement(obj.mMarkerNodeName_ComponentName));
    thisChecksum=thisComponent.appendChild(xmlDoc.createElement(obj.mMarkerNodeName_Checksum));
    thisDvoChecksum=thisChecksum.appendChild(xmlDoc.createElement(obj.mMarkerNodeName_DVO));
    thisModelMapChecksum=thisChecksum.appendChild(xmlDoc.createElement(obj.mMarkerNodeName_ModelMap));



    thisName.appendChild(xmlDoc.createTextNode(componentName));
    thisDvoChecksum.appendChild(xmlDoc.createTextNode(dvoChecksum));
    thisModelMapChecksum.appendChild(xmlDoc.createTextNode(modelMapChecksum));

    if obj.mIsXIL&&slavteng('feature','SILReuseTranslation')
        thisxilDBChecksum=thisChecksum.appendChild(xmlDoc.createElement(obj.mMarkerNodeName_xilDB));
        thisxilDBChecksum.appendChild(xmlDoc.createTextNode(xilDbCheckSum));
    end


    docRootNode=xmlDoc.getDocumentElement;
    docRootNode.appendChild(thisComponent);

    writeToFile(DOMWriter,xmlDoc,obj.mMarkerFileNameFull);
end
