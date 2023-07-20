function styleSheetInfo=getDSSSLStylesheetInfo(this,formatInfo)





    styleSheetInfo=LocSheetInfo(this,formatInfo);
    styleSheetInfo.sourcename=this.SrcFileName;
    styleSheetInfo.reportname=this.DstFileName;

    rg=rptgen.appdata_rg;
    styleSheetInfo.Language=rg.Language;


    function mySheet=LocSheetInfo(this,~)


        styleName=this.StylesheetDSSSL;
        if rptgen.use_java
            ext=char(com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.FILE_EXT_SS);
        else
            ext=mlreportgen.re.internal.db.StylesheetMaker.FILE_EXT_SS;
        end

        ssFile=rptgen.findFile([styleName,ext]);

        if isempty(ssFile)
            sheets=stylesheets();
            sheetIndex=find(strcmpi({sheets(:).ID},styleName));
        else
            sheets=stylesheets(ssFile);
            if isempty(sheets)
                sheetIndex=[];
            else
                sheetIndex=1;
            end
        end

        if~isempty(sheetIndex)
            mySheet=sheets(sheetIndex(1));
        else
            mySheet=struct('Name','NoSheet',...
            'ID','',...
            'Formats',{{}},...
            'Description','',...
            'Filename','',...
            'Variables',{{}},...
            'Overlays',{{}});
        end


        function allSheets=stylesheets(regfiles)



            if(nargin==0)
                regfiles=which('rptstylesheets.xml','-all');
            elseif ischar(regfiles)
                regfiles={regfiles};
            end

            allSheets=[];
            for i=1:length(regfiles)
                try
                    allSheets=[allSheets,LocProcessFile(regfiles{i})];%#ok
                catch ME
                    warning(ME.message);
                end
            end
            if~isempty(allSheets)
                [~,uniqueIndex]=unique({allSheets.ID});
                allSheets=allSheets(uniqueIndex);
            end


            function isElement=locIsElement(node)
                if rptgen.use_java
                    isElement=isa(node,'org.w3c.dom.Element');
                else
                    isElement=isa(node,'matlab.io.xml.dom.Element');
                end


                function nodeText=locGetNodeText(node)
                    if rptgen.use_java
                        nodeText=char(com.mathworks.toolbox.rptgencore.tools.RgXmlUtils.getNodeText(node));%#ok
                    else
                        nodeText=getTextContent(node);
                    end


                    function sheetStruct=LocProcessFile(filename)

                        sheetStruct=[];

                        filename=char(com.mathworks.util.FileUtils.getLocalizedFilename(filename));

                        if rptgen.use_java
                            doc=xmlread(filename);
                        else
                            doc=parseFile(matlab.io.xml.dom.Parser,filename);
                        end

                        regList=doc.getElementsByTagName('registry');

                        for regIdx=0:regList.getLength-1




                            fileEntities=cell(0,2);

                            currNode=regList.item(regIdx).getFirstChild;
                            while~isempty(currNode)

                                if locIsElement(currNode)
                                    switch(char(currNode.getTagName))
                                    case 'fileentities'
                                        fileEntities=locFileExtract(currNode);
                                    case 'stylesheet'


                                        sheetStruct=[sheetStruct,locProcessStylesheet(currNode,fileEntities)];%#ok
                                    end
                                end
                                currNode=currNode.getNextSibling;
                            end
                        end


                        function sheet=locProcessStylesheet(sheetNode,fileEntities)

                            sheet=struct('Name','',...
                            'ID','',...
                            'Formats',[],...
                            'Description','',...
                            'Filename','',...
                            'Variables',[],...
                            'Overlays',[]);

                            currNode=sheetNode.getFirstChild;
                            while~isempty(currNode)
                                if locIsElement(currNode)
                                    switch(char(currNode.getTagName))
                                    case 'name'
                                        sheet.Name=locGetNodeText(currNode);
                                    case 'ID'
                                        sheet.ID=locGetNodeText(currNode);
                                    case 'validformats'
                                        sheet.Formats=locFormatExtract(currNode);
                                    case 'description'
                                        sheet.Description=locGetNodeText(currNode);
                                    case 'fileref'
                                        sheet.Filename=locFileReference(currNode,fileEntities);
                                    case 'variables'
                                        sheet.Variables=locVariablesExtract(currNode);
                                    case 'dsssl'
                                        allOverlays={};
                                        childNode=currNode.getFirstChild;
                                        while~isempty(childNode)
                                            if locIsElement(childNode)

                                                allOverlays{end+1}=locFileReference(childNode,fileEntities);%#ok
                                            end
                                            childNode=childNode.getNextSibling;
                                        end
                                        sheet.Overlays=allOverlays;
                                    end
                                end
                                currNode=currNode.getNextSibling;
                            end


                            function allFmt=locFormatExtract(fmtNode)

                                allFmt={};
                                currNode=fmtNode.getFirstChild;
                                while~isempty(currNode)
                                    if locIsElement(currNode)

                                        fmt=locGetNodeText(currNode);
                                        if strcmp(fmt,'$stdprint$')
                                            stdFormats={'RTF95','RTF97','fot','pdf'};
                                            allFmt={allFmt{:},stdFormats{:}};%#ok<CCAT>
                                        else
                                            allFmt={allFmt{:},fmt};%#ok<CCAT>
                                        end
                                    end
                                    currNode=currNode.getNextSibling;
                                end



                                function allFE=locFileExtract(feNode)

                                    allFE=cell(0,2);
                                    currNode=feNode.getFirstChild;
                                    while~isempty(currNode)
                                        if locIsElement(currNode)
                                            switch(char(currNode.getTagName))
                                            case 'refname'
                                                allFE{end+1,1}=locGetNodeText(currNode);%#ok
                                            case 'filename'
                                                fName='';
                                                childNode=currNode.getFirstChild;
                                                while~isempty(childNode)
                                                    if locIsElement(childNode)

                                                        thisChild=locGetNodeText(childNode);
                                                        if(strcmpi(thisChild,'$matlabroot$')||strcmpi(thisChild,'$approot$'))
                                                            fName=matlabroot();
                                                        else
                                                            fName=fullfile(fName,thisChild);
                                                        end
                                                    end
                                                    childNode=childNode.getNextSibling;
                                                end
                                                allFE{end,2}=fName;
                                            end
                                        end
                                        currNode=currNode.getNextSibling;
                                    end


                                    function allVars=locVariablesExtract(varNode)

                                        allVars=cell(0,2);
                                        varIdx=1;
                                        currNode=varNode.getFirstChild;
                                        while~isempty(currNode)
                                            if locIsElement(currNode)

                                                childNode=currNode.getFirstChild;
                                                while~isempty(childNode)
                                                    if locIsElement(childNode)
                                                        switch(char(childNode.getTagName))
                                                        case 'varname'
                                                            allVars{varIdx,1}=locGetNodeText(childNode);
                                                        case 'varvalue'
                                                            allVars{varIdx,2}=locGetNodeText(childNode);
                                                        end
                                                    end
                                                    childNode=childNode.getNextSibling;
                                                end
                                                varIdx=varIdx+1;
                                            end
                                            currNode=currNode.getNextSibling;
                                        end


                                        function fName=locFileReference(currNode,fileList)

                                            fileRef=locGetNodeText(currNode);

                                            if isempty(fileRef)
                                                fName='';
                                            else
                                                fileIdx=find(strcmpi(fileList(:,1),fileRef));
                                                if isempty(fileIdx)
                                                    fName='';
                                                    warning(message('rptgen:rx_db_output:noStyleSheetFound',fileRef));
                                                else
                                                    fName=fileList{fileIdx(1),2};
                                                end
                                            end