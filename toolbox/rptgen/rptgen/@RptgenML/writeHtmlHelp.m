function writeHtmlHelp(this,fName)










    if nargin<2
        fName='_help.html';
    end

    if isa(this,'RptgenML.ComponentMaker')
        fid=this.openFile(fName);
        dName=this.DisplayName;
        clsName=[this.PkgName,'.',this.ClassName];
        desc=this.Description;
        compType=this.Type;
    elseif isa(this,'rptgen.rptcomponent')
        fid=fopen(fName,'w');
        dName=this.getName;
        clsName=class(this);
        desc=this.getDescription;
        compType=this.getType;
    else
        error(message('rptgen:RptgenML:invalidHtmlHelpArgument'));
    end

    dName=escapeHtml(dName);
    desc=escapeHtml(desc);
    compType=escapeHtml(compType);

    fprintf(fid,'<html><head><title>%s (Report Generator)</title>\n',...
    dName);

    fprintf(fid,'<link rel=stylesheet href="docstyle1.css" type="text/css">\n');

    fprintf(fid,'</head>\n<body bgcolor="#ffffff">\n');


    fprintf(fid,'\n<table border=0 width="100%%" cellpadding=0 cellspacing=0><tr>\n');
    fprintf(fid,'<td valign=baseline bgcolor="#e7ebf7"><b>Report Generator</b></td>\n');
    fprintf(fid,'<!-- Navigation Arrows\n<td valign=baseline bgcolor="#e7ebf7" align=right>\n<a href="PREV.html"><img src="b_prev.gif" alt="Previous page" border=0></a>\n&nbsp;&nbsp;&nbsp;\n<a href="NEXT.html"><img src="b_next.gif" alt="Next Page" border=0></a>\n</td>\n-->\n');
    fprintf(fid,'</tr></table>\n');


    fprintf(fid,'<a name="obj.%s"></a><font size="+3" color="#990000">%s</font>\n',...
    clsName,dName);


    fprintf(fid,'\n<a name="category"></a><!-- H2 --><br><font size="+1" color="#990000"><b>Category</b></font><br class="hdr">\n<p>%s</p>\n',...
    compType);


    fprintf(fid,'\n<a name="description"></a><!-- H2 --><p><font size="+1" color="#990000"><b>Description</b></font><br class="hdr">\n<p>%s</p>\n',...
    desc);


    fprintf(fid,'\n<a name="attributes"></a><!-- H2 --><p><font size="+1" color="#990000"><b>Attributes</b></font><br class="hdr">\n');
    fprintf(fid,'\n<!--<p>The following figure shows the <strong>%s</strong> properties panel:</p>\n<p><img src="_screenshot.png" alt="" align=bottom></p>-->\n',...
    dName);

    fprintf(fid,'\n<!--<a name="group_header_XX"></a><p><font size="+1" color="#990000"><b>Group Header XX</b></font><br class="hdr">-->\n');

    fprintf(fid,'\n<dl>\n');

    if isa(this,'RptgenML.ComponentMaker')
        thisProp=this.down;
        while~isempty(thisProp)
            writeHelp(thisProp,fid);
            thisProp=thisProp.right;
        end
    elseif isa(this,'rptgen.rptcomponent')

        allProp=get(classhandle(this),'Properties');
        superProp=get(findclass(findpackage('rptgen'),'rptcomponent'),'Properties');

        allPropNames=get(allProp,'Name');
        superPropNames=get(superProp,'Name');
        [thisPropNames,thisPropIdx]=setdiff(allPropNames,superPropNames);
        allProp=allProp(thisPropIdx);

        for i=1:length(allProp)
            writeHelp(allProp(i),fid);
        end
    end

    fprintf(fid,'</dl>\n');

    fprintf(fid,'\n<!--<a name="example"></a><p><font color="#990000"><b>Example</b></font><br class="hdr">\n<p>This is an example</p>-->\n');

    fprintf(fid,'\n<a name="insert_anything_into_report?"></a><!-- H2 --><p><font size="+1" color="#990000"><b>Insert Anything into Report?</b></font><br class="hdr">\n<p>Yes. <!-- Table/Text/Chapter/Image --></p>\n');

    fprintf(fid,'\n<a name="filename"></a><!-- H2 --><p><font size="+1" color="#990000"><b>Filename</b></font><br class="hdr">\n<p><code>%s</code></p>\n',...
    clsName);

    fprintf(fid,'\n<!-- Navigation Table\n<table bgcolor="#e7ebf7" border=0 width="100%%" cellpadding=0 cellspacing=0><tr valign=top><td align=left width=20>\n<a href="PREV.html"><img src="b_prev.gif" alt="Previous page" border=0 align=bottom></a>&nbsp;</td>td align=left>&nbsp;Previous Page</td>\n<td>&nbsp;</td>\n<td align=right>Next Page&nbsp;</td><td align=right width=20><a href="NEXT.html"><img src="b_next.gif" alt="Next page" border=0 align=bottom></a></td>\n</tr></table>\n-->\n');






    fprintf(fid,'\n</body>\n</html>');

    fclose(fid);

    if isa(this,'RptgenML.ComponentMaker')
        this.viewFile(fName);
    elseif isa(this,'rptgen.rptcomponent')
        edit(fName);
    end


    function writeHelp(this,fid)

        if isa(this,'RptgenML.ComponentMakerData')
            desc=this.Description;
            if isempty(desc)
                desc=this.PropertyName;
            end
            dataType=this.DataTypeString;
            eNames=this.EnumNames;
            eValues=this.EnumValues;
        else
            if strcmp(this.Visible,'off')||strcmp(this.AccessFlags.PublicSet,'off')
                return;
            end
            desc=this.Description;
            if isempty(desc)
                desc=this.Name;
            end
            dataType=this.DataType;
            dt=findtype(dataType);
            if isa(dt,'rptgen.enum')
                dataType='!enumeration';
                eNames=dt.DisplayNames;
                eValues=dt.Strings;
            end
        end

        desc=escapeHtml(desc);


        fprintf(fid,'<dt><b>%s</b></dt>\n<dd>(Description) ',desc);

        if strcmpi(dataType,'!enumeration')
            nameCount=length(eNames);
            fprintf(fid,'\n<ul>\n');
            for i=1:length(eValues)
                if i<=nameCount
                    eName=eNames{i};
                else
                    eName=eValues{i};
                end
                fprintf(fid,'<li><code>%s</code> -- (Description)</li>\n',escapeHtml(eName));
            end
            fprintf(fid,'</ul>\n');
        end

        if strcmpi(dataType,rptgen.makeStringType)
            fprintf(fid,'Supports the <code>%%&lt;varname&gt;</code> notation.');
        end

        fprintf(fid,'</dd>\n');



        function str=escapeHtml(str)



            str=strrep(str,'&','&amp;');
            str=strrep(str,'<','&lt;');
            str=strrep(str,'>','&gt;');

