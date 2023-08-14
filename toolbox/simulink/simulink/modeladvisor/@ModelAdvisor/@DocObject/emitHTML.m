function out=emitHTML(h)




    xDoc=h.XDoc;

    out=locEmitHTML(xDoc);

    out=regexprep(out,'([ ]*[\n]+[ ]*)+','\n');


    if length(out)>=2&&out(1)==sprintf('\n')
        out=out(2:end);
    end

    function out=locEmitHTML(xObj)


        if strcmp(xObj.getNodeName,'#comment')
            out=[];
            return
        end



        if strcmp(xObj.getNodeName,'#text')

            txt=char(xObj.getNodeValue);

            txt=strrep(txt,'&','&amp;');
            txt=strrep(txt,'<','&lt;');
            txt=strrep(txt,'>','&gt;');
            txt=strrep(txt,char(160),'&#160;');


            txt=regexprep(txt,'\s+',' ');
            out=txt;
            return
        end


        tagname=char(xObj.getTagName);

        attrib=cell(xObj.getAttributes.getLength,1);
        for k=1:xObj.getAttributes.getLength
            attrib{k}=[char(xObj.getAttributes.item(k-1).Name),'="',char(xObj.getAttributes.item(k-1).Value),'"'];
        end


        delim=locGetDelimiter(tagname);
        tag=sprintf('%s<%s',delim,lower(tagname));



        for k=1:length(attrib)
            tag=sprintf('%s %s',tag,attrib{k});
        end
        tag=[tag,'>'];
        out=tag;


        if locDynamicContents(xObj)
            out=[out,'#'];
        else

            for k=1:xObj.getLength
                out=[out,locEmitHTML(xObj.item(k-1))];
            end
        end


        out=[out,'</',lower(tagname),'>',delim];





        function out=locGetDelimiter(tag)



            tags={
'html'
'head'
'body'
'title'
'p'
'br'
'table'
'tr'
'h1'
'h2'
'h3'
'h4'
'h5'
'h6'
'hr'
'li'
'ul'
'ol'
'dl'
'div'
            };

            if any(strcmpi(tag,tags))
                out=sprintf('\n');
            else
                out='';
            end

            function out=locDynamicContents(xObj)
                out=false;

                spanclass={
'timestamp'
'version'
'runsummary'
                };


                if strcmpi(char(xObj.getTagName),'span')
                    classname=char(xObj.getAttribute('class'));
                    if isempty(classname)
                        classname=char(xObj.getAttribute('CLASS'));
                    end
                    if any(strcmpi(classname,spanclass))
                        out=true;
                    end
                end
