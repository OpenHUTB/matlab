function createJSONfileFromStruct(data,jsonFileName)



    try

        jsonStr=jsonencode(data);

        fid=fopen(jsonFileName,'w');
        tabs=0;
        dQuoteKVStringStarted=false;
        len=numel(jsonStr);
        for i=1:len
            c=jsonStr(i);

            if dQuoteKVStringStarted&&c~='"'
                if c=='\'
                    fprintf(fid,'\\');
                else
                    fprintf(fid,c);
                end
            else
                switch c
                case{'[','{'}
                    fprintf(fid,[c,'\n']);
                    tabs=tabs+1;
                    printTabs(fid,tabs);
                case{']','}'}
                    fprintf(fid,c);


                    if i<len&&contains(jsonStr(i+1),{']','}'})
                        fprintf(fid,'\n');
                        tabs=tabs-1;
                        printTabs(fid,tabs);
                    end
                case ':'
                    fprintf(fid,' : ');
                case '"'
                    fprintf(fid,c);
                    dQuoteKVStringStarted=~dQuoteKVStringStarted;
                    if contains(jsonStr(i+1),{']','}'})
                        fprintf(fid,'\n');
                        tabs=tabs-1;
                        printTabs(fid,tabs);
                    end
                case ','
                    fprintf(fid,[c,'\n']);
                    printTabs(fid,tabs);
                otherwise
                    fprintf(fid,c);
                    if contains(jsonStr(i+1),{']','}'})
                        fprintf(fid,'\n');
                        tabs=tabs-1;
                        printTabs(fid,tabs);
                    end
                end
            end
        end
        fclose(fid);
    catch
        error('Error while generating manifest file.');
    end
end

function printTabs(fid,n)
    for i=1:n
        fprintf(fid,'\t');
    end
end
