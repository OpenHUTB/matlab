function mustBeMemberMessageID(propValue,ids)




%#codegen

    coder.allowpcode('plain');

    entries=getUSEnglishMessages(ids);

    if coder.target('MATLAB')
        lowerEntries=lower(entries);
    else

        lowerEntries=cell(size(entries));
        for n=coder.unroll(1:numel(entries))
            lowerEntries{n}=lower(entries{n});
        end
    end

    mustBeMember(lower(propValue),lowerEntries);
end

function entries=getUSEnglishMessages(ids)
    coder.extrinsic('matlab.system.internal.lookupMessageCatalogEntries');
    entries=coder.internal.const(matlab.system.internal.lookupMessageCatalogEntries(ids,true,'MustBeMember'));
end
