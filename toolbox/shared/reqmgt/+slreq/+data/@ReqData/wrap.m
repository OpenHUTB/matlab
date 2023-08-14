function out=wrap(this,in)












    if~isempty(in.tag)
        out=in.tag;
        return;
    end

    switch class(in)
    case 'slreq.datamodel.LinkSet'
        out=slreq.data.LinkSet(in);
        in.tag=out;

    case 'slreq.datamodel.Link'
        out=slreq.data.Link(in);
        in.tag=out;

    case 'slreq.datamodel.RequirementSet'
        out=slreq.data.RequirementSet(in);
        in.tag=out;

    case 'slreq.datamodel.MwRequirement'
        out=slreq.data.Requirement(in);
        in.tag=out;

    case 'slreq.datamodel.ExternalRequirement'
        out=slreq.data.Requirement(in);
        in.tag=out;

    case 'slreq.datamodel.Justification'
        out=slreq.data.Requirement(in);
        in.tag=out;

    case 'slreq.datamodel.Comment'
        out=slreq.data.Comment(in);
        in.tag=out;

    case 'slreq.datamodel.Markup'
        out=slreq.data.Markup(in);
        in.tag=out;

    case 'slreq.datamodel.Connector'
        out=slreq.data.Connector(in);
        in.tag=out;

    case 'slreq.datamodel.TextItem'
        out=slreq.data.TextItem(in);
        in.tag=out;

    case 'slreq.datamodel.TextRange'
        out=slreq.data.TextRange(in);
        in.tag=out;

    case 'slreq.datamodel.LinkableItem'
        out=slreq.data.SourceItem(in);
        in.tag=out;

    otherwise
        out=slreq.data.DataModelObj.empty();



    end


    slreq.utils.assertValid(out);
end
