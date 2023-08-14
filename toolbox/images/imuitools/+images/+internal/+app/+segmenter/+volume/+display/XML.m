classdef XML<handle




    properties

Reader

    end


    methods




        function self=XML(str)

            try

                inputObject=java.io.StringBufferInputStream(str);
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
                fwrite(fid,str);
                fclose(fid);


                root=xmlread(filename);


                delete(filename);
            end

            self.Reader=root.getDocumentElement;

        end




        function TF=isInFront(self,name)



            occupants=getOccupants(self);

            TF=false;

            for idx=1:occupants.getLength()

                node=occupants.item(idx-1);
                occupantName=node.getAttribute('Name');

                if strcmp(occupantName,name)

                    TF=strcmp(node.getAttribute('InFront'),'yes');
                    return;

                end

            end

        end




        function TF=isOnlyOneTile(self)


            tiles=getTiles(self);

            TF=tiles.getLength()<=1;

        end




        function TF=isTileFullColumnOnFarRight(self,tileId,numRows,numCols)







            tiles=getTiles(self);

            if(tileId<0)||(tileId>=tiles.getLength())
                TF=false;
                return;
            end

            thisTile=tiles.item(tileId);

            height=str2double(char(thisTile.getAttribute('Height')));
            width=str2double(char(thisTile.getAttribute('Width')));
            x=str2double(char(thisTile.getAttribute('X')));
            y=str2double(char(thisTile.getAttribute('Y')));

            TF=(height==numRows)&&(width==1)&&((numCols>=1)...
            &&(x==(numCols-1)))&&(y==0);

        end




        function TF=isTileFullColumnOnFarLeft(self,tileId,numRows,numCols)







            tiles=getTiles(self);

            if(tileId<0)||(tileId>=tiles.getLength())
                TF=false;
                return;
            end

            thisTile=tiles.item(tileId);

            height=str2double(char(thisTile.getAttribute('Height')));
            width=str2double(char(thisTile.getAttribute('Width')));
            x=str2double(char(thisTile.getAttribute('X')));
            y=str2double(char(thisTile.getAttribute('Y')));

            TF=(height==numRows)&&(width==1)&&((numCols>=1)...
            &&(x==(0)))&&(y==0);

        end




        function TF=isTileOccupiedByOneOccupant(self,tileId,name)

            occupants=getOccupants(self);

            TF=true;

            for idx=1:occupants.getLength()

                occupantNode=occupants.item(idx-1);
                occupantTile=str2double(char(occupantNode.getAttribute('Tile')));
                occupantName=occupantNode.getAttribute('Name');

                if occupantTile==tileId&&~strcmp(occupantName,name)

                    TF=false;

                end

            end

        end




        function TF=isLastOccupant(self,name)


            occupants=getOccupants(self);

            occupantNode=occupants.item(occupants.getLength()-1);
            occupantName=occupantNode.getAttribute('Name');
            TF=strcmp(occupantName,name);

        end




        function TF=isFirstOccupant(self,name)


            occupants=getOccupants(self);

            occupantNode=occupants.item(0);
            occupantName=occupantNode.getAttribute('Name');
            TF=strcmp(occupantName,name);

        end




        function TF=isOccupant(self,name)

            occupants=getOccupants(self);

            TF=false;

            for idx=1:occupants.getLength()

                occupantNode=occupants.item(idx-1);
                occupantName=occupantNode.getAttribute('Name');
                if strcmp(occupantName,name)
                    TF=true;
                    return;
                else
                    TF=false;
                end

            end

        end




        function tile=getOccupantTile(self,name)

            occupants=getOccupants(self);

            for idx=1:occupants.getLength()

                occupantNode=occupants.item(idx-1);
                occupantName=occupantNode.getAttribute('Name');

                if strcmp(occupantName,name)

                    tile=str2double(char(occupantNode.getAttribute('Tile')));
                    return;

                end

            end

        end




        function xmlString=removeFromLayout(self,str)







            xmlString='';

            if~isOccupant(self,str)
                return;
            end

            if isOnlyOneTile(self)||~isTileOccupiedByOneOccupant(self,getOccupantTile(self,str),str)
                return;
            end

            if isFirstOccupant(self,str)||isLastOccupant(self,str)

                tile=getOccupantTile(self,str);
                [rows,cols]=getTileRowsAndColumns(self);

                if isTileFullColumnOnFarRight(self,tile,rows,cols)

                    tileStruct=getTileStruct(self);
                    occupantStruct=getOccupantStruct(self);
                    rowWeights=getRowWeights(self);
                    colWeights=getColumnWeights(self);


                    col=colWeights(end);
                    colWeights(end)=[];
                    colWeights(end)=colWeights(end)+col;

                    tileStruct(end)=[];
                    occupantStruct(end)=[];

                    xmlString=createXML(self,colWeights,rowWeights,tileStruct,occupantStruct);

                elseif isTileFullColumnOnFarLeft(self,tile,rows,cols)

                    tileStruct=getTileStruct(self);
                    occupantStruct=getOccupantStruct(self);
                    rowWeights=getRowWeights(self);
                    colWeights=getColumnWeights(self);


                    col=colWeights(1);
                    colWeights(1)=[];
                    colWeights(1)=colWeights(1)+col;

                    tileStruct(1)=[];

                    for idx=1:numel(tileStruct)
                        tileStruct(idx).X=tileStruct(idx).X-1;
                    end

                    occupantStruct(1)=[];

                    for idx=1:numel(occupantStruct)
                        occupantStruct(idx).Tile=occupantStruct(idx).Tile-1;
                    end

                    xmlString=createXML(self,colWeights,rowWeights,tileStruct,occupantStruct);

                end

            end


        end




        function order=getOccupantOrder(self)

            occupants=getOccupants(self);
            order=cell([occupants.getLength(),1]);

            for idx=1:occupants.getLength()

                occupantNode=occupants.item(idx-1);
                order{idx}=occupantNode.getAttribute('Name');

            end

        end




        function xmlString=createXML(self,columnInfo,rowInfo,tileInfo,occupantInfo)



            docNode=com.mathworks.xml.XMLUtils.createDocument('Tiling');
            rootNode=docNode.getDocumentElement;

            attributeNames={'Columns','Count','EliminateEmpties','Rows'};
            attributeValues={num2str(numel(columnInfo)),num2str(numel(tileInfo)),'no',num2str(numel(rowInfo))};


            tilingNode=createElementWithAttribute(self,docNode,'Tiles',attributeNames,attributeValues);
            rootNode.appendChild(tilingNode);


            for idx=1:numel(columnInfo)

                columnNode=createElementWithAttribute(self,docNode,'Column','Weight',num2str(columnInfo(idx)));
                tilingNode.appendChild(columnNode);

            end


            for idx=1:numel(rowInfo)

                rowNode=createElementWithAttribute(self,docNode,'Row','Weight',num2str(rowInfo(idx)));
                tilingNode.appendChild(rowNode);

            end


            for idx=1:numel(tileInfo)

                attributeNames={'Height','Width','X','Y'};
                attributeValues={num2str(tileInfo(idx).Height),num2str(tileInfo(idx).Width),num2str(tileInfo(idx).X),num2str(tileInfo(idx).Y)};

                tileNode=createElementWithAttribute(self,docNode,'Tile',attributeNames,attributeValues);
                tilingNode.appendChild(tileNode);

            end



            occupancyNode=createElement(docNode,'Occupancy');
            rootNode.appendChild(occupancyNode);


            for idx=1:numel(occupantInfo)

                attributeNames={'InFront','Name','Tile'};
                attributeValues={occupantInfo(idx).InFront,occupantInfo(idx).Name,num2str(occupantInfo(idx).Tile)};

                occupantNode=createElementWithAttribute(self,docNode,'Occupant',attributeNames,attributeValues);
                occupancyNode.appendChild(occupantNode);

            end

            xmlString=xmlwrite(docNode);

        end

    end


    methods(Access=private)


        function elementNode=createElementWithAttribute(~,docNode,elementName,names,values)

            elementNode=docNode.createElement(elementName);
            names=cellstr(names);
            values=cellstr(values);

            for i=1:numel(names)
                elementNode.setAttribute(names{i},values{i});
            end

        end


        function occupants=getOccupants(self)

            occupancyElement=self.Reader.getElementsByTagName('Occupancy');
            occupancyNodes=occupancyElement.item(0);
            occupants=occupancyNodes.getElementsByTagName('Occupant');

        end


        function tiles=getTiles(self)

            tileElement=self.Reader.getElementsByTagName('Tiles');
            tileNodes=tileElement.item(0);
            tiles=tileNodes.getElementsByTagName('Tile');

        end


        function rowWeights=getRowWeights(self)

            tileElement=self.Reader.getElementsByTagName('Tiles');
            tileNodes=tileElement.item(0);
            rows=tileNodes.getElementsByTagName('Row');

            rowWeights=zeros([rows.getLength(),1]);

            for idx=1:rows.getLength()

                rowNodes=rows.item(idx-1);
                rowWeights(idx)=str2double(rowNodes.getAttribute('Weight'));

            end

        end


        function colWeights=getColumnWeights(self)

            tileElement=self.Reader.getElementsByTagName('Tiles');
            tileNodes=tileElement.item(0);
            cols=tileNodes.getElementsByTagName('Column');

            colWeights=zeros([cols.getLength(),1]);

            for idx=1:cols.getLength()

                colNodes=cols.item(idx-1);
                colWeights(idx)=str2double(colNodes.getAttribute('Weight'));

            end

        end


        function[rows,cols]=getTileRowsAndColumns(self)

            tileElement=self.Reader.getElementsByTagName('Tiles');
            tileNodes=tileElement.item(0);

            rows=str2double(tileNodes.getAttribute('Rows'));
            cols=str2double(tileNodes.getAttribute('Columns'));

            if~isfinite(rows)
                rows=1;
            end

            if~isfinite(cols)
                cols=1;
            end

        end


        function data=getTileStruct(self)

            tiles=getTiles(self);

            for idx=1:tiles.getLength()

                node=tiles.item(idx-1);

                data(idx).Height=str2double(char(node.getAttribute('Height')));%#ok<AGROW>
                data(idx).Width=str2double(char(node.getAttribute('Width')));%#ok<AGROW>
                data(idx).X=str2double(char(node.getAttribute('X')));%#ok<AGROW>
                data(idx).Y=str2double(char(node.getAttribute('Y')));%#ok<AGROW>

            end

        end


        function data=getOccupantStruct(self)

            occupants=getOccupants(self);

            for idx=1:occupants.getLength()

                node=occupants.item(idx-1);

                data(idx).InFront=char(node.getAttribute('InFront'));%#ok<AGROW>
                data(idx).Name=char(node.getAttribute('Name'));%#ok<AGROW>
                data(idx).Tile=str2double(char(node.getAttribute('Tile')));%#ok<AGROW>

            end

        end

    end


end