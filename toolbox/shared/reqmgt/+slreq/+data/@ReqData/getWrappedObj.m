function dataObj=getWrappedObj(modelObj)







    objType=class(modelObj);
    if any(strcmp(objType,{...
        'slreq.datamodel.RequirementSet',...
        'slreq.datamodel.LinkSet',...
        'slreq.datamodel.LinkableItem',...
        'slreq.datamodel.Link',...
        'slreq.datamodel.ExternalRequirement',...
        'slreq.datamodel.MwRequirement',...
        'slreq.datamodel.Justification',...
        'slreq.datamodel.Comment',...
        'slreq.datamodel.TextItem',...
        'slreq.datamodel.TextRange',...
        'slreq.datamodel.Connector',...
        'slreq.datamodel.Markup',...
        }))
        dataObj=slreq.data.ReqData.getInstance.wrap(modelObj);
    else
        error('slreq.data.ReqData.getWrappedObj(): can''t wrap type %s',objType);
    end
end
