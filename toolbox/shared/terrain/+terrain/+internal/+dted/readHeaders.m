function[UHL,DSI,ACC]=readHeaders(fileID)




    UHLfield=UHLdescription;
    DSIfield=DSIdescription;
    ACCfield=ACCdescription;

    UHL=readHeaderFields(fileID,UHLfield);
    DSI=readHeaderFields(fileID,DSIfield);
    ACC=readHeaderFields(fileID,ACCfield);



    filename=fopen(fileID);
    if contains(filename,'n00.dt0')
        if isequal(DSI.LatitudeofNWcorner,'010000S')


            DSI.LatitudeofNWcorner='010000N';
            DSI.LatitudeofNEcorner=DSI.LatitudeofNWcorner;
        end
    end





    [pathstr,name,ext]=fileparts(filename);
    [~,nameOfEnclosingDirectory]=fileparts(pathstr);
    if strcmp(nameOfEnclosingDirectory,'e000')
        if 'W'==DSI.LongitudeofNEcorner(end)

            warning(message('shared_terrain:dted:CorrectingLongitudes',[fullfile(nameOfEnclosingDirectory,name),ext]));
            DSI.Longitudeoforigin(end)='E';
            UHL.Longitudeoforigin(end)='E';
            DSI.LongitudeofSWcorner(end)='E';
            DSI.LongitudeofNWcorner(end)='E';
            DSI.LongitudeofNEcorner(end)='E';
            DSI.LongitudeofSEcorner(end)='E';
        end
    end



    function struc=readHeaderFields(fileID,field)


        datastartpos=ftell(fileID);
        fseek(fileID,0,1);
        eof=ftell(fileID);
        fseek(fileID,datastartpos,-1);


        status=fseek(fileID,datastartpos,-1);
        if ftell(fileID)>=eof||status==-1
            error(message('shared_terrain:dted:RecordNotFound'));
        end

        struc=[];
        for i=1:length(field)

            field(i).name=erase(field(i).name," ");
            len=field(i).length;
            strng=fread(fileID,len,'char');
            strng=char(strng');
            strng=deblank(strng);
            if~isempty(field(i).name)
                struc=setfield(struc,{1},field(i).name,strng);
            end
        end



        function UHLfield=UHLdescription



            UHLfield(1).length=3;UHLfield(1).name='Recognition sentinel';
            UHLfield(2).length=1;UHLfield(2).name='Fixed by standard';
            UHLfield(3).length=8;UHLfield(3).name='Longitude of origin ';
            UHLfield(4).length=8;UHLfield(4).name='Latitude of origin ';
            UHLfield(5).length=4;UHLfield(5).name='Longitude data interval ';
            UHLfield(6).length=4;UHLfield(6).name='Latitude data interval ';
            UHLfield(7).length=4;UHLfield(7).name='Absolute Vertical Accuracy in Meters';
            UHLfield(8).length=3;UHLfield(8).name='Security Code';
            UHLfield(9).length=12;UHLfield(9).name='Unique reference number ';
            UHLfield(10).length=4;UHLfield(10).name='number of longitude lines ';
            UHLfield(11).length=4;UHLfield(11).name='number of latitude points ';
            UHLfield(12).length=1;UHLfield(12).name='Multiple accuracy';
            UHLfield(13).length=24;UHLfield(13).name='future use';



            function DSIfield=DSIdescription



                DSIfield(1).length=3;DSIfield(1).name='Recognition Sentinel';
                DSIfield(2).length=1;DSIfield(2).name='Security Classification Code';
                DSIfield(3).length=2;DSIfield(3).name='Security Control and Release Markings';
                DSIfield(4).length=27;DSIfield(4).name='Security Handling Description';
                DSIfield(5).length=26;DSIfield(5).name='reserved1';
                DSIfield(6).length=5;DSIfield(6).name='DMA series';
                DSIfield(7).length=15;DSIfield(7).name='unique Ref Num';
                DSIfield(8).length=8;DSIfield(8).name='reserved2';
                DSIfield(9).length=2;DSIfield(9).name='Data Edition Number';
                DSIfield(10).length=1;DSIfield(10).name='Match Merge Version';
                DSIfield(11).length=4;DSIfield(11).name='Maintenance Date';
                DSIfield(12).length=4;DSIfield(12).name='Match Merge Date';
                DSIfield(13).length=4;DSIfield(13).name='Maintenance Description Code';
                DSIfield(14).length=8;DSIfield(14).name='Producer Code';
                DSIfield(15).length=16;DSIfield(15).name='reserved3';
                DSIfield(16).length=9;DSIfield(16).name='Product Specification';
                DSIfield(17).length=2;DSIfield(17).name='Product Specification Amendment Number';
                DSIfield(18).length=4;DSIfield(18).name='Date of Product Specification';
                DSIfield(19).length=3;DSIfield(19).name='Vertical Datum ';
                DSIfield(20).length=5;DSIfield(20).name='Horizontal Datum Code ';
                DSIfield(21).length=10;DSIfield(21).name='Digitizing Collection System';
                DSIfield(22).length=4;DSIfield(22).name='Compilation Date';
                DSIfield(23).length=22;DSIfield(23).name='reserved4';
                DSIfield(24).length=9;DSIfield(24).name='Latitude of origin';
                DSIfield(25).length=10;DSIfield(25).name='Longitude of origin ';
                DSIfield(26).length=7;DSIfield(26).name='Latitude of SW corner ';
                DSIfield(27).length=8;DSIfield(27).name='Longitude of SW corner ';
                DSIfield(28).length=7;DSIfield(28).name='Latitude of NW corner ';
                DSIfield(29).length=8;DSIfield(29).name='Longitude of NW corner ';
                DSIfield(30).length=7;DSIfield(30).name='Latitude of NE corner ';
                DSIfield(31).length=8;DSIfield(31).name='Longitude of NE corner ';
                DSIfield(32).length=7;DSIfield(32).name='Latitude of SE corner ';
                DSIfield(33).length=8;DSIfield(33).name='Longitude of SE corner ';
                DSIfield(34).length=9;DSIfield(34).name='Clockwise orientation angle ';
                DSIfield(35).length=4;DSIfield(35).name='Latitude interval ';
                DSIfield(36).length=4;DSIfield(36).name='Longitude interval ';
                DSIfield(37).length=4;DSIfield(37).name='Number of Latitude lines';
                DSIfield(38).length=4;DSIfield(38).name='Number of Longitude lines';
                DSIfield(39).length=2;DSIfield(39).name='Partial Cell Indicator ';
                DSIfield(40).length=101;DSIfield(40).name='reserved5';
                DSIfield(41).length=100;DSIfield(41).name='Reserved for producing nation use ';
                DSIfield(42).length=156;DSIfield(42).name='reserved6';



                function ACCfield=ACCdescription



                    ACCfield(1).length=3;ACCfield(1).name='Recognition Sentinel';
                    ACCfield(2).length=4;ACCfield(2).name='Absolute Horizontal Accuracy ';
                    ACCfield(3).length=4;ACCfield(3).name='Absolute Vertical Accuracy ';
                    ACCfield(4).length=4;ACCfield(4).name='Relative Horizontal Accuracy';
                    ACCfield(5).length=4;ACCfield(5).name='Relative Vertical Accuracy';
                    ACCfield(6).length=4;ACCfield(6).name='reserved1';
                    ACCfield(7).length=1;ACCfield(7).name='reserved2';
                    ACCfield(8).length=31;ACCfield(8).name='reserved3';
                    ACCfield(9).length=2;ACCfield(9).name='Multiple Accuracy Outline Flag';
                    ACCfield(10).length=4;ACCfield(10).name='Sub Absolute Horizontal Accuracy ';
                    ACCfield(11).length=4;ACCfield(11).name='Sub Absolute Vertical Accuracy';
                    ACCfield(12).length=4;ACCfield(12).name='Sub Relative Horizontal Accuracy';
                    ACCfield(13).length=4;ACCfield(13).name='Sub Relative Vertical Accuracy';
                    ACCfield(14).length=14*(2+9+10);ACCfield(14).name='Sub Region Outlines';
                    ACCfield(15).length=18;ACCfield(15).name='reserved4';
                    ACCfield(16).length=69;ACCfield(16).name='reserved5';
