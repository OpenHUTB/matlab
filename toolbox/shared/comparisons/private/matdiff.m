function htmlOut=matdiff(source1,source2,reportID,mergingEnabled)







    if nargin<4

        mergingEnabled='true';
    end

    figureCleanup=createFigureCleanup();%#ok<NASGU>

    [source1,fullname1,shortname1,readable1]=i_resolve(source1);
    [source2,fullname2,shortname2,readable2]=i_resolve(source2);

    colors=i_defineColors();





    if strcmp(shortname1,shortname2)
        [pt1,n,e]=fileparts(readable1);
        shortname1=[n,e];
        [pt2,n,e]=fileparts(readable2);
        shortname2=[n,e];
        while strcmp(shortname1,shortname2)
            [pt1,dn1]=fileparts(pt1);
            [pt2,dn2]=fileparts(pt2);
            if isempty(dn1)&&isempty(dn2)


                break;
            end


            shortname1=fullfile(dn1,shortname1);
            shortname2=fullfile(dn2,shortname2);
        end
    end

    [names1,size1,backup1,format1]=i_info(readable1);
    [names2,size2,backup2,format2]=i_info(readable2);


    [escFullname1,escShortname1]=escapeHTML(fullname1,shortname1);
    [escFullname2,escShortname2]=escapeHTML(fullname2,shortname2);




    filesize_threshold=settings().comparisons.mat.MAX_MAT_FILE_SIZE.ActiveValue;
    one_at_a_time=size1>filesize_threshold||size2>filesize_threshold;

    if~one_at_a_time


        try

            variables1=i_load(readable1);
            variables2=i_load(readable2);
        catch E
            if~strcmp(E.identifier,'MATLAB:nomem')

                rethrow(E);
            end
            one_at_a_time=true;
        end
    end

    if one_at_a_time




        variables1=struct;
        variables2=struct;
    end

    allnames=unique(vertcat(names1(:),names2(:)));

    doc=matlab.io.xml.dom.Document('MatFileEditScript');

    root=doc.getDocumentElement;
    if~useNoJava()
        bundles=[...
        '<script type="text/javascript" src="/toolbox/shared/comparisons/web/mw-diff/release/mw-diff/dojoConfig-release-global.js"></script>',...
        newline,...
        '<script type="text/javascript" src="/toolbox/shared/comparisons/web/mw-diff/release/bundle.index.js"></script>'];
        root.setAttribute('bundles',bundles);
    end
    root.setAttribute('id',reportID);
    root.setAttribute('mergingEnabled',mergingEnabled);

    root.setAttribute('FindCSS',createFindCSS());
    root.setAttribute('clickToSort',...
    getString(message('comparisons:comparisons:MatDiffClickToSort')));
    root.setAttribute('reportTitle',...
    getString(message('comparisons:comparisons:MatDiffTitle',...
    escShortname1,escShortname2)));
    root.setAttribute('LeftFileMsg',...
    getString(message('comparisons:comparisons:MatDiffLeftFile')));
    root.setAttribute('RightFileMsg',...
    getString(message('comparisons:comparisons:MatDiffRightFile')));


    root.setAttribute('ActionMsg',...
    getString(message('comparisons:comparisons:MatDiffAction')));
    root.setAttribute('VarNameMsg',...
    getString(message('comparisons:comparisons:MatDiffVarName')));
    root.setAttribute('ClassMsg',...
    getString(message('comparisons:comparisons:MatDiffClass')));
    root.setAttribute('SizeMsg',...
    getString(message('comparisons:comparisons:MatDiffSize')));
    root.setAttribute('StatusMsg',...
    getString(message('comparisons:comparisons:MatDiffStatus')));
    root.setAttribute('LearnMoreTitle',...
    getString(message('comparisons:comparisons:MatDiffLearnMore')));


    root.setAttribute('IdenticalFilesMsg',...
    getString(message('comparisons:comparisons:MatDiffIdenticalFiles')));
    root.setAttribute('ContainerDifferenceOnlyMsg',...
    getString(message('comparisons:comparisons:MatDiffContainerDifferenceOnly')));
    root.setAttribute('FormatDifferenceOnlyMsg',...
    getString(message('comparisons:comparisons:MatDiffFormatDifferenceOnly')));
    if~comparisons.internal.isMOTW()

        root.setAttribute('compareVarsMessage',...
        getString(message('comparisons:comparisons:MatDiffCompareVars')));
        root.setAttribute('compareLinkText',...
        getString(message('comparisons:comparisons:MatDiffCompare')));
    end
    root.setAttribute('classesDifferText',...
    [getString(message('comparisons:comparisons:MatDiffClassesDiffer')),' ']);
    root.setAttribute('ChangedColor',colors.modifiedvarcolor);
    root.setAttribute('BackgroundColor',colors.backgroundcolor);


    root.setAttribute('deleteLeftLinkTitle',...
    getString(message('comparisons:comparisons:MatDiffDeleteLeft')));
    root.setAttribute('mergeLeftLinkTitle',...
    getString(message('comparisons:comparisons:MatDiffMergeLeft')));
    root.setAttribute('deleteRightLinkTitle',...
    getString(message('comparisons:comparisons:MatDiffDeleteRight')));
    root.setAttribute('mergeRightLinkTitle',...
    getString(message('comparisons:comparisons:MatDiffMergeRight')));


    if strcmp(format1,format2)
        node=i_xmltextnode(doc,root,'LeftLocation',fullname1);
    else
        text1=getString(message('comparisons:comparisons:MatDiffFileAndFormat',fullname1,format1));
        node=i_xmltextnode(doc,root,'LeftLocation',text1);
    end
    node.setAttribute('Readable',readable1);
    node.setAttribute('ReadableNeutral',strrep(readable1,'\','/'));
    node.setAttribute('ShortName',escShortname1);
    node.setAttribute('ColumnHeader',...
    getString(message('comparisons:comparisons:MatDiffVariablesIn',...
    escShortname1)));
    node.setAttribute('leftLoadFileLinkMessage',...
    getString(message('comparisons:comparisons:MatDiffLoad',escFullname1)));

    if~isempty(backup1)
        node.setAttribute('Backup',backup1);
        node.setAttribute('CEFRestoreFromBackupMsg',...
        getString(message('comparisons:comparisons:MatDiffCEFRestoreFromBackup',...
        escShortname1,code2html(backup1))));
    end


    if strcmp(format1,format2)
        node=i_xmltextnode(doc,root,'RightLocation',fullname2);
    else
        text2=getString(message('comparisons:comparisons:MatDiffFileAndFormat',fullname2,format2));
        node=i_xmltextnode(doc,root,'RightLocation',text2);
    end
    node.setAttribute('Readable',readable2);
    node.setAttribute('ReadableNeutral',strrep(readable2,'\','/'));
    node.setAttribute('ShortName',escShortname2);
    node.setAttribute('ColumnHeader',...
    getString(message('comparisons:comparisons:MatDiffVariablesIn',...
    escShortname2)));
    node.setAttribute('rightLoadFileLinkMessage',...
    getString(message('comparisons:comparisons:MatDiffLoad',escFullname2)));

    if~isempty(backup2)
        node.setAttribute('Backup',backup2);
        node.setAttribute('CEFRestoreFromBackupMsg',...
        getString(message('comparisons:comparisons:MatDiffCEFRestoreFromBackup',...
        escShortname2,code2html(backup2))));
    end


    found_diff=false;
    for i=1:numel(allnames)
        varname=allnames{i};
        if~ismember(varname,names2)

            node=i_xmltextnode(doc,root,'LeftVariable',varname);
            var=i_getvar(readable1,variables1,varname);
            node.setAttribute('size',i_getsize(var));
            node.setAttribute('class',comparisons.internal.variableClass(var));
            found_diff=true;
            node.setAttribute('contentsColor',colors.leftvarcolor);
            node.setAttribute('statusSummary',...
            getString(message('comparisons:comparisons:MatDiffRemoved')));
            node.setAttribute('tableSummary',...
            getString(message('comparisons:comparisons:MatDiffNotInList')));
        elseif~ismember(varname,names1)

            node=i_xmltextnode(doc,root,'RightVariable',varname);
            var=i_getvar(readable2,variables2,varname);
            node.setAttribute('size',i_getsize(var));
            node.setAttribute('class',comparisons.internal.variableClass(var));
            found_diff=true;
            node.setAttribute('contentsColor',colors.rightvarcolor);
            node.setAttribute('statusSummary',...
            getString(message('comparisons:comparisons:MatDiffAdded')));
            node.setAttribute('tableSummary',...
            getString(message('comparisons:comparisons:MatDiffNotInList')));
        else

            node=i_xmltextnode(doc,root,'Variable',varname);
            var1=i_getvar(readable1,variables1,varname);
            node.setAttribute('leftsize',i_getsize(var1));
            node.setAttribute('leftclass',comparisons.internal.variableClass(var1));
            var2=i_getvar(readable2,variables2,varname);
            node.setAttribute('rightsize',i_getsize(var2));
            node.setAttribute('rightclass',comparisons.internal.variableClass(var2));
            match_type=comparisons.internal.variablesEqual(var1,var2);
            node.setAttribute('contentsMatch',match_type);
            if~strcmp(match_type,'yes')&&~strcmp(match_type,'classesdiffer')


                found_diff=true;
                node.setAttribute('contentsColor',colors.modifiedvarcolor);
                node.setAttribute('statusSummary',...
                [getString(message('comparisons:comparisons:MatDiffModified')),' ']);
            else
                node.setAttribute('contentsColor',colors.backgroundcolor);
                node.setAttribute('statusSummary',...
                getString(message('comparisons:comparisons:MatDiffIdentical')));
            end
        end
    end


    clear variables1;
    clear variables2;

    if~found_diff


        if~strcmp(format1,format2)

            root.setAttribute('difftype','format');
        else
            if isa(source1,'com.mathworks.comparisons.source.impl.LocalFileSource')
                sourceForCS1=char(source1.toString);
                sourceForCS2=char(source2.toString);
            else
                sourceForCS1=source1;
                sourceForCS2=source2;
            end

            checksum1=getFileChecksum(sourceForCS1);
            checksum2=getFileChecksum(sourceForCS2);
            if~isequal(checksum1,checksum2)


                root.setAttribute('difftype','container');
            else

                root.setAttribute('difftype','identical');
            end
        end
    else
        root.setAttribute('difftype','contents');
    end


    webroot=fullfile(matlabroot,'toolbox','shared','comparisons','web');
    stylesheet=fullfile(webroot,'templates','mat','styles','matdiff.xsl');



    tempXMLFile=[tempname,'.xml'];
    doc.xmlwrite(tempXMLFile)
    outStr=matlab.io.xml.transform.ResultString();
    transform(matlab.io.xml.transform.Transformer,tempXMLFile,stylesheet,outStr);
    htmlOut=char(outStr.String);
    try %#ok<TRYNC>
        delete(tempXMLFile);
    end

end


function node=i_xmltextnode(docNode,parentNode,tag,content)

    node=docNode.createElement(tag);
    node.appendChild(docNode.createTextNode(content));
    parentNode.appendChild(node);
end


function str=i_getsize(var)
    sz=size(var);


    if numel(sz)==2
        str=sprintf('%dx%d',sz(1),sz(2));
    elseif numel(sz)==3
        str=sprintf('%dx%dx%d',sz(1),sz(2),sz(3));
    else

        str=sprintf('%d-D',numel(sz));
    end
end


function[source,fullname,shortname,readable]=i_resolve(source)

    if ischar(source)||(isstring(source)&&isscalar(source))

        source=char(source);
        source=comparisons.internal.resolvePath(source);
        if useNoJava()

            fullname=source;
            readable=source;
            [~,nn,ee]=fileparts(source);
            shortname=[nn,ee];
            return
        end
        source=com.mathworks.comparisons.source.impl.LocalFileSource(java.io.File(source),source);%#ok<JAPIMATHWORKS>
    end

    absnameprop=com.mathworks.comparisons.source.property.CSPropertyAbsoluteName.getInstance();%#ok<JAPIMATHWORKS>
    if source.hasProperty(absnameprop)
        fullname=char(source.getPropertyValue(absnameprop,[]));
    else

        nameprop=com.mathworks.comparisons.source.property.CSPropertyName.getInstance();%#ok<JAPIMATHWORKS>

        assert(source.hasProperty(nameprop));
        fullname=char(source.getPropertyValue(nameprop,[]));
    end

    shorttitleprop=com.mathworks.comparisons.source.property.CSPropertyShortTitle.getInstance();%#ok<JAPIMATHWORKS>
    if source.hasProperty(shorttitleprop)
        shortname=char(source.getPropertyValue(shorttitleprop,[]));
    else

        nameprop=com.mathworks.comparisons.source.property.CSPropertyName.getInstance();%#ok<JAPIMATHWORKS>

        assert(source.hasProperty(nameprop));
        shortname=char(source.getPropertyValue(nameprop,[]));
    end

    readableprop=com.mathworks.comparisons.source.property.CSPropertyReadableLocation.getInstance();%#ok<JAPIMATHWORKS>

    assert(source.hasProperty(readableprop));
    readable=char(source.getPropertyValue(readableprop,[]));
end






function val=i_getvar(filename,variables,name)
    if isfield(variables,name)
        val=variables.(name);
    else
        x=i_load(filename,name);
        val=x.(name);
    end
end




function vars=i_load(filename,varname)
    cleanup=suppressWarnings();%#ok<NASGU>
    if nargin<2
        vars=load(filename,'-mat');
    else
        vars=load(filename,'-mat',varname);
    end
end




function[names,totalsize,backup_file,format]=i_info(filename)
    cleanup=suppressWarnings();
    w=figwhos('-file',filename);
    names={w.name};
    totalsize=sum([w.bytes]);
    backup_file=[filename,'~'];
    backup_exists=exist(backup_file,'file')~=0;
    if~backup_exists
        backup_file=[];
    end
    format=getMATFileType(filename);
    delete(cleanup);
end

function cleanup=suppressWarnings()
    w=warning('off');
    cleanup=onCleanup(@()warning(w));
end

function colors=i_defineColors()
    import comparisons.internal.colorutil.Colors
    import comparisons.internal.colorutil.rgb2hex
    colors.backgroundcolor='#FFF';
    colors.leftvarcolor=rgb2hex(Colors.leftColor());
    colors.rightvarcolor=rgb2hex(Colors.rightColor());
    colors.modifiedvarcolor=rgb2hex(Colors.modifiedColor());
end

function checksum=getFileChecksum(fileName)
    digester=matlab.internal.crypto.BasicDigester('DeprecatedMD5');
    checksumBytes=digester.computeFileDigest(fileName);
    checksum=char(upper(matlab.internal.crypto.hexEncode(checksumBytes)));
end

function findCSS=createFindCSS()
    import comparisons.internal.findutil.getFindHighlightClassName
    import comparisons.internal.findutil.getFindHighlightRGB
    highlightRGB=getFindHighlightRGB();
    findCSS=...
    ['.',char(getFindHighlightClassName()),' {',newline,...
    '       color: rgb(',num2str(highlightRGB.textColor),');',newline,...
    '  background: rgb(',num2str(highlightRGB.backgroundColor),');',newline,...
    ' text-shadow: none;',newline,...
    '}',newline];
end

function bool=useNoJava()
    bool=settings().comparisons.NoJavaVisdiff.ActiveValue...
    ||comparisons.internal.isMOTW();
end

function varargout=escapeHTML(varargin)
    varargout=cellfun(@code2html,varargin,'UniformOutput',false);
end