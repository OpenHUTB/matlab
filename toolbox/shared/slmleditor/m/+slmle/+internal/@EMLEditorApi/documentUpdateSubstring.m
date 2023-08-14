function bool=documentUpdateSubstring(obj,id,newStartPos,newEndPos,newString)




    bool=false;

    if obj.logger
        disp(mfilename);
    end

    m=slmle.internal.slmlemgr.getInstance;
    mlfbEds=m.getMLFBEditorsFromAllStudios(id);
    if isempty(mlfbEds)
        return;
    end


    ed=mlfbEds{1};

    if~isempty(ed)




        if~newEndPos==0


            newScript=[ed.Text(1:newStartPos-1),newString,ed.Text(newEndPos+1:end)];
            ed.Text=newScript;
            return;
        end

        ed.selectText(newStartPos-1,newEndPos);
        ed.insertText(newString);

        bool=true;
    end
end
