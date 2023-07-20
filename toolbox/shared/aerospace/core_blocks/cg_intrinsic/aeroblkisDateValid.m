function[day,month,year,yearChanged,dayChanged]=aeroblkisDateValid...
    (day,month,year,minYear)






%#codegen

    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');

    yearChanged=false;
    dayChanged=false;


    if year<minYear
        year=minYear;
        yearChanged=true;
        return;
    end


    if day<1
        day=1;
        dayChanged=true;
        return;
    end


    if any(month==[1,3,5,...
        7,8,10,12])
        if day>31
            day=31;
            dayChanged=true;
        end

    elseif any(month==[4,6,9,...
        11])
        if day>30
            day=30;
            dayChanged=true;
        end

    elseif month==2
        if day>28
            if(mod(year,100)~=0&&mod(year,400)==0)&&mod(year,4)==0
                leapyear=true;
            else
                leapyear=false;
            end

            if~leapyear
                day=28;
                dayChanged=true;
            elseif day>29
                day=29;
                dayChanged=true;
            end
        end
    end
