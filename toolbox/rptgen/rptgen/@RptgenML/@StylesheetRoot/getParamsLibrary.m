function varargout=getParamsLibrary(this,transformType,libAction)




    if(nargin<3)
        libAction='';
    end

    if isa(transformType,'RptgenML.StylesheetEditor')
        transformType=transformType.TransformType;
    end

    pLib=locGetLibrary(this,transformType);

    if isempty(pLib)||~isa(pLib,'RptgenML.Library')

        switch lower(libAction)
        case '-asynchronous'
            pLib=RptgenML.Message(getString(message('rptgen:RptgenML_StylesheetRoot:searchingLabel')),...
            getString(message('rptgen:RptgenML_StylesheetRoot:buildingParameterListLabel')));
            mlreportgen.utils.internal.defer(@()this.getParamsLibrary(transformType,'-deferred'));

        case '-deferred'
            pLib=locBuildLibrary(this,transformType);


            locRefreshListView();

        case '-clear'
            pLib=[];
            locSetLibrary(this,transformType,pLib);

        case '-nobuild'



        otherwise
            pLib=locBuildLibrary(this,transformType);

        end
    end

    if(nargout>0)
        varargout={pLib};
    end


    function pLib=locBuildLibrary(this,transformType)

        pLib=RptgenML.Library(['param_',transformType]);
        if rptgen.use_java
            scp=com.mathworks.toolbox.rptgen.xml.StylesheetCustomizationParser.getParser(transformType);
        else
            scp=mlreportgen.re.internal.ui.StylesheetCustomizationParser.getParser(transformType);
        end

        catEl=scp.findFirstCategory;
        while~isempty(catEl)


            libCat=RptgenML.LibraryCategory(...
            char(scp.getCategoryName),...
            'HelpMapFile',RptgenML.getHelpMapfile,...
            'HelpMapKey',['category.StylesheetElement.',transformType]);
            connect(libCat,pLib,'up');


            docEl=scp.findFirstParameter;
            while~isempty(docEl)
                if scp.getParamVisible
                    try
                        ssData=RptgenML.createStylesheetElement([],scp);
                    catch %#ok
                        ssData=[];
                    end
                    if~isempty(ssData)
                        connect(ssData,libCat,'up');
                    end
                end
                docEl=scp.findNextParameter;
            end

            catEl=scp.findNextCategory;
        end

        locSetLibrary(this,transformType,pLib);


        function locRefreshListView()

            r=RptgenML.Root;
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('ListChangedEvent',r.getCurrentTreeNode);


            function pLib=locGetLibrary(this,transformType)

                propName=['Params',transformType];
                pLib=get(this,propName);


                function locSetLibrary(this,transformType,pLib)

                    propName=['Params',transformType];
                    set(this,propName,pLib);


