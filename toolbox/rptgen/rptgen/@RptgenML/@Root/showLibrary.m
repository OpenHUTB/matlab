function varargout=showLibrary(this)






    if isempty(this.Library)
        this.Library=RptgenML.Library;
        buildComponentLibrary(this.Library);
        if isa(this.Editor,'DAStudio.Explorer')
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('ListChangedEvent',this.getCurrentComponent);
        end
    end

    if(nargout>0)
        varargout{1}=this.Library;
    end


    function buildComponentLibrary(libH)



        allCategories=libH.find('-depth',1,'-isa','RptgenML.LibraryCategory');
        for i=1:length(allCategories)
            disconnect(allCategories(i));
            delete(allCategories(i));
        end

        parser=matlab.io.xml.dom.Parser;


        allRegistries=which('rptcomps2.xml','-all');
        for i=1:length(allRegistries)
            try
                thisRegistry=parser.parseFile(allRegistries{i});
                useMsgId=strcmpi(locSafeGetAttribute(thisRegistry.getDocumentElement(),'use_msgid'),'true');
                processCategories(libH,thisRegistry,useMsgId);

            catch ME
                warning(message('rptgen:RptgenML_Root:cannotParseRegistry',...
                allRegistries{i},ME.message));
            end
        end


        function processCategories(libH,thisRegistry,useMsgId)

            thisCategory=thisRegistry.getDocumentElement.getFirstChild;
            while~isempty(thisCategory)
                if(isa(thisCategory,'matlab.io.xml.dom.Element')&&...
                    strcmp(thisCategory.getTagName(),'category'))

                    try
                        cType=char(thisCategory.getAttribute('name'));
                    catch ME %#ok
                        cType='Unknown Category';
                    end

                    if~isempty(cType)
                        cType=getTranslatedName(cType,useMsgId);
                        cCategory=libH.find('-depth',1,'CategoryName',cType);
                        if isempty(cCategory)
                            cCategory=RptgenML.LibraryCategory(cType);
                            connectAlphabetical(libH,cCategory,'CategoryName');
                        end

                        helpMapFile=locSafeGetAttribute(thisCategory,'HelpMapFile');
                        cCategory.helpMapFile=helpMapFile;

                        helpMapKey=locSafeGetAttribute(thisCategory,'HelpMapKey');
                        cCategory.HelpMapKey=helpMapKey;

                        helpHtmlFile=locSafeGetAttribute(thisCategory,'HelpHtmlFile');
                        cCategory.HelpHtmlFile=helpHtmlFile;

                    else
                        cCategory=[];

                    end

                    processComponents(thisCategory,cCategory,useMsgId)
                end

                thisCategory=thisCategory.getNextSibling;
            end


            function processComponents(thisCategory,cCategory,useMsgId)

                thisComponent=thisCategory.getFirstChild;
                while~isempty(thisComponent)
                    if(isa(thisComponent,'matlab.io.xml.dom.Element')&&...
                        strcmp(thisComponent.getTagName(),'component'))

                        cClass=locSafeGetAttribute(thisComponent,'class');

                        if~isempty(cClass)
                            if~isempty(cCategory)

                                cName=locSafeGetAttribute(thisComponent,'name');
                                if isempty(cName)
                                    cName=cClass;
                                end
                                cName=getTranslatedName(cName,useMsgId);

                                cComponent=RptgenML.LibraryComponent(cClass,cName);
                                connectAlphabetical(cCategory,cComponent,'DisplayName');

                                helpMapFile=locSafeGetAttribute(thisComponent,'HelpMapFile');
                                cComponent.helpMapFile=helpMapFile;

                                helpMapKey=locSafeGetAttribute(thisComponent,'HelpMapKey');
                                cComponent.HelpMapKey=helpMapKey;

                                helpHtmlFile=locSafeGetAttribute(thisComponent,'HelpHtmlFile');
                                cComponent.HelpHtmlFile=helpHtmlFile;

                            end
                            processLegacy(thisComponent,cClass);
                        end

                    end
                    thisComponent=thisComponent.getNextSibling;
                end


                function name=getTranslatedName(name,useMsgId)

                    if useMsgId
                        try
                            name=getString(message(name));
                        catch ME
                            warning(message('rptgen:RptgenML_LibraryComponent:cannotGetComponentName',...
                            name,...
                            ME.message));
                        end
                    end


                    function processLegacy(thisComponent,classV2)

                        thisLegacy=thisComponent.getFirstChild;
                        while~isempty(thisLegacy)
                            if(isa(thisLegacy,'matlab.io.xml.dom.Element')&&...
                                strcmp(thisLegacy.getTagName(),'component_v1'))

                                classV1=locSafeGetAttribute(thisLegacy,'class');
                                if~isempty(classV1)
                                    try
                                        mlreportgen.re.internal.tools.LegacyConversion.put(classV1,classV2);
                                    catch
                                        sprintf('Legacy\t%16s\t%16s\n',char(classV1),classV2);
                                    end
                                end
                            end
                            thisLegacy=thisLegacy.getNextSibling;
                        end


                        function connectAlphabetical(hParent,hNew,propName)






                            compareChild=hParent.down;
                            while~isempty(compareChild)
                                if issorted({get(hNew,propName),get(compareChild,propName)})
                                    connect(hNew,compareChild,'right')
                                    return
                                else
                                    compareChild=compareChild.right;
                                end
                            end

                            connect(hNew,hParent,'up');



                            function attributeValue=locSafeGetAttribute(this,attributeName)

                                try
                                    attributeValue=char(this.getAttribute(attributeName));
                                catch ME %#ok
                                    attributeValue='';
                                end


