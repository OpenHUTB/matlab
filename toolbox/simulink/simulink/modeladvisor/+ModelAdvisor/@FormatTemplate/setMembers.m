
function setMembers(this,inputParam)




    for inx=1:2:length(inputParam)

        if(isprop(this,inputParam{inx})==0)

        else
            if(strcmp(inputParam{inx},'SubResultStatus'))
                setSubResultStatus(this,inputParam{inx+1});
            elseif(strcmp(inputParam{inx},'SubTitle'))
                setSubTitle(this,inputParam{inx+1});
            elseif(strcmp(inputParam{inx},'FormatType'))
                setFormatType(this,inputParam{inx+1});
            elseif(strcmp(inputParam{inx},'RefLink'))
                setRefLink(this,inputParam{inx+1});
            elseif(strcmp(inputParam{inx},'Information'))
                setInformation(this,inputParam{inx+1});
            elseif(strcmp(inputParam{inx},'ListObj'))
                setListObj(this,inputParam{inx+1});
            elseif(strcmp(inputParam{inx},'RecAction'))
                setRecAction(this,inputParam{inx+1});
            elseif(strcmp(inputParam{inx},'TableInfo'))
                setTableInfo(this,inputParam{inx+1});
            elseif(strcmp(inputParam{inx},'ColTitles'))
                setColTitles(this,inputParam{inx+1});
            elseif(strcmp(inputParam{inx},'TableTitle'))
                setTableTitle(this,inputParam{inx+1});
            elseif(strcmp(inputParam{inx},'CheckText'))
                setCheckText(this,inputParam{inx+1});
            elseif(strcmp(inputParam{inx},'SubBar'))
                setSubBar(this,inputParam{inx+1});

            end
        end
    end
end
