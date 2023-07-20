function emitXML(h,filename)




    fid=fopen(filename,'w','n','UTF-8');

    try


        tag_traceInfo='traceInfo';
        tag_blocks='blocks';


        fwrite(fid,'<?xml version="1.0" encoding="UTF-8"?>');

        fwrite(fid,XmlTagBegin('traceInfo'),'char');

        fwrite(fid,XmlTagBegin(tag_blocks),'char');
        reasonMap=h.getBlockReductionReasons;
        registry=h.getRegistryWithScope();
        arrayfun(@(x)(locWriteRegistry(fid,h,reasonMap,x)),registry);

        fwrite(fid,XmlTagEnd(tag_blocks),'char');
        fwrite(fid,XmlTagEnd(tag_traceInfo),'char');

    catch me
        fclose(fid);
        rethrow(me);
    end

    fclose(fid);

    function locWriteRegistry(fid,h,reasonMap,reg)
        tag_block='block';
        tag_name='name';
        tag_rtwname='rtwname';
        tag_pathname='pathname';
        tag_locations='locations';
        tag_location='location';
        tag_file='file';
        tag_line='line';
        tag_scope='scope';
        tag_comment='comment';
        tag_href='href';

        hyperlink=locGetHyperlink(reg);
        fwrite(fid,XmlTagBegin(tag_block),'char');
        fwrite(fid,XmlElement(tag_name,reg.name),'char');
        fwrite(fid,XmlElement(tag_rtwname,reg.rtwname),'char');
        fwrite(fid,XmlElement(tag_pathname,reg.pathname),'char');
        if~isempty(hyperlink)
            fwrite(fid,XmlElement(tag_href,hyperlink),'char');
        end
        fwrite(fid,XmlTagBegin(tag_locations),'char');
        len=length(reg.location);
        for m=1:len
            loc=reg.location(m);
            [~,file,ext]=fileparts(loc.file);
            ln=sprintf('%d',loc.line);
            hyperlink=[file,'_',ext(2),'.html#',ln];
            s=[XmlTagBegin(tag_location),...
            XmlElement(tag_file,[file,ext]),...
            XmlElement(tag_line,ln),...
            XmlElement(tag_scope,loc.scope),...
            XmlElement(tag_href,hyperlink),...
            XmlTagEnd(tag_location)];
            fwrite(fid,s,'char');
        end
        if len==0
            [~,comment]=h.getReason(reasonMap,reg);
            if~isempty(comment)
                fwrite(fid,XmlElement(tag_comment,comment),'char');
            end
        end
        fwrite(fid,XmlTagEnd(tag_locations),'char');
        fwrite(fid,XmlTagEnd(tag_block),'char');

        function out=XmlEscape(content)

            out=strrep(content,'&','&amp;');
            out=strrep(out,'<','&lt;');
            out=strrep(out,'>','&gt;');
            out=strrep(out,'"','&quot;');
            out=strrep(out,'''','&apos;');

            function out=XmlElement(tag,content)

                content=XmlEscape(content);
                out=sprintf('<%s>%s</%s>',tag,content,tag);

                function out=XmlTagBegin(tag,varargin)

                    if nargin==2
                        out=['<',tag,' ',varargin{1},'>'];
                    else
                        out=['<',tag,'>'];
                    end

                    function out=XmlTagEnd(tag)

                        out=['</',tag,'>'];

                        function out=XmlAttribute(attrib,value)

                            out=sprintf('%s="%s"',attrib,value);

                            function out=locGetHyperlink(reg)


                                if isempty(reg.hyperlink)
                                    out='';
                                    return
                                end
                                [~,out]=strtok(reg.hyperlink,'"');
                                out=strtok(out,'"');

                                if out(end)==';'
                                    out=out(1:end-1);
                                end



