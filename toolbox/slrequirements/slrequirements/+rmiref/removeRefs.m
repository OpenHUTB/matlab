function totalRemoved=removeRefs(doctype)

















    disp(getString(message('Slvnv:rmiref:removeRefs:RemovingRefs')));
    if nargin==0
        doctype=input(getString(message('Slvnv:rmiref:removeRefs:PleaseSpecifyType')),'s');
        if isempty(doctype)
            return
        end
    end

    doctype=convertStringsToChars(doctype);

    switch lower(doctype)
    case 'word'
        totalRemoved=word_remove_refs();
    case 'excel'
        totalRemoved=excel_remove_refs();
    case 'doors'
        totalRemoved=doors_remove_refs();
    otherwise
        error(message('Slvnv:rmiref:removeRefs:InvalidDoctype',doctype));
    end
end

function totalRemoved=excel_remove_refs()
    [currentDoc,~,hDoc]=rmiref.ExcelUtil.getCurrentDoc();
    currentDoc=standard_path(currentDoc);
    allShapes=hDoc.ActiveSheet.Shapes;
    [isSLRef,isMcRef]=markSLRefs(allShapes);
    totalRefs=sum(isSLRef)+sum(isMcRef);
    if totalRefs>0
        disp(getString(message('Slvnv:rmiref:removeRefs:CurrentDoc',currentDoc)));
        disp(getString(message('Slvnv:rmiref:removeRefs:TotalRefs',totalRefs)));
        msg=getString(message('Slvnv:rmiref:removeRefs:RemoveAllQuestion'));
        reply=lower(input(msg,'s'));
        totalRemoved=0;
        if~isempty(reply)&&strncmp(reply(1),'y',1)
            fprintf(1,'    Removing ...\n');
            for idx=allShapes.Count:-1:1
                if isSLRef(idx)||isMcRef(idx)
                    try
                        allShapes.Item(idx).Delete;
                        totalRemoved=totalRemoved+1;
                    catch Mex
                        warning(message('Slvnv:rmiref:removeRefs:RemoveSimulinkReferenceFailed',Mex.message));
                    end
                end
            end
        end
    else
        disp(getString(message('Slvnv:rmiref:removeRefs:NoRefsIn',currentDoc)));
        totalRemoved=0;
    end
end

function totalRemoved=word_remove_refs()
    [currentDoc,~,hDoc]=rmiref.WordUtil.getCurrentDoc();
    currentDoc=standard_path(currentDoc);
    allShapes=hDoc.InlineShapes();

    [isSLRef,isMcRef]=markSLRefs(allShapes);
    totalRefs=sum(isSLRef)+sum(isMcRef);
    if totalRefs>0
        disp(getString(message('Slvnv:rmiref:removeRefs:CurrentDoc',currentDoc)));
        disp(getString(message('Slvnv:rmiref:removeRefs:TotalRefs',totalRefs)));
        msg=getString(message('Slvnv:rmiref:removeRefs:RemoveAllQuestion'));
        reply=lower(input(msg,'s'));
        totalRemoved=0;
        if~isempty(reply)&&strncmp(reply(1),'y',1)
            fprintf(1,'    Removing ...\n');
            for idx=allShapes.Count:-1:1
                if isSLRef(idx)||isMcRef(idx)
                    try
                        allShapes.Item(idx).Delete;
                        totalRemoved=totalRemoved+1;
                    catch Mex
                        warning(message('Slvnv:rmiref:removeRefs:RemoveSimulinkReferenceFailed',Mex.message));
                    end
                end
            end
        end
    else
        disp(getString(message('Slvnv:rmiref:removeRefs:NoRefsIn',currentDoc)));
        totalRemoved=0;
    end
end

function[isSlRef,isMcRef]=markSLRefs(objects)
    isSlRef=false(1,objects.Count);
    isMcRef=false(1,objects.Count);
    for i=1:objects.Count
        try
            oleFormat=objects.Item(i).OLEFormat;
            if any(strcmp(oleFormat.ProgID,{'mwSimulink1.SLRefButton','mwSimulink.SLRefButton','mwSimulink2.SLRefButtonA'}))
                isSlRef(i)=true;
            end
        catch Mex %#ok<NASGU>

            try
                hyperlink=objects.Item(i).Hyperlink;
                if~isempty(hyperlink)
                    address=hyperlink.Address;
                    if strncmp(address,'http://localhost:31415/matlab/feval/rmiobjnavigate',50)||strncmp(address,'http://127.0.0.1:31415/matlab/feval/rmiobjnavigate',50)
                        isMcRef(i)=true;
                    end
                end
            catch ME %#ok<NASGU>

            end
        end
    end
end

function myPath=standard_path(myPath)
    myPath=lower(myPath);
    myPath=strrep(myPath,'\','/');
end

function totalRemoved=doors_remove_refs()
    doc=rmiref.DoorsUtil.getCurrentDoc();
    name=rmidoors.getModuleAttribute(doc,'FullName');
    disp(getString(message('Slvnv:rmiref:removeRefs:CurrentDocMore',doc,name)));
    refObjects=rmidoors.getModuleAttribute(doc,'SlRefObjects');
    totalRefs=size(refObjects,1);
    fprintf(1,'    Total references: %d\n',totalRefs);
    totalRemoved=0;
    if totalRefs>0
        msg=sprintf('    Remove all Simulink references? y/n ');
        reply=lower(input(msg,'s'));
        if~isempty(reply)&&strncmp(reply(1),'y',1)
            fprintf(1,'    Removing ...\n');
            for i=1:totalRefs
                rmidoors.removeObject(doc,refObjects{i,1});
                totalRemoved=totalRemoved+1;
            end
        end
    end
end
