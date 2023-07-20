function browseTLCFiles(h)



    systlcFile=[];

    warningState=[warning;warning('query','backtrace')];
    warning off backtrace;
    warning on;%#ok<WNON>
    errmsg=[];
    try
        systlcFile=systlc_browse(matlabroot,path);
    catch me
        errmsg=me.message;
    end

    warning(warningState);%#ok<WNTAG>

    if(~isempty(errmsg))
        errmsg=['Error occurred while scanning for system target files: ',errmsg];
        errordlg(errmsg,'Error','modal');
        return;
    end


    set(h,'tlcfiles',systlcFile);

    tlcList=[];

    idx=0;
    width=h.column1Width;
    if~isempty(systlcFile)
        for i=1:length(systlcFile)
            if~systlcFile(i).isObsolete
                idx=idx+1;
                sp={};
                sp(1:max(1,(width-length(systlcFile(i).shortName))))={'&nbsp;'};
                space_string=[sp{:}];
                tlcList{idx}=[systlcFile(i).shortName,space_string...
                ,systlcFile(i).description];%#ok<AGROW>
            end
        end
    end

    set(h,'tlclist',tlcList);
