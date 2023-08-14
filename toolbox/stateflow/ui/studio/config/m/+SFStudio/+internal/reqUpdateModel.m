function reqUpdateModel(cbinfo)




    if isempty(cbinfo.referencedModel)
        SLM3I.SLDomain.updateDiagram(cbinfo.model.Handle);
    else
        SLM3I.SLDomain.updateDiagram(cbinfo.referencedModel.Handle);
    end
end
