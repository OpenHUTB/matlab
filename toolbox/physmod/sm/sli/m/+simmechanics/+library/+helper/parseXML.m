function theStruct=parseXML(filename)


    try
        fid=fopen(filename);
        if fid==-1
            error('Failed to read XML file %s.',filename);
        end
        theStruct=recursiveParse(fid);
        fclose(fid);
    catch excp
        if fid~=-1
            fclose(fid);
        end
        rethrow(excp);
    end

    function children=recursiveParse(fid)

        children=struct.empty(1,0);
        while~feof(fid)
            currLine=strip(fgetl(fid));
            if startsWith(currLine,'<table')
                while~endsWith(currLine,'>')
                    currLine=[currLine,' ',strip(fgetl(fid))];
                end
                children(end+1).Name='table';
                children(end).Attributes=getAttributes(currLine);
                children(end).Children=recursiveParse(fid);
            end

            if startsWith(currLine,'<message')
                while~endsWith(currLine,'</message>')
                    currLine=[currLine,' ',strip(fgetl(fid))];
                end
                msgStruct=getMessage(currLine);
                children(end+1).Name=msgStruct.Name;
                children(end).Attributes=msgStruct.Attributes;
                children(end).Children=msgStruct.Children;
            end

            if startsWith(currLine,'</table')||endsWith(currLine,'/>')
                break;
            end
        end

        function attrs=getAttributes(nodeStr)

            nodeStr=strip(nodeStr);
            [s,e]=regexp(nodeStr,'\s+\w*\s*=\s*"[^"]*"');

            attrs=struct.empty(length(s),0);
            for i=1:length(s)
                ss=extractBetween(nodeStr,s(i),e(i));
                [nvs,nve]=regexp(ss{1},'[\w:]*');
                assert(length(nvs)==2);

                attrs(i).Name=cell2mat(extractBetween(ss{1},nvs(1),nve(1)));
                attrs(i).Value=cell2mat(extractBetween(ss{1},nvs(2),nve(2)));
            end

            function msgStruct=getMessage(nodeStr)

                msg.Name='#text';
                msg.Attributes=[];
                msg.Children=[];
                msg.Data=strip(extractBetween(nodeStr,'>','</message>'));
                msg.Data=replaceSpecialSequences(msg.Data{1});

                msgStruct.Name='message';
                msgStruct.Attributes=getAttributes(nodeStr);
                msgStruct.Children(1)=msg;

                function msg=replaceSpecialSequences(msg)

                    msg=strrep(msg,'&lt;','<');
