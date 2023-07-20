function inuse=variableInUse(refname)








    inuse=com.mathworks.mlservices.MLArrayEditorServices.isEditable(refname);
    if~inuse

        codes=com.mathworks.comparisons.compare.concr.VariableComparison.getComparisonCodes.iterator;
        nameprop=com.mathworks.comparisons.source.property.CSPropertyName.getInstance();
        while codes.hasNext
            comp=com.mathworks.comparisons.compare.concr.VariableComparison.getComparison(codes.next);


            source1=comp.getSource1;
            name1=char(source1.getPropertyValue(nameprop,[]));
            if strcmp(name1,refname)
                inuse=true;
                break;
            end
            source2=comp.getSource2;
            name2=char(source2.getPropertyValue(nameprop,[]));
            if strcmp(name2,refname)
                inuse=true;
                break;
            end
        end
    end
