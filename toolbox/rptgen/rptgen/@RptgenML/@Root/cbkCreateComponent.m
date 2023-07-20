function cMaker=cbkCreateComponent(this,cMaker)






    if(nargin<2)
        cMaker=RptgenML.ComponentMaker;

    elseif isa(cMaker,'RptgenML.ComponentMaker')


    elseif(ischar(cMaker)...
        &&(strcmp(cMaker,'-browse')||strcmp(cMaker,'-v2browse')))

        v2Name=RptgenML.compdlg(...
        'Name',getString(message('rptgen:RptgenML_Root:createComponentLabel')),...
        'PromptString',getString(message('rptgen:RptgenML_Root:deriveComponentLabel')));

        if isempty(v2Name)
            cMaker=[];
            return
        end
        try
            v2Component=feval(v2Name);
        catch ex %#ok<NASGU>
            v2Component=[];
        end
        if~isa(v2Component,'rptgen.rptcomponent')
            warning(message('rptgen:RptgenML_Root:nonexistentComponent',v2Name));
            return
        end
        cMaker=RptgenML.ComponentMaker(v2Component);

    else
        cMaker=RptgenML.ComponentMaker(cMaker);
    end

    if isempty(down(this))
        connect(cMaker,this,'up');
    else
        connect(cMaker,down(this),'right');
    end

    LocResolvePackage(cMaker);

    e=this.getEditor;

    ime=DAStudio.imExplorer(e);
    ime.expandTreeNode(cMaker);

    e.view(cMaker);


    function cList=LocParseRegistry(filename)

        xmlDoc=xmlread(filename);
        compListArray=xmlDoc.getElementsByTagName('c');

        nComps=compListArray.getLength;
        cList=cell(nComps,1);
        for i=1:nComps
            cList{i}=char(compListArray.item(i-1).getTextContent);
        end





        function LocResolvePackage(component)

            dirInfo=what(['@',component.PkgName]);

            if(~isempty(dirInfo))
                [component.PkgDir,component.PkgName]=fileparts(dirInfo.path);
            end
