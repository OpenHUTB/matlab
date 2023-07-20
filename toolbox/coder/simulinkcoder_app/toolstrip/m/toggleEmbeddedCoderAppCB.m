function toggleEmbeddedCoderAppCB(cbinfo)







    ed=cbinfo.EventData;
    if isempty(ed)
        st=true;
    elseif isnumeric(ed)||islogical(ed)
        st=ed;
    elseif ischar(ed)
        st=true;
    end
    if(st)
        simulinkcoder.internal.toolstrip.util.checkUseCoderFeatures(cbinfo,'UseEmbeddedCoderFeatures')
    end
    coder.internal.toolstrip.CoderAppContext.toggleCoderApp(cbinfo,'embeddedCoderApp',true);
end


