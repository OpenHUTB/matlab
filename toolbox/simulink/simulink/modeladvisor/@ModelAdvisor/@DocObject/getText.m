function out=getText(h,varargin)




    xObj=h.XDoc;
    mask=[];
    if nargin>1
        if mod(nargin-1,2)~=0
            DAStudio.error('Simulink:utility:invalidArgPairing',...
            'DocObject.getText');
        end
        for k=1:2:length(varargin)
            switch(varargin{k})
            case '-node'
                xObj=varargin{k+1};
            case '-mask'
                mask=varargin{k+1};

            otherwise
                DAStudio.error('Simulink:utility:invalidInputArgs',varargin{k})
            end
        end
    end

    out=locGetText(xObj,mask);


    out=regexprep(out,'([ ]*[\n][ ]*)+','\n');
    out=regexprep(out,'[ ]+',' ');
    out=strtrim(out);

    function out=locGetText(xObj,mask)
        out='';
        switch char(xObj.getNodeName)
        case{'#comment','script'}
            return
        case '#text'

            out=char(xObj.getNodeValue);


            out=regexprep(out,'\s+',' ');
            return
        case{'HR','hr'}
            out='-';
        end
        if locDynamicContents(xObj,mask)
            out='#';
            return
        end

        for n=1:xObj.getLength
            x=xObj.item(n-1);
            txt=locGetText(x,mask);
            out=[out,txt];%#ok<AGROW>
        end

        s=locGetSeparator(xObj);
        out=sprintf('%s%s%s',s,out,s);

        function out=locGetSeparator(x)

            if strcmp(x.getNodeName,'#text')
                out=[];
                return
            end
            tag=lower(char(x.getTagName));
            switch tag
            case{
'title'
'p'
'br'
'tr'
'h1'
'h2'
'h3'
'h4'
'h5'
'h6'
'h7'
'hr'
'li'
'ul'
'ol'
'hr'
                }
                out=sprintf('\n');
            case 'td'
                out=' ';
            otherwise
                out='';
            end

            function out=locDynamicContents(xObj,mask)
                out=false;

                if iscell(mask)
                    spanclass=mask;
                    if isempty(spanclass)
                        return
                    end
                else
                    spanclass={
'timestamp'
'version'
'runsummary'
                    };
                end

                if strcmpi(xObj.getTagName,'span')
                    classname=xObj.getAttribute('class');
                    if any(strcmpi(classname,spanclass))
                        out=true;
                    end
                end
