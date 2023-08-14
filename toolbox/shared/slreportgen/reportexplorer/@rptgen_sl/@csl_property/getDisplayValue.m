function[dValue,dName]=getDisplayValue(h,dName)






    hGet=get(rptgen_sl.appdata_sl,['Current',h.ObjectType]);

    if isempty(hGet)
        error(message('RptgenSL:rsl_csl_property:noObjectLabel',h.ObjectType,dName));
    end






    isParentParagraph=false;
    if strcmp(h.ObjectType,'Annotation')

        parent=getParent(h);
        while~(isa(parent,'RptgenML.CReport')||isa(parent,'RptgenML.CForm'))
            if isa(parent,'rptgen.cfr_paragraph')
                isParentParagraph=true;
                h.status(getString(message('RptgenSL:rsl_csl_property:htmlFormattingMissingWarning')));
                break;
            else
                parent=getParent(parent);
            end
        end

    end

    [dValue,dName]=getPropValue(rptgen_sl.propsrc_sl,...
    hGet,dName,h.ObjectType,isParentParagraph);
    dValue=dValue{1};
