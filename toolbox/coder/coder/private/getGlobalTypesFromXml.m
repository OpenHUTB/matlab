

function[nGtcs,gtcs]=getGlobalTypesFromXml(xmlParamGlobals,emlFeatureControl)
    [xGlobalVar,idpTable]=coder.internal.gui.GuiUtils.getInputDataReader(xmlParamGlobals);
    nGtcs=0;
    gtcs={};

    while xGlobalVar.isPresent()
        gtc=loadProjectGlobal(xGlobalVar,emlFeatureControl,idpTable);
        nGtcs=nGtcs+1;
        gtcs{nGtcs}=gtc;%#ok<AGROW>
        xGlobalVar=xGlobalVar.next();
    end
end


function type=loadProjectGlobal(xGlobalVar,emlFeatureControl,idpTable)
    globalName=char(xGlobalVar.readAttribute('Name'));
    type=xml2type(emlFeatureControl,xGlobalVar,globalName,globalName,idpTable);
    if~isempty(type.ValueConstructor)
        if isa(type,'coder.Constant')
            gType=coder.typeof(type.Value);
            gType.Name=globalName;
            gType.InitialValue=type;
            type=gType;
        elseif~type.contains(type.InitialValue)
            msgId='Coder:configSet:GlobalInitialValueTypeMismatch';
            ccdiagnosticid(msgId,globalName);
        end
    end
end