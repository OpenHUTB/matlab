function result=isequal(element1,element2)






    result=false;
    if isa(element1,'ModelAdvisor.FormatTemplate')&&isa(element2,'ModelAdvisor.FormatTemplate')
        if length(element1)~=length(element2)
            return;
        end
        for idx=1:length(element1)
            result=strcmp(element1(idx).emitContent.emitHTML,element2(idx).emitContent.emitHTML);
            if~result
                break;
            end
        end
    end
