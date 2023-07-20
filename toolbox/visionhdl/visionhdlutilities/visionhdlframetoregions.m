function regions=visionhdlframetoregions(activePixelsPerLine,activeLines,numHorTiles,numVerTiles,varargin)



































    validateattributes(activePixelsPerLine,{'numeric'},{'scalar','integer','real','>=',1},'','activePixelsPerLine');
    validateattributes(activeLines,{'numeric'},{'scalar','integer','real','>=',1},'','activeLines');
    validateattributes(numHorTiles,{'numeric'},{'scalar','integer','real','>=',1,'<=',16},'','numHorTiles');
    validateattributes(numVerTiles,{'numeric'},{'scalar','integer','real','>=',1,'<=',1024},'','numVerTiles');



    defaultfillType='none';
    defaultnumPix=1;
    p=inputParser;
    addParameter(p,'fillType',defaultfillType,@ischar);
    addParameter(p,'numPix',defaultnumPix);
    parse(p,varargin{:});
    fillType=p.Results.fillType;
    validfillType=["none","full"];
    validatestring(fillType,validfillType);
    numPix=p.Results.numPix;
    validateattributes(numPix,{'numeric'},{'scalar','integer','real','>=',1},'','numPix');

    regions=zeros((numHorTiles*numVerTiles),4);

    tileDim=[floor(activeLines/numVerTiles),floor(activePixelsPerLine/numHorTiles)];
    extraRow=mod(activeLines,numVerTiles);
    extraCol=mod(activePixelsPerLine,numHorTiles);
    extraColTile=mod(tileDim(2),numPix);
    minPixelsPerLineMP=2*numPix*numHorTiles;
    regIdx=1;

    if numPix>1


        coder.internal.errorIf(activePixelsPerLine<minPixelsPerLineMP,'visionhdl:visionhdlframetoregions:invalidInputSizeMP');


        if extraColTile~=0
            tileDim(2)=tileDim(2)-extraColTile;
            extraCol=extraCol+(extraColTile*numHorTiles);
        end


        while floor(extraCol/numPix)>=numHorTiles
            tileDim(2)=tileDim(2)+numPix;
            extraCol=extraCol-(numPix*numHorTiles);
        end
    end

    if strcmp(fillType,'none')

        for vPos=1:tileDim(1):(activeLines-extraRow)

            for hPos=1:tileDim(2):(activePixelsPerLine-extraCol)
                regions(regIdx,:)=[hPos,vPos,tileDim(2),tileDim(1)];
                regIdx=regIdx+1;
            end
        end
    elseif strcmp(fillType,'full')
        coder.internal.errorIf(mod(activePixelsPerLine,numPix)~=0,'visionhdl:visionhdlframetoregions:invalidActivePixelsPerLine');


        vTile=1;

        for vPos=1:tileDim(1):activeLines
            hTile=1;
            for hPos=1:tileDim(2):activePixelsPerLine
                if hTile==numHorTiles&&vTile~=numVerTiles

                    regions(regIdx,:)=[hPos,vPos,(tileDim(2)+extraCol),tileDim(1)];
                    regIdx=regIdx+1;
                    break;
                elseif hTile~=numHorTiles&&vTile==numVerTiles

                    regions(regIdx,:)=[hPos,vPos,tileDim(2),(tileDim(1)+extraRow)];
                    regIdx=regIdx+1;
                    hTile=hTile+1;
                elseif hTile==numHorTiles&&vTile==numVerTiles

                    regions(regIdx,:)=[hPos,vPos,(tileDim(2)+extraCol),(tileDim(1)+extraRow)];
                    break;
                else
                    regions(regIdx,:)=[hPos,vPos,tileDim(2),tileDim(1)];
                    regIdx=regIdx+1;
                    hTile=hTile+1;
                end
            end
            if vTile==numVerTiles
                break;
            end
            vTile=vTile+1;
        end
    end
end
