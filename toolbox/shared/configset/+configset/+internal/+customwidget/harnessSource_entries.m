function[out,dscr]=harnessSource_entries(cs,name)




    dscr=[name,'''enum harness source option based on feature flag'];
    owner=cs.getPropOwner(name);
    m=findprop(owner,name);
    types=findtype(m.DataType);

    values=types.Strings;
    testSeqIdx=strcmpi('Test Sequence',values);

    if~slavteng('feature','ExportToTestSequence')...
        ||~Simulink.harness.internal.isInstalled()...
        ||~Simulink.harness.internal.licenseTest()

        values(testSeqIdx)=[];
    end

    avail_vals=cell(1,length(values));
    for i=1:length(values)
        avail_vals{i}.str=values{i};
    end

    out=cell2mat(avail_vals);
end
