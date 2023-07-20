classdef XMLHandler<handle

    properties
xmlRootElement
    end

    methods(Access=private)
        function elementNode=createElementWithAttrib(this,docNode,elementName,attribNames,attribValues)
            elementNode=docNode.createElement(elementName);
            attribNames=cellstr(attribNames);
            attribValues=cellstr(attribValues);
            for i=1:numel(attribNames)
                elementNode.setAttribute(attribNames{i},attribValues{i});
            end
        end

        function elementNode=createElement(docNode,elementName)
            elementNode=docNode.createElement(elementName);
        end

        function mergedTileInfo=populateMergedTileInfo(this,mergedTileInfo)


            mergedTileInfo(1).TopLeftXY=[0,0];
            mergedTileInfo(1).HinNumRows=3;
            mergedTileInfo(1).WinNumCols=1;

            mergedTileInfo(2).TopLeftXY=[1,0];
            mergedTileInfo(2).HinNumRows=1;
            mergedTileInfo(2).WinNumCols=1;

            mergedTileInfo(3).TopLeftXY=[1,1];
            mergedTileInfo(3).HinNumRows=1;
            mergedTileInfo(3).WinNumCols=1;

            mergedTileInfo(4).TopLeftXY=[2,0];
            mergedTileInfo(4).HinNumRows=1;
            mergedTileInfo(4).WinNumCols=1;

            mergedTileInfo(5).TopLeftXY=[2,1];
            mergedTileInfo(5).HinNumRows=1;
            mergedTileInfo(5).WinNumCols=1;

            mergedTileInfo(6).TopLeftXY=[3,0];
            mergedTileInfo(6).HinNumRows=3;
            mergedTileInfo(6).WinNumCols=1;

            mergedTileInfo(7).TopLeftXY=[1,2];
            mergedTileInfo(7).HinNumRows=1;
            mergedTileInfo(7).WinNumCols=2;
        end



        function occupantInfo=populateOccupantInfo(this,occupantInfo)


            occupantInfo(1).Name='ROI Display';
            occupantInfo(1).InFront='yes';
            occupantInfo(1).TargetTileID_1D=0;

            occupantInfo(2).Name='Frame Display';
            occupantInfo(2).InFront='no';
            occupantInfo(2).TargetTileID_1D=0;

            occupantInfo(3).Name='city';
            occupantInfo(3).InFront='no';
            occupantInfo(3).TargetTileID_1D=1;

            occupantInfo(4).Name='highway';
            occupantInfo(4).InFront='no';
            occupantInfo(4).TargetTileID_1D=2;

            occupantInfo(5).Name='caltech';
            occupantInfo(5).InFront='no';
            occupantInfo(5).TargetTileID_1D=3;

            occupantInfo(6).Name='washington';
            occupantInfo(6).InFront='no';
            occupantInfo(6).TargetTileID_1D=4;

            occupantInfo(7).Name='Range Slider Display';
            occupantInfo(7).InFront='no';
            occupantInfo(7).TargetTileID_1D=6;
        end
    end
    methods
        function this=XMLHandler(xmlJavaStr)
            javaStr2DOMNode(this,xmlJavaStr);
        end

        function javaStr2DOMNode(this,xmlJavaStr)
            try

                inputObject=java.io.StringBufferInputStream(xmlJavaStr);
                try

                    parserFactory=javaMethod('newInstance','javax.xml.parsers.DocumentBuilderFactory');
                    p=javaMethod('newDocumentBuilder',parserFactory);
                    root=p.parse(inputObject);
                catch

                    root=xmlread(inputObject);
                end
            catch



                filename=[tempname,'.xml'];
                fid=fopen(filename,'Wt');
                fprintf(fid,'%s',xmlJavaStr);
                fclose(fid);


                root=xmlread(filename);


                delete(filename);
            end
            this.xmlRootElement=root.getDocumentElement;
        end

        function xmlString=createXML(this,rowHeights,colWidths,mergedTileInfo,occupantInfo)


























































            numRows=numel(rowHeights);
            numCols=numel(colWidths);
            numTiles=numel(mergedTileInfo);
            numOccupants=numel(occupantInfo);


            docNode=com.mathworks.xml.XMLUtils.createDocument('Tiling');
            rootNode=docNode.getDocumentElement;

            attribNames={'Columns','Count','EliminateEmpties','Rows'};
            attribValues={num2str(numCols),num2str(numTiles),'no',num2str(numRows)};
            tilesNode=createElementWithAttrib(this,docNode,'Tiles',attribNames,attribValues);
            rootNode.appendChild(tilesNode);


            for i=1:numCols
                columnNode=createElementWithAttrib(this,docNode,'Column','Weight',num2str(colWidths(i)));
                tilesNode.appendChild(columnNode);
            end


            for i=1:numRows
                rowNode=createElementWithAttrib(this,docNode,'Row','Weight',num2str(rowHeights(i)));
                tilesNode.appendChild(rowNode);
            end


            for i=1:numTiles
                attribNames={'Height','Width','X','Y'};

                numRowSpan=mergedTileInfo(i).HinNumRows;
                numColSpan=mergedTileInfo(i).WinNumCols;
                tileX_0b=mergedTileInfo(i).TopLeftXY(1);
                tileY_0b=mergedTileInfo(i).TopLeftXY(2);
                attribValues={num2str(numRowSpan),num2str(numColSpan),num2str(tileX_0b),num2str(tileY_0b)};
                tileNode=createElementWithAttrib(this,docNode,'Tile',attribNames,attribValues);
                tilesNode.appendChild(tileNode);
            end


            occupancyNode=createElement(docNode,'Occupancy');
            rootNode.appendChild(occupancyNode);

            for i=1:numOccupants
                attribNames={'InFront','Name','Tile'};

                name=occupantInfo(i).Name;
                isInFrontStr=occupantInfo(i).InFront;
                targetTileID_1D=occupantInfo(i).TargetTileID_1D;
                if iscell(name)&&(numel(name)==1)


                    name=name{1};
                end
                attribValues={isInFrontStr,name,num2str(targetTileID_1D)};

                occupantNode=createElementWithAttrib(this,docNode,'Occupant',attribNames,attribValues);
                occupancyNode.appendChild(occupantNode);
            end

            xmlString=xmlwrite(docNode);








        end

        function tf=isInFront(this,name)
            occupancyNodes=this.xmlRootElement.getElementsByTagName('Occupancy');
            occupancyNode_0=occupancyNodes.item(0);
            occupantNodes=occupancyNode_0.getElementsByTagName('Occupant');
            numOccupants=occupantNodes.getLength();

            tf=false;
            for i=1:numOccupants
                occupantNode_i=occupantNodes.item(i-1);
                occupantName_i=occupantNode_i.getAttribute('Name');
                if strcmp(occupantName_i,name)
                    isInFrontStr_i=occupantNode_i.getAttribute('InFront');
                    tf=strcmp(isInFrontStr_i,'yes');
                    return;
                end
            end
        end

        function tf=isLastTile_H1_W1_X1(this)
            tilesNodes=this.xmlRootElement.getElementsByTagName('Tiles');
            tilesNode_0=tilesNodes.item(0);
            tileNodes=tilesNode_0.getElementsByTagName('Tile');
            numTiles=tileNodes.getLength();
            tileNode_end=tileNodes.item(numTiles-1);
            height=str2double(char(tileNode_end.getAttribute('Height')));
            width=str2double(char(tileNode_end.getAttribute('Width')));
            x=str2double(char(tileNode_end.getAttribute('X')));
            tf=(height==1)&&(width==1)&&(x==1);
        end

        function tf=isTile_Hfull_W1_XendGE2Y0(this,tileId,numRows,numCols)
            tilesNodes=this.xmlRootElement.getElementsByTagName('Tiles');
            tilesNode_0=tilesNodes.item(0);
            tileNodes=tilesNode_0.getElementsByTagName('Tile');
            numTiles=tileNodes.getLength();

            if(tileId<0)||(tileId>=numTiles)
                tf=false;
                return;
            end

            thisTileNode=tileNodes.item(tileId);

            thisTileNode_H=str2double(char(thisTileNode.getAttribute('Height')));
            thisTileNode_W=str2double(char(thisTileNode.getAttribute('Width')));
            thisTileNode_X=str2double(char(thisTileNode.getAttribute('X')));
            thisTileNode_Y=str2double(char(thisTileNode.getAttribute('Y')));

            tf=(thisTileNode_H==numRows)&&...
            (thisTileNode_W==1)&&...
            ((numCols>=3)&&(thisTileNode_X==(numCols-1)))&&...
            (thisTileNode_Y==0);

        end

        function tf=isTileOccupiedByNoneOther(this,tileId,name1,name2)
            occupancyNodes=this.xmlRootElement.getElementsByTagName('Occupancy');
            occupancyNode_0=occupancyNodes.item(0);
            occupantNodes=occupancyNode_0.getElementsByTagName('Occupant');
            numOccupants=occupantNodes.getLength();

            tf=true;
            for i=0:(numOccupants-1)
                occupantNode_i=occupantNodes.item(i);

                occupantTileId_i=str2double(char(occupantNode_i.getAttribute('Tile')));
                if(occupantTileId_i==tileId)
                    occupantName_i=occupantNode_i.getAttribute('Name');
                    if strcmp(occupantName_i,name1)||strcmp(occupantName_i,name2)
                        tf=true;
                    else
                        tf=false;
                        return;
                    end
                end
            end
        end

        function tf=isLastOccupant(this,name)
            occupancyNodes=this.xmlRootElement.getElementsByTagName('Occupancy');
            occupancyNode_0=occupancyNodes.item(0);
            occupantNodes=occupancyNode_0.getElementsByTagName('Occupant');
            numOccupants=occupantNodes.getLength();
            if(numOccupants==0)
                tf=true;
                return;
            end
            occupantNode_end=occupantNodes.item(numOccupants-1);
            endOccupantName=occupantNode_end.getAttribute('Name');
            tf=strcmp(endOccupantName,name);
        end

















































        function changeLayout(xmlJavaStr,numRows,numCols,numTiles)
            javaStr2DOMNode(this,xmlJavaStr);
            tilesNodes=this.xmlRootElement.getElementsByTagName('Tiles');
            assert(tilesNodes.getLength()==1);
            tilesNode0=tilesNodes.item(0);

            adjustNumRowTag(this,tilesNode0,numRows,rowHeight)


            tilesNode0.setAttribute('Rows',num2str(numRows));
            tilesNode0.setAttribute('Columns',num2str(numCols));
            tilesNode0.setAttribute('Count',num2str(numTiles));

            columnNodes=tilesNode0.getElementsByTagName('Column');
            rowNodes=tilesNode0.getElementsByTagName('Row');






            this.xmlRootElement.normalize();
        end





        function appendRowTag(this,rowNodes)
            newRowNode=this.xmlRootElement.createElement("Row");
            newRowAttrib=this.xmlRootElement.createAttribute("Weight");
            newRowNode.appendChild(newRowAttrib);

            rowNodes.getparent().appendChild(newRowNode);
        end

        function removeRowTag(this,rowNodes)

            nodeToBeRemoved=rowNodes.item(0);
            rowNodes.getparent().removeChild(nodeToBeRemoved);
        end

        function setRowHeight(this,rowNodes,rowWidths)
            for i=1:rowNodes.getLnegth()
                rowNode_i=rowNodes.item(i-1);
                rowNode_i.setAttribute('Weight',num2str(rowWidths(i)));
            end
        end

        function adjustNumRowTag(this,tilesNode0,numRows,rowHeights)

            curNumRows=tilesNode0.getAttribute('Rows');

            if curNumRows==numRows
                return
            else
                tilesNode0.setAttribute('Rows',num2str(numRows));
                rowNodes=tilesNode0.getElementsByTagName('Row');
                assert(rowNodes.getLength()==numRows);
                if curNumRows<numRows
                    for i=1:(numRows-curNumRows)
                        appendRowTag(this,rowNodes)
                    end
                else
                    for i=1:(curNumRows-numRows)
                        removeRowTag(this,rowNodes)
                    end
                end
                setRowHeight(this,rowNodes,rowHeights);
            end
        end

        function setRowsCols(this,numRows,numCols)
            this.xmlRootElement.getElementsByTagName('Tiles').item(0).setAttribute('Rows',num2str(numRows));
            this.xmlRootElement.getElementsByTagName('Tiles').item(0).setAttribute('Columns',num2str(numCols));
            adjustNumRowTag(this,numRows);
            adjustNumColumnTag(this,numCols);
        end


        function children=parseChildNodes(theNode)

            children=[];
            if theNode.hasChildNodes
                childNodes=theNode.getChildNodes;
                numChildNodes=childNodes.getLength;
                allocCell=cell(1,numChildNodes);

                children=struct(...
                'Name',allocCell,'Attributes',allocCell,...
                'Data',allocCell,'Children',allocCell);

                for count=1:numChildNodes
                    theChild=childNodes.item(count-1);
                    children(count)=makeStructFromNode(theChild);
                end
            end
        end

        function nodeStruct=makeStructFromNode(theNode)


            nodeStruct=struct(...
            'Name',char(theNode.getNodeName),...
            'Attributes',parseAttributes(theNode),...
            'Data','',...
            'Children',parseChildNodes(theNode));

            if any(strcmp(methods(theNode),'getData'))
                nodeStruct.Data=char(theNode.getData);
            else
                nodeStruct.Data='';
            end

        end

        function attributes=parseAttributes(theNode)


            attributes=[];
            if theNode.hasAttributes
                theAttributes=theNode.getAttributes;
                numAttributes=theAttributes.getLength;
                allocCell=cell(1,numAttributes);
                attributes=struct('Name',allocCell,'Value',...
                allocCell);

                for count=1:numAttributes
                    attrib=theAttributes.item(count-1);
                    attributes(count).Name=char(attrib.getName);
                    attributes(count).Value=char(attrib.getValue);
                end
            end
        end
    end
end