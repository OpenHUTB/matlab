function[htmlOut,diffType]=compare(...
    source1,...
    source2,...
    reportID,...
    reportStrings,...
tempDirs...
    )




    import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.resources.SlxComparisonResources;
    import com.mathworks.comparisons.compare.concr.BinaryComparison;
    import com.mathworks.comparisons.compare.concr.ListComparisonUtilities;
    import com.mathworks.xml.XMLUtils;

    [names1,variables1]=extractVars(source1);
    [names2,variables2]=extractVars(source2);

    allnames=unique(vertcat(names1(:),names2(:)));

    doc=XMLUtils.createDocument('MatFileEditScript');
    root=doc.getDocumentElement;
    root.setAttribute('id',reportID);

    leftShortName=reportStrings.getLeftModelWorkspaceShortName();
    rightShortName=reportStrings.getRightModelWorkspaceShortName();

    title=SlxComparisonResources.getString(...
    'modelworkspace.comparison.title',...
    [{leftShortName},{rightShortName}]...
    );
    i_XmlTextNode(doc,root,'Title',title);

    node=i_XmlTextNode(doc,root,'LeftLocation',reportStrings.getLeftModelFilePath());
    node.setAttribute('Readable',writeTempFile(variables1,source1,char(tempDirs(1))));
    node.setAttribute('ShortName',leftShortName);

    node=i_XmlTextNode(doc,root,'RightLocation',reportStrings.getRightModelFilePath());
    node.setAttribute('Readable',writeTempFile(variables2,source2,char(tempDirs(2))));
    node.setAttribute('ShortName',rightShortName);

    found_diff=false;

    for i=1:numel(allnames)
        varname=allnames{i};
        if~ismember(varname,names2)

            node=i_XmlTextNode(doc,root,'LeftVariable',varname);
            var=variables1.(varname);
            node.setAttribute('size',i_GetSize(var));
            node.setAttribute('class',comparisons.internal.variableClass(var));
            found_diff=true;
        elseif~ismember(varname,names1)

            node=i_XmlTextNode(doc,root,'RightVariable',varname);
            var=variables2.(varname);
            node.setAttribute('size',i_GetSize(var));
            node.setAttribute('class',comparisons.internal.variableClass(var));
            found_diff=true;
        else

            node=i_XmlTextNode(doc,root,'Variable',varname);
            var1=variables1.(varname);
            node.setAttribute('leftsize',i_GetSize(var1));
            node.setAttribute('leftclass',comparisons.internal.variableClass(var1));
            var2=variables2.(varname);
            node.setAttribute('rightsize',i_GetSize(var2));
            node.setAttribute('rightclass',comparisons.internal.variableClass(var2));
            match_type=comparisons.internal.variablesEqual(var1,var2);
            node.setAttribute('contentsMatch',match_type);
            if~strcmp(match_type,'yes')
                found_diff=true;
            end
        end
    end


    clear variables1;
    clear variables2;

    if~found_diff



        identical=BinaryComparison.compare(source1,source2);
        if~identical


            diffType='container';
            root.setAttribute('difftype',diffType);
        else

            diffType='identical';
            root.setAttribute('difftype',diffType);
        end
    else
        diffType='contents';
        root.setAttribute('difftype',diffType);
    end


    styleRoot=fullfile(matlabroot,'toolbox','rptgenext','slxmlcomp','web');
    schemafile=fullfile(styleRoot,'modelworkspace','styles','modelWorkspaceDiff.xsd');
    stylesheet=fullfile(styleRoot,'modelworkspace','styles','modelWorkspaceDiff.xsl');

    ListComparisonUtilities.debugSaveXML(doc,schemafile);
    xmlsource=XMLUtils.transformSourceFactory(doc);
    htmlOut=char(ListComparisonUtilities.doTransform(xmlsource,stylesheet));
end


function node=i_XmlTextNode(docNode,parentNode,tag,content)

    node=docNode.createElement(tag);
    node.appendChild(docNode.createTextNode(content));
    parentNode.appendChild(node);
end


function str=i_GetSize(var)
    sz=size(var);


    if numel(sz)==2
        str=sprintf('%dx%d',sz(1),sz(2));
    elseif numel(sz)==3
        str=sprintf('%dx%dx%d',sz(1),sz(2),sz(3));
    else

        str=sprintf('%d-D',numel(sz));
    end
end

function[names,vars]=extractVars(slxPart)
    vars=slxmlcomp.internal.modelWorkspace.extract(slxPart);
    names=fieldnames(vars);
end

function readable=writeTempFile(vars,slxPart,tempDir)
    import com.mathworks.comparisons.source.property.CSPropertyName;

    parent=slxPart.getParentSource();
    modelName=parent.getPropertyValue(CSPropertyName.getInstance(),[]);
    [~,modelName]=fileparts(char(modelName));
    readable=fullfile(tempDir,[modelName,'.mat']);
    save(readable,'-struct','vars');
end
