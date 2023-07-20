function javaLangString=getLayoutXML(obj)




    sw=StringWriter;
    sw.addcr('<?xml version="1.0" encoding="utf-8"?>');

    sw.addcr('<Tiling>');

    sw.addcr(getTilesSection(obj));
    sw.addcr(getOccupancySection(obj));
    sw.addcr('</Tiling>');
    javaLangString=java.lang.String(sw.string);


    function str=getTilesSection(obj)

        sw=StringWriter;

        currDialog=obj.pParameters.CurrentDialog;
        numScopes=obj.pPlotTimeScope+obj.pPlotSpectrum+obj.pPlotConstellation+obj.pPlotEyeDiagram+obj.pPlotCCDF+currDialog.numVisibleFigs;
        cols=currDialog.getNumTileColumns(numScopes);
        rows=currDialog.getNumTileRows(numScopes);

        tiles=currDialog.getNumTiles(numScopes);
        sw.addcr(['<Tiles Columns="',num2str(cols),'" Count="',num2str(tiles),'" Rows="',num2str(rows),'">']);


        w=currDialog.getColumnWeights(numScopes);
        for idx=1:cols
            sw.addcr(['<Column Weight="',num2str(w(idx)),' "/>']);
        end


        w=currDialog.getRowWeights(numScopes);
        for r=1:rows
            sw.addcr(['<Row Weight="',num2str(w(r)),' "/>']);
        end


        sw=currDialog.getTileOrientation(sw,rows,numScopes);

        sw.addcr('</Tiles>');
        str=sw.string;


        function str=getOccupancySection(obj)

            sw=StringWriter;
            sw.addcr('<Occupancy>');
            sw.addcr('<Occupant InFront="yes" Name="Waveform" Tile="0"/>');
            sw.addcr('<Occupant InFront="no" Name="Impairments" Tile="0"/>');
            sw.addcr('<Occupant InFront="no" Name="Transmitter" Tile="0"/>');

            sw=obj.pParameters.CurrentDialog.getCustomTilePlacement(sw);

            sw.addcr('</Occupancy>');
            str=sw.string;