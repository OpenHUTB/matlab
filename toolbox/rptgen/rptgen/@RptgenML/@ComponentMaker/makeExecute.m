function makeExecute(h)




    fid=h.openFile('execute.m');

    fprintf(fid,'function out=execute(thisComp,parentDoc,varargin)\n');
    fprintf(fid,'%%EXECUTE Generate report output\n');
    fprintf(fid,'%%   OUT = EXECUTE(THISCOMP,PARENTDOC) is called during\n');
    fprintf(fid,'%%    generation to produce the component''s contribution\n');
    fprintf(fid,'%%    to the report.\n');
    fprintf(fid,'%%    \n');
    fprintf(fid,'%%   THISCOMP is the Report Generator component being run.\n');
    fprintf(fid,'%%   PARENTDOC is a handle to the current document being generated.\n');
    fprintf(fid,'%%   OUT is a Document Object Model node or string to be added \n');
    fprintf(fid,'%%    to the report.  For more help with DOM nodes, see XMLWRITE\n');
    fprintf(fid,'%%    \n\n');

    h.writeHeader(fid);

    fprintf(fid,'out=[];\n\n');

    fprintf(fid,'%% ***************************************************** \n');
    fprintf(fid,'%% * This block of code shows how to access each       * \n');
    fprintf(fid,'%% * component property.  Property values control how  * \n');
    fprintf(fid,'%% * the component behaves during execution.           * \n');
    fprintf(fid,'%% *                                                   * \n');
    fprintf(fid,'%% * Property values should not be changed or set      * \n');
    fprintf(fid,'%% * during execution.                                 * \n');
    fprintf(fid,'%% ***************************************************** \n\n');


    thisProp=h.down;
    while~isempty(thisProp)
        writeExecute(thisProp,fid);
        thisProp=thisProp.right;
    end

    fprintf(fid,'%% ***************************************************** \n');
    fprintf(fid,'%% * This block of code shows how to create basic      * \n');
    fprintf(fid,'%% * documentation elements.  Once you have processed  * \n');
    fprintf(fid,'%% * your data, use one or more of these to return the * \n');
    fprintf(fid,'%% * component''s formatted output.                     * \n');
    fprintf(fid,'%% ***************************************************** \n\n');

    fprintf(fid,'%% To create a table, set the "Source" property with your cell\n');
    fprintf(fid,'%% array or structure.  For more help with tables, type:\n');
    fprintf(fid,'%% help(rptgen.cfr_table)\n');
    fprintf(fid,'%% \n');
    fprintf(fid,'%% tableSrc = struct(''dec'',5,''jun'',9,''feb'',3);\n');
    fprintf(fid,'%% tableSrc = {''mon'',''wed'',''fri'';pi,log(10),sqrt(-1)};\n');
    fprintf(fid,'%% out = execute(rptgen.cfr_table(...\n');
    fprintf(fid,'%%     ''Source''        , tableSrc,...\n');
    fprintf(fid,'%%     ''numHeaderRows'' , 1,...\n');
    fprintf(fid,'%%     ''TableTitle''    , ''Example Title''),...\n');
    fprintf(fid,'%%    parentDoc);\n\n');

    fprintf(fid,'%% To create a list, set the "Source" property with your\n');
    fprintf(fid,'%% cell vector.  For more help with lists, type:\n');
    fprintf(fid,'%% help(rptgen.cfr_list)\n');
    fprintf(fid,'%% \n');
    fprintf(fid,'%% listSrc = {''item1'',''item2'',{''subitem1'',''subitem2''},''item3''};\n');
    fprintf(fid,'%% out = execute(rptgen.cfr_list(...\n');
    fprintf(fid,'%%     ''Source''    , listSrc,...\n');
    fprintf(fid,'%%     ''ListStyle'' , ''orderedlist'',...\n');
    fprintf(fid,'%%     ''ListTitle'' , ''Example List''),...\n');
    fprintf(fid,'%%    parentDoc);\n\n');

    fprintf(fid,'%% To create a text, set the "ParaText" property with \n');
    fprintf(fid,'%% your string.  For more help with paragraphs, type:\n');
    fprintf(fid,'%% help(rptgen.cfr_paragraph)\n');
    fprintf(fid,'%% \n');
    fprintf(fid,'%% paraSrc = ''Lorem ipsum dolor'';\n');
    fprintf(fid,'%% out = execute(rptgen.cfr_paragraph(...\n');
    fprintf(fid,'%%     ''ParaText'' , paraSrc),...\n');
    fprintf(fid,'%%    parentDoc);\n\n');

    fprintf(fid,'%% To create graphics, set the "FigureHandle" property with \n');
    fprintf(fid,'%% your figure.  For more help with figure snapshots, type:\n');
    fprintf(fid,'%% help(rptgen_hg.chg_fig_snap)\n');
    fprintf(fid,'%% \n');
    fprintf(fid,'%% figSrc = gcf;\n');
    fprintf(fid,'%% out = execute(rptgen_hg.chg_fig_snap(...\n');
    fprintf(fid,'%%     ''FigureHandle''   , figSrc,...\n');
    fprintf(fid,'%%     ''Title''          , '''',...\n');
    fprintf(fid,'%%     ''isResizeFigure'' , ''manual'',...\n');
    fprintf(fid,'%%     ''PrintSize''      , [6 4],...\n');
    fprintf(fid,'%%     ''PrintUnits''     , ''inches''),...\n');
    fprintf(fid,'%%    parentDoc);\n\n');


    fprintf(fid,'%% ***************************************************** \n');
    fprintf(fid,'%% * This block of code shows how to run child         * \n');
    fprintf(fid,'%% * components.  The first line calls the "execute.m" * \n');
    fprintf(fid,'%% * method for all child components.  The second line * \n');
    fprintf(fid,'%% * appends the result of the child runs to the       * \n');
    fprintf(fid,'%% * existing output.                                  * \n');
    fprintf(fid,'%% *                                                   * \n');
    fprintf(fid,'%% * See also GETPARENTABLE                            * \n');
    fprintf(fid,'%% ***************************************************** \n\n');

    if~h.Parentable

        fprintf(fid,'%% ');
    end

    fprintf(fid,'childOut = thisComp.runChildren(parentDoc);\n');
    if~h.Parentable

        fprintf(fid,'%% ');
    end

    fprintf(fid,'out = parentDoc.createDocumentFragment(out,childOut);\n\n');

    fclose(fid);

    h.viewFile('execute.m',1);


    if~isempty(h.v1ExecuteFile)&&...
        exist(h.v1ExecuteFile,'file')==2
        [~,oFile]=fileparts(h.v1ExecuteFile);
        newFile=fullfile(h.ClassDir,[oFile,'.old']);
        try
            copyfile(h.v1ExecuteFile,newFile,'f');
            h.viewFile([oFile,'.old']);
        catch ME
            h.ErrorMessage=ME.message;
        end
    end



    function writeExecute(this,fid)


        switch this.DataTypeString
        case 'bool'
            fprintf(fid,'if thisComp.%s  %% %s\n    \nelse\n    \nend\n\n',...
            this.PropertyName,this.Description);
        case '!ENUMERATION'
            fprintf(fid,'switch thisComp.%s %% %s\n',...
            this.PropertyName,this.Description);
            nameCount=length(this.EnumNames);
            for i=1:length(this.EnumValues)
                if nameCount>=i
                    eName=this.EnumNames{i};
                else
                    eName=this.EnumValues{i};
                end
                fprintf(fid,'    case ''%s'' %% %s\n       \n',...
                this.EnumValues{i},eName);
            end
            fprintf(fid,'    otherwise\n        error(''rptgen:InvalidEnumValue'',''Invalid value "%%s"'',...\n              thisComp.%s)\nend\n\n',...
            this.PropertyName);
        case{rptgen.makeStringType,'ustring'}
            fprintf(fid,'parsedString = rptgen.parseExpressionText(thisComp.%s); %% %s\n\n',...
            this.PropertyName,this.Description);
        otherwise
            fprintf(fid,'p%s = thisComp.%s;  %% %s;\n\n',...
            strrep(this.DataTypeString,' ','_'),...
            this.PropertyName,...
            this.Description);
        end

