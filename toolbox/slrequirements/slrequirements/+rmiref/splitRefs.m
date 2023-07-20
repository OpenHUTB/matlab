function totalRemoved=splitRefs(doctype)


















    disp(getString(message('Slvnv:rmiref:splitRefs:SplittingMultiTarget')));
    if nargin==0
        doctype=input(getString(message('Slvnv:rmiref:splitRefs:PleaseSpecifyType')),'s');
        if isempty(doctype)
            return
        end
    end

    rmiref.cachedSettings('reset');

    switch lower(doctype)
    case 'word'
        totalRemoved=word_split_refs();
    case 'excel'
        totalRemoved=excel_split_refs();
    case 'doors'
        totalRemoved=doors_split_refs();
    otherwise
        error(message('Slvnv:rmiref:splitRefs:InvalidDoctype',doctype));
    end
end

function totalSplit=excel_split_refs()
    [currentDoc,~,hDoc]=rmiref.ExcelUtil.getCurrentDoc();
    currentDoc=standard_path(currentDoc);
    rmiref.ExcelUtil.insertions('reset');
    allObjects=hDoc.ActiveSheet.OLEObjects;
    isSLRef=markSLRefs(allObjects,'excel');
    totalRefs=sum(isSLRef);
    disp(getString(message('Slvnv:rmiref:splitRefs:CurrentDoc',currentDoc)));
    disp(getString(message('Slvnv:rmiref:splitRefs:TotalRefs',totalRefs)));
    totalSplit=0;
    fprintf(1,'    Splitting ...\n');
    for idx=allObjects.Count:-1:1
        if isSLRef(idx)
            try
                totalSplit=totalSplit+excel_split(hDoc,allObjects.Item(idx));
            catch Mex
                warning(message('Slvnv:reqmgt:splitRefs:SplitSimulinkReferenceFailed',Mex.message));
            end
        end
    end
end

function split=excel_split(hDoc,Item)
    split=0;
    Object=Item.Object;
    evalString=Object.MLEvalString;
    tooltipString=Object.ToolTipString;
    if strncmp(evalString,'rmiobjnavigate',length('rmiobjnavigate'))
        locCommand=strrep(evalString,'rmiobjnavigate','split_targets');
        targets=eval(locCommand);
        if length(targets)>1
            tooltips=split_tooltip(tooltipString,targets{1});

            targetCell=Item.TopLeftCell;
            for i=1:length(targets)
                navcmd=['rmiobjnavigate(',targets{i},');'];
                rmiref.ExcelUtil.insertInCell(hDoc,targetCell,navcmd,tooltips{i});
            end
            Item.Delete;
            split=1;
        end
    end
end

function tooltips=split_tooltip(tooltipString,oneTarget)

    parts=eval(['{',oneTarget,'}']);
    [~,mdlName]=fileparts(parts{1});
    idx=strfind(tooltipString,mdlName);

    tooltips=cell(length(idx),1);
    for i=1:length(idx)
        if i<length(idx)
            tooltips{i}=tooltipString(idx(i):idx(i+1)-3);
        else
            tooltips{i}=tooltipString(idx(i):end);
        end
    end
end

function targets=split_targets(varargin)
    if nargin<2
        targets=[];
    else
        mdl=varargin{1};
        guid=varargin{2};
        target=['''',mdl,''',''',guid,''''];
        next=3;
        if nargin>2&&isa(varargin{3},'double')
            target=[target,',',num2str(varargin{3})];
            next=4;
        end
        targets=[{target};split_targets(mdl,varargin{next:end})];
    end
end

function totalSplit=word_split_refs()
    [currentDoc,~,hDoc]=rmiref.WordUtil.getCurrentDoc();
    currentDoc=standard_path(currentDoc);
    allShapes=hDoc.InlineShapes();
    isSLRef=markSLRefs(allShapes,'word');
    totalRefs=sum(isSLRef);
    disp(getString(message('Slvnv:rmiref:splitRefs:CurrentDoc',currentDoc)));
    disp(getString(message('Slvnv:rmiref:splitRefs:TotalRefs',totalRefs)));
    totalSplit=0;
    fprintf(1,'    Splitting ...\n');
    for idx=allShapes.Count:-1:1
        if isSLRef(idx)
            try
                totalSplit=totalSplit+word_split(hDoc,allShapes.Item(idx));
            catch Mex
                warning(message('Slvnv:reqmgt:splitRefs:SplitSimulinkReferenceFailed',Mex.message));
            end
        end
    end
end

function split=word_split(hDoc,Item)
    split=0;
    Object=Item.OLEFormat.Object;
    evalString=Object.MLEvalString;
    tooltipString=Object.ToolTipString;
    if strncmp(evalString,'rmiobjnavigate',length('rmiobjnavigate'))
        locCommand=strrep(evalString,'rmiobjnavigate','split_targets');
        targets=eval(locCommand);
        if length(targets)>1
            tooltips=split_tooltip(tooltipString,targets{1});

            actxId='mwSimulink2.SLRefButtonA';
            bitmap=rmi.settings_mgr('get','linkSettings','slrefUserBitmap');
            Item.Select;
            hSelection=hDoc.ActiveWindow.Selection;
            hSelection.Collapse(0);
            for i=1:length(targets)
                navcmd=['rmiobjnavigate(',targets{i},');'];
                rmiref.WordUtil.insertActxButton(hDoc,hSelection,actxId,bitmap,navcmd,tooltips{i});
                hSelection.Collapse(0);
            end
            Item.Delete;
            split=1;
        end
    end
end

function flags=markSLRefs(objects,type)
    flags=false(1,objects.Count);
    for i=1:objects.Count
        try
            switch type
            case 'word'
                oleFormat=objects.Item(i).OLEFormat;
            case 'excel'
                oleFormat=objects.Item(i);
            end
            if any(strcmp(oleFormat.ProgID,{'mwSimulink1.SLRefButton','mwSimulink.SLRefButton','mwSimulink2.SLRefButtonA'}))
                flags(i)=true;
            end
        catch Mex %#ok<NASGU>

        end
    end
end

function myPath=standard_path(myPath)
    myPath=lower(myPath);
    myPath=strrep(myPath,'\','/');
end

function totalSplit=doors_split_refs()
    doc=rmiref.DoorsUtil.getCurrentDoc();
    name=rmidoors.getModuleAttribute(doc,'FullName');
    disp(getString(message('Slvnv:rmiref:splitRefs:CurrentDocMore',doc,name)));
    refObjects=rmidoors.getModuleAttribute(doc,'SlRefObjects');
    totalRefs=size(refObjects,1);
    fprintf(1,'    Total references: %d\n',totalRefs);
    totalSplit=0;
    fprintf(1,'    Splitting ...\n');
    for i=1:totalRefs
        totalSplit=totalSplit+doors_split(doc,refObjects{i,1});
    end
end

function split=doors_split(doc,objId)
    split=0;
    evalString=rmidoors.getObjAttribute(doc,objId,'DmiSlNavCmd');
    locCommand=strrep(evalString,'rmiobjnavigate','split_targets');
    targets=eval(locCommand);
    if length(targets)>1
        tooltipString=rmidoors.getObjAttribute(doc,objId,'Object Text');
        tooltips=split_tooltip(tooltipString,targets{1});

        navcmd=['rmiobjnavigate(',targets{1},');'];
        rmidoors.setObjAttribute(doc,objId,'DmiSlNavCmd',navcmd);
        labelStr=['[Simulink reference: ',tooltips{1},']'];
        rmidoors.setObjAttribute(doc,objId,'Object Text',labelStr);
        iconPath=rmi.settings_mgr('get','linkSettings','slrefUserBitmap');
        if isempty(iconPath)
            iconPath=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','slicon.bmp');
        end
        for i=2:length(targets)
            navcmd=['rmiobjnavigate(',targets{i},');'];
            labelStr=['[Simulink reference: ',tooltips{i},']'];
            rmidoors.addLinkObj(doc,objId,iconPath,labelStr,navcmd);
        end
        split=1;
    end
end
