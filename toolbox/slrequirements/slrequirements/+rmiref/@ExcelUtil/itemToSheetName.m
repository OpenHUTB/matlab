function sheet=itemToSheetName(item_name)




    sheet='';
    location=item_name.Value;



    if~isempty(location)
        left_cut=strfind(location,'=');
        if~isempty(left_cut)&&left_cut(1)==1
            right_cut=strfind(location,'!');
            if~isempty(right_cut)&&right_cut(end)>left_cut+1
                sheet=location(left_cut+1:right_cut-1);
                if sheet(1)==''''&&sheet(end)==''''&&length(sheet)>2
                    sheet=sheet(2:end-1);
                end

                sheet=strrep(sheet,'''''','''');
            end
        end
    end
end
