function migrateXmlOptions(srcM3IModel,dstM3IModel,clearXmlOptionsInSrcModel)




    import autosar.mm.util.XmlOptionsAdapter;

    srcARRoot=srcM3IModel.RootPackage.front();
    dstARRoot=dstM3IModel.RootPackage.front();


    m3iPropSeq=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(srcARRoot,false);
    for ii=1:m3iPropSeq.size()
        m3iPropName=m3iPropSeq.at(ii).name;
        if any(strcmp(m3iPropName,{'ArxmlFilePackaging','Domain','Name'}))
            continue
        end

        if isempty(dstARRoot.(m3iPropName))
            dstARRoot.(m3iPropName)=srcARRoot.(m3iPropName);
        end



        if clearXmlOptionsInSrcModel
            srcARRoot.(m3iPropName)='';
        end
    end


    propertyNames=XmlOptionsAdapter.getValidProperties();
    for propIdx=1:length(propertyNames)
        propertyName=propertyNames{propIdx};
        if any(strcmp(propertyName,XmlOptionsAdapter.ComponentSpecificXmlOptions))

            continue;
        end


        dstValue=XmlOptionsAdapter.get(dstARRoot,propertyName,false);
        if isempty(dstValue)
            srcValue=XmlOptionsAdapter.get(srcARRoot,propertyName,false);
            if~isempty(srcValue)
                XmlOptionsAdapter.set(dstARRoot,propertyName,srcValue);
            end
        end
    end
