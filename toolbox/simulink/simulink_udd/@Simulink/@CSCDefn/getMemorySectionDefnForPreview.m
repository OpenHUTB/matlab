function msdefn=getMemorySectionDefnForPreview(cscdefn,hUI)




    msdefn=[];
    msName=cscdefn.MemorySection;


    for i=1:length(hUI.AllDefns{2})
        tmpDefn=hUI.AllDefns{2}(i);
        if isequal(tmpDefn.Name,msName)
            msdefn=tmpDefn;
            break;
        end
    end


    if isempty(msdefn)
        msdefn=processcsc('GetMemorySectionDefn',cscdefn.OwnerPackage,msName);
    end

    if~isempty(msdefn)
        msdefn=msdefn.getMemorySectionDefnForPreview(hUI);
    end


