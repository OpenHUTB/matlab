

function filesList=getFilesWithNavigationInfo(xml_navig_file)

    filesList=cell(1,0);
    if exist(xml_navig_file,'file')
        try
            parser=matlab.io.xml.dom.Parser;
            xmlDoc=parser.parseFile(xml_navig_file);
            xmlData=xmlDoc.getDocumentElement();
            filesSections=xmlData.getElementsByTagName('Files');
            i_files_section=0;
            while i_files_section<filesSections.getLength()
                filesSection=filesSections.item(i_files_section);
                fileNodes=filesSection.getElementsByTagName('F');
                i_node=0;
                while i_node<fileNodes.getLength()
                    fileNode=fileNodes.item(i_node);
                    if fileNode.hasAttribute('n')
                        fileName=fileNode.getAttribute('n');
                        fileName=polyspace.internal.getAbsolutePath(fileName);

                        filesList{1,end+1}=fileName;%#ok<AGROW>
                    end
                    i_node=i_node+1;
                end
                i_files_section=i_files_section+1;
            end
        catch Me %#ok<NASGU>
        end
    end

