function diff=compare_components(componentA,componentB)






































    if nargin~=2
        DAStudio.error('Simulink:modelReference:compareComponentsIncorrectNumberOfArguments');
    end


    diff=struct('Type','','Compatible',true,'Differences','','Components','');
    diff.Differences=struct('Property',{},'ValueA',{},'ValueB',{});
    diff.Components=struct('Type','','Compatible',{},'Differences',{},'Components',{});



    if~isequal(class(componentA),class(componentB))
        diff.Compatible=false;
        return;
    end

    diff.Type=class(componentA);
    afields=componentA.fields;
    bfields=componentB.fields;

    if(length(afields)~=length(bfields))
        diff.Compatible=false;
        return;
    end


    for i=1:length(afields)
        afield=componentA.get(afields{i});
        bfield=componentB.get(bfields{i});
        if isa(afield,'Simulink.BaseConfig')
            isEqual=eq(afield,bfield);
        else
            isEqual=isequal(afield,bfield);
        end

        if~isEqual
            compdiff.Property=afields{i};
            compdiff.ValueA=afield;
            compdiff.ValueB=bfield;
            diff.Differences(end+1)=compdiff;
        end
    end



    if(length(componentA.Components)~=length(componentB.Components))
        diff.Compatible=false;
        return;
    else
        for i=1:length(componentA.Components)
            subDiff=compare_components(componentA.Components(i),componentB.Components(i));
            diff.Components(i)=subDiff;
        end
    end


