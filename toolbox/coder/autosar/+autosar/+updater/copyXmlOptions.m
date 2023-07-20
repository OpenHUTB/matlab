function copyXmlOptions(oldM3IModel,newM3IModel,oldM3IComp,newM3IComp)




    import autosar.mm.util.XmlOptionsAdapter;


    copyComponentSpecificXmlOptions=(nargin>2);

    oldARRoot=oldM3IModel.RootPackage.front();
    newARRoot=newM3IModel.RootPackage.front();


    m3iPropSeq=Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes(oldARRoot,false);
    for ii=1:m3iPropSeq.size()
        m3iPropName=m3iPropSeq.at(ii).name;
        if strcmp(m3iPropName,'Domain')
            continue
        end

        newARRoot.(m3iPropName)=oldARRoot.(m3iPropName);
    end


    propertyNames=XmlOptionsAdapter.getValidProperties();
    for propIdx=1:length(propertyNames)
        propertyName=propertyNames{propIdx};
        if any(strcmp(propertyName,XmlOptionsAdapter.ComponentSpecificXmlOptions))
            if copyComponentSpecificXmlOptions
                value=XmlOptionsAdapter.get(oldM3IComp,propertyName);
                XmlOptionsAdapter.set(newM3IComp,propertyName,value);
            end
        else
            value=XmlOptionsAdapter.get(oldARRoot,propertyName);
            XmlOptionsAdapter.set(newARRoot,propertyName,value);
        end
    end
