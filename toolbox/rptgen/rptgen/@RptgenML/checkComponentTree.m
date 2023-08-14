function errMsg=checkComponentTree(this,thisChild)










    errMsg='';

    thisContentType=this.getContentType;
    if isempty(thisContentType)
        thisParent=this.up;
        if isa(thisParent,'rptgen.rptcomponent')
            errMsg=checkComponentTree(thisParent,thisChild);
        end
        return;
    end

    childContentType=thisChild.getContentType;

    contentTypes={
'set'
'book'
'section'
'titlepage'
'paragraph'
'table'
'text'
''
    };

    thisContentIdx=find(strcmp(contentTypes,thisContentType));
    if isempty(thisContentIdx)
        thisContentIdx=length(contentTypes);
    else
        thisContentIdx=thisContentIdx(1);
    end

    childContentIdx=find(strcmp(contentTypes,childContentType));
    if isempty(childContentIdx)
        childContentIdx=length(contentTypes);
    else
        childContentIdx=childContentIdx(1);
    end

    canContain=[
    1,0,0,0,0,0,0,1
    0,0,1,1,0,0,0,1
    0,0,1,1,1,1,0,1
    0,0,0,0,0,0,0,1
    0,0,0,0,0,1,1,1
    0,0,0,0,1,1,1,1
    0,0,0,0,0,0,1,1
    1,1,1,1,1,1,1,1
    ];






    if(~canContain(thisContentIdx,childContentIdx))

        childName=loc_getShortDisplayLabel(thisChild);
        okParents=contentTypes(logical(canContain(1:end-1,childContentIdx)));
        okParentsCount=length(okParents);

        if(okParentsCount==0)
            okParentsString='';

        elseif(okParentsCount==1)
            okParentsString=okParents{1};

        elseif(okParentsCount==2)
            okParentsString=getString(message('rptgen:RptgenML:okParentsTwo',okParents{1},okParents{2}));

        else
            okParentsString=[okParents{1},','];
            for i=2:okParentsCount-1
                okParentsString=getString(message('rptgen:RptgenML:okParentsMany',okParentsString,okParents{i}));
            end

            okParentsString=getString(message('rptgen:RptgenML:okParentsTwo',okParentsString,okParents{end}));

        end

        rptgen.makeSingleLineText(okParents,' | ');
        errMsg=getString(message('rptgen:RptgenML:invalidChildMsg',...
        loc_getShortDisplayLabel(this),thisContentType,...
        childName,childContentType,...
        childName,okParentsString));

    elseif(isa(thisChild,'rptgen.cfr_titlepage'))

        parentDoc=loc_getParentDocument(thisChild);


        topLevelSections=find(parentDoc,...
        '-isa','rptgen.rpt_section',...
        'Active',true,...
        '-not','ObjectSection',false,...
        '-not','-isa','rptgen.coutline');%#ok<GTARG>

        if(isempty(topLevelSections))
            errMsg=getString(message('rptgen:RptgenML:chaptersRequiredLabel',...
            loc_getShortDisplayLabel(thisChild),thisContentType));
        end
    end


    function dLabel=loc_getShortDisplayLabel(c)

        try
            dLabel=getDisplayLabel(c);
            dashIdx=strfind(dLabel,' -');
            if~isempty(dashIdx)
                dLabel=dLabel(1:dashIdx-1);
            end
        catch ex %#ok<NASGU>
            try
                dLabel=getName(c);
            catch ex2 %#ok<NASGU>
                dLabel=class(c);
            end
        end


        function parentDoc=loc_getParentDocument(child)

            parentDoc=rptgen.findRpt(child);
