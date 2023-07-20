function GenerateRenamedTop(obj,tname)



    dFile=StringWriter();
    sFile=StringWriter();
    readfile(sFile,fullfile(obj.data.fpath,[obj.data.fname,obj.data.fext]));

    replaced=false;
    functionfound=false;

    for i=1:numel(sFile.cellstr)
        tline=sFile.cellstr{i};

        if~isempty(tline)&&~replaced
            C=textscan(tline,'%s','CommentStyle','%','Delimiter','\n\t\b, .=;()[]');
            words=cellstr(C{1});
            words=words(~cellfun('isempty',words));
        else
            words=[];
        end
        if numel(words)>=1
            if(strcmp(words{1},'function'))
                functionfound=true;
            end
            if functionfound
                index=strfind(tline,obj.data.TopFunctionName);
                sline='';
                sidx=1;
                for y=1:numel(index)
                    leftdelim=true;
                    rightdelim=true;
                    lidx=index(y)-1;
                    if lidx>0
                        if any(strfind(['a':'z','A':'Z','0':'9','_'],tline(lidx)))



                            leftdelim=false;
                        end
                    end
                    ridx=index(y)+length(obj.data.TopFunctionName);
                    if ridx<=length(tline)
                        if any(strfind(['a':'z','A':'Z','0':'9','_'],tline(ridx)))



                            rightdelim=false;
                        end
                    end
                    if leftdelim&&rightdelim
                        sline=[sline,tline(sidx:index(y)-1),tname];%#ok<AGROW>
                        replaced=true;
                    else



                        sline=[sline,tline(sidx:ridx-1)];%#ok<AGROW>
                    end
                    sidx=ridx;
                end
                sline=[sline,tline(sidx:end)];%#ok<AGROW>
            else



                sline=tline;
            end
        else
            sline=tline;
        end
        dFile.addcr(sline);
    end


    write(dFile,fullfile(obj.data.workdirectory,[tname,obj.data.fext]));

end

