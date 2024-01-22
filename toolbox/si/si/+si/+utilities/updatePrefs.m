function updatePrefs
    siFolder=fullfile(prefdir,'si_toolbox_shared');
    if isfolder(siFolder)

        return
    end

    [prefParent,rel,~]=fileparts(prefdir);
    yearRel=reldata(rel);
    yearRel=previousRel(yearRel);
    while yearRel>2021.0
        strRel=rel2str(yearRel);
        previousPref=fullfile(prefParent,strRel,'si_toolbox_shared');
        if isfolder(previousPref)
            copyfile(previousPref,siFolder)
            return
        end
        yearRel=previousRel(yearRel);
    end


    function relStr=rel2str(yearRel)

        if mod(yearRel,1)==0
            aOrb='a';
        else
            aOrb='b';
        end
        relStr=['R',num2str(floor(yearRel)),aOrb];
    end


    function yearRel=reldata(rel)
        yearRel=2021.0;
        if rel(1)~='R'
            return;
        end
        yearStr=rel(2:5);
        tYear=str2double(yearStr);
        if isnan(tYear)

            return
        end
        if mod(tYear,1)~=0

            return;
        end
        aorb=rel(6);
        if aorb~='a'&&aorb~='b'
            return
        end
        isbrelease=aorb=='b';
        yearRel=tYear;
        if isbrelease
            yearRel=yearRel+0.1;
        end
    end
    function rel=previousRel(rel)

        if mod(rel,1)==0
            rel=rel-0.9;
        else
            rel=floor(rel);
        end
    end
end

