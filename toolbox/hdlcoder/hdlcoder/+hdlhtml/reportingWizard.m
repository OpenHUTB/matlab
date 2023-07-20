



classdef reportingWizard<handle
    properties(SetAccess=private,GetAccess=private)
file
htmldoc
insideRunningSection
    end

    methods


        function this=reportingWizard(filename,title,formatting)
            if isempty(filename)
                error(message('hdlcoder:engine:NoHTMLFile'));
            end
            if nargin<3
                formatting=true;
            end
            if nargin<2
                title='';
            end
            this.file=filename;
            this.htmldoc=ModelAdvisor.Document;
            this.htmldoc.setTitle(title);
            if(formatting)
                this.setFormatting;
            end
            this.insideRunningSection=false;
        end


        function setFormatting(this,param,value)
            if nargin<2
                param='';
                value='';
            end

            this.htmldoc.addHeadItem('<link rel="stylesheet" type="text/css" href="rtwreport.css" />');
            this.htmldoc.addHeadItem('<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>');
            if~isempty(param)&&strcmpi(param,'bgcolor')
                this.htmldoc.setBodyAttribute('bgcolor',value);
            else
                this.htmldoc.setBodyAttribute('bgcolor','#ffffff');
            end
            this.htmldoc.setBodyAttribute('link','0033CC');
            this.htmldoc.setBodyAttribute('vlink','#666666');
        end


        function setJsFormatting(this)
            this.htmldoc.addHeadItem('<script language="JavaScript" type="text/javascript" src="rtwhilite.js"></script>');
            this.htmldoc.addHeadItem('<script language="JavaScript" type="text/javascript" src="search.js"></script>');
        end


        function setHeader(this,header)
            section=this.createSection(header,'font');
            section.setAttribute('SIZE','+2');
            section.setAttribute('COLOR','#000066');
            this.commitSection(section);
        end


        function setAttribute(this,param,value)
            this.htmldoc.setBodyAttribute(param,value);
        end


        function setFramesetAttribute(this,param,value)
            this.htmldoc.setFramesetAttribute(param,value);
        end


        function addCollapsibleJS(this)


            addCollapseByElement(this);


            addCollapseAll(this);


            addExpandAll(this);
        end

        function addCollapseByElement(this)
            jsSection=ModelAdvisor.Element;
            jsSection.setTag('script');
            js=['<!--',10...
            ,'function hdlTableShrink(o,tagNameStr)',10...
            ,'{',10...
            ,'var temp = document.getElementsByName(tagNameStr);',10...
            ,'if (temp[0].style.display == "")',10...
            ,'{',10...
            ,9,'temp[0].style.display = "none";',10...
            ,9,'o.innerHTML = ''<span style="font-family:monospace">[+]</span>'';',10...
            ,'}',10...
            ,'else',10...
            ,'{',10...
            ,9,'temp[0].style.display = "";',10...
            ,9,'o.innerHTML = ''<span style="font-family:monospace">[-]</span>'';',10...
            ,'}',10...
            ,'}',10...
            ,'// -->'];
            jsSection.setContent(js);
            this.htmldoc.addItem(jsSection);
        end

        function addCollapseAll(this)
            jsSection=ModelAdvisor.Element;
            jsSection.setTag('script');
            js=['<!--',10...
            ,'function hdlTableCollapseAll(o, numNtks, numComps)',10...
            ,'{',10...
            ,9,'var id = "";',10...
            ,9,'for (i = 1; i <= numNtks; i++)',10...
            ,9,'{',10...
            ,9,9,'for (j = 1; j <= numComps; j++)',10...
            ,9,9,'{',10...
            ,9,9,9,'id = "Multiply" + "_" + i + "_" + j;',10...
            ,9,9,9,'var temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "none";',10...
            ,9,9,9,'}',10...
            ,9,9,9,'id = "Adder" + "_" + i + "_" + j;',10...
            ,9,9,9,'temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "none";',10...
            ,9,9,9,'}',10...
            ,9,9,9,'id = "Subtractor" + "_" + i + "_" + j;',10...
            ,9,9,9,'temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "none";',10...
            ,9,9,9,'}',10...
            ,9,9,9,'id = "Register" + "_" + i + "_" + j;',10...
            ,9,9,9,'temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "none";',10...
            ,9,9,9,'}',10...
            ,9,9,9,'id = "RAM" + "_" + i + "_" + j;',10...
            ,9,9,9,'temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "none";',10...
            ,9,9,9,'}',10...
            ,9,9,9,'id = "Multiplexer" + "_" + i + "_" + j;',10...
            ,9,9,9,'temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "none";',10...
            ,9,9,9,'}',10...
            ,9,9,'}',10...
            ,9,'}',10...
            ,9,'var collapsibles = document.getElementsByName(''collapsible'');',10...
            ,9,'for (i = 0; i < collapsibles.length; i++)',10...
            ,9,'{',10...
            ,9,9,'collapsibles[i].innerHTML = ''<span style="font-family:monospace">[+]</span>'';',10...
            ,9,'}',10...
            ,'}',10...
            ,'// -->'];
            jsSection.setContent(js);
            this.htmldoc.addItem(jsSection);
        end

        function addExpandAll(this)
            jsSection=ModelAdvisor.Element;
            jsSection.setTag('script');
            js=['<!--',10...
            ,'function hdlTableExpandAll(o, numNtks, numComps)',10...
            ,'{',10...
            ,9,'var id = "";',10...
            ,9,'for (i = 1; i <= numNtks; i++)',10...
            ,9,'{',10...
            ,9,9,'for (j = 1; j <= numComps; j++)',10...
            ,9,9,'{',10...
            ,9,9,9,'id = "Multiply" + "_" + i + "_" + j;',10...
            ,9,9,9,'var temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "";',10...
            ,9,9,9,'}',10...
            ,9,9,9,'id = "Adder" + "_" + i + "_" + j;',10...
            ,9,9,9,'temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "";',10...
            ,9,9,9,'}',10...
            ,9,9,9,'id = "Subtractor" + "_" + i + "_" + j;',10...
            ,9,9,9,'temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "";',10...
            ,9,9,9,'}',10...
            ,9,9,9,'id = "Register" + "_" + i + "_" + j;',10...
            ,9,9,9,'temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "";',10...
            ,9,9,9,'}',10...
            ,9,9,9,'id = "RAM" + "_" + i + "_" + j;',10...
            ,9,9,9,'temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "";',10...
            ,9,9,9,'}',10...
            ,9,9,9,'id = "Multiplexer" + "_" + i + "_" + j;',10...
            ,9,9,9,'temp = document.getElementsByName(id);',10...
            ,9,9,9,'if (temp != null && temp.length > 0)',10...
            ,9,9,9,'{',10...
            ,9,9,9,9,'temp[0].style.display = "";',10...
            ,9,9,9,'}',10...
            ,9,9,'}',10...
            ,9,'}',10...
            ,9,'var collapsibles = document.getElementsByName(''collapsible'');',10...
            ,9,'for (i = 0; i < collapsibles.length; i++)',10...
            ,9,'{',10...
            ,9,9,'collapsibles[i].innerHTML = ''<span style="font-family:monospace">[-]</span>'';',10...
            ,9,'}',10...
            ,'}',10...
            ,'// -->'];
            jsSection.setContent(js);
            this.htmldoc.addItem(jsSection);
        end


        function dumpHTML(this)
            fid=fopen(this.file,'w','n','utf8');
            if fid==-1
                error(message('hdlcoder:engine:cannotopenfile',this.file));
            end
            fwrite(fid,this.htmldoc.emitHTML,'char');
            fclose(fid);
        end


        function dump2ExistingHTML(this)
            fid=fopen(this.file,'a+','n','utf8');
            if fid==-1
                error(message('hdlcoder:engine:cannotopenfile',this.file));
            end
            fwrite(fid,this.htmldoc.emitHTML,'char');
            fclose(fid);
        end





        function addText(this,text,count)
            if nargin<3
                count=1;
            end
            for i=1:count
                mTxt=ModelAdvisor.Text(text);
                this.htmldoc.addItem(mTxt);
            end
        end


        function addFormattedText(this,text,format,count)
            if nargin<4
                count=1;
            end
            for i=1:count
                mTxt=ModelAdvisor.Text(text);
                if~isempty(findstr(format,'b'))
                    mTxt.IsBold=true;
                end
                if~isempty(findstr(format,'i'))
                    mTxt.IsItalic=true;
                end
                if~isempty(findstr(format,'u'))
                    mTxt.IsUnderlined=true;
                end
                if~isempty(findstr(format,'s'))
                    mTxt.IsSubscript=true;
                end
                if~isempty(findstr(format,'S'))
                    mTxt.IsSuperscript=true;
                end
                this.htmldoc.addItem(mTxt);
            end
        end


        function addBlank(this)
            this.addText('&nbsp');
        end


        function addLine(this,count)
            if nargin<2
                count=1;
            end
            this.addText('<p><hr /></p>',count);
        end


        function addBreak(this,count)
            if nargin<2
                count=1;
            end
            this.addText('<br />',count);
        end


        function addLink(this,text,link)
            section=this.createSection(text,'a');
            section.setAttribute('href',link);
            this.commitSection(section);
        end


        function addFrame(this,frame)
            this.htmldoc.addFrameItem(frame.getData);
        end





        function section=createSection(~,content,tag)
            if nargin<3
                tag='';
            end
            if nargin<2
                content='';
            end
            section=hdlhtml.section(content,tag);
        end


        function section=createSectionTitle(this,title)
            innersection=this.createSection(title);
            section=innersection.formatTitle(title);
        end


        function commitSection(this,section)
            this.htmldoc.addItem(section.getData);
        end





        function table=createTable(~,row,column,heading,formatting)
            if nargin<4
                heading='';
            end
            if nargin<5
                formatting=true;
            end
            table=hdlhtml.table(row,column,heading,formatting);
        end


        function commitTable(this,table)
            this.htmldoc.addItem(table.getData);
        end





        function list=createList(~)
            list=hdlhtml.list;
        end


        function commitList(this,list)
            this.htmldoc.addItem(list.getData);
        end





        function startColoredSection(this,colorcode)
            this.insideRunningSection=true;
            this.addText(['<div style="background-color: ',colorcode,'">']);
        end


        function endColoredSection(this)
            this.insideRunningSection=false;
            this.addText('</div>');
        end


        function flag=isInsideRunningSection(this)
            flag=this.insideRunningSection;
        end
    end

    methods(Static)

        function linkedPath=generateSystemLinkFromHandle(name,h)
            sid=Simulink.ID.getSID(h);
            link=sprintf('matlab:coder.internal.code2model(''%s'')',sid);
            section=hdlhtml.section(name,'a');
            section.setAttribute('href',link);
            section.setAttribute('name','code2model');
            section.setAttribute('class','code2model');
            linkedPath=section.getHTML;
        end


        function linkedPath=generateSystemLink(path,h,emitEntireName)
            if nargin<2
                h=[];
            end
            if isempty(path)
                linkedPath='';
                return;
            end
            if isempty(h)
                try
                    h=get_param(path,'Handle');
                catch
                    h=[];
                end
            end
            [~,nameVisible]=fileparts(path);
            if(nargin>2)&&emitEntireName
                nameVisible=path;
            end
            if isempty(h)
                linkedPath=path;
            else
                linkedPath=hdlhtml.reportingWizard.generateSystemLinkFromHandle(nameVisible,h);
            end
        end


        function linkedPath=generateSystemLinkForSignal(name,h)
            blockName=get_param(h,'Parent');
            blockName=string(blockName);
            blockName=regexprep(blockName,'\n',' ');
            portNumber=get_param(h,'PortNumber');
            bdrootName=get_param(bdroot,'Name');
            linkStr=sprintf('matlab:set_param(''%s'', ''hiliteAncestors'', ''none'');',bdrootName);
            linkStr=sprintf('%s hilite_system(getfield(get_param(''%s'', ''Porthandles''), ''Outport'', {%d}), ''blueWhite'');',linkStr,blockName,portNumber);
            section=hdlhtml.section(name,'a');
            section.setAttribute('href',linkStr);
            section.setAttribute('name','code2model');
            section.setAttribute('class','code2model');
            linkedPath=section.getHTML;
        end

    end

end



