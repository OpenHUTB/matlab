classdef CZMLWriter<handle

    properties
FileName
FilePath
        StartTime=datetime(-9999,8,21,0,0,0);

        EndTime=datetime(9999,8,21,1,0,0);

        CurrentTime=datetime(-9999,8,21,0,0,0);


Speed

    end

    properties(Access=private)
DocumentPacket
Packets
FileContent
NumGraphics
        PacketNames=strings(0)
    end

    properties(Dependent)
CurrentGraphics

    end

    properties(Constant)

        DateTimeFormat='yyyy-MM-dd''T''HH:mm:ss.SSSSSSSS''Z';
    end

    methods
        function writer=CZMLWriter(fileName,filePath,startTime,...
            endTime,varargin)


            p=inputParser;
            addRequired(p,'fileName');
            addRequired(p,'filePath');
            addRequired(p,'startTime');
            addRequired(p,'endTime');
            addParameter(p,'CurrentTime',startTime);
            addParameter(p,'Speed',1);
            parse(p,fileName,filePath,startTime,endTime,varargin{:});



            inputs=p.Results;
            writer.FileName=inputs.fileName;
            writer.FilePath=inputs.filePath;
            writer.CurrentTime=inputs.CurrentTime;
            writer.StartTime=inputs.startTime;
            writer.EndTime=inputs.endTime;
            writer.Speed=inputs.Speed;
            writer.FileContent="";


            addDocumentPacket(writer);


            writer.NumGraphics=0;
        end

        function write(writer)




            compileFileContent(writer);


            fullPath=...
            fullfile(writer.FilePath,[writer.FileName,'.czml']);


            fc=writer.FileContent;
            fid=fopen(fullPath,"w");
            fwrite(fid,fc);
            fclose(fid);
        end

        function removeGraphic(writer,name)

            packetRemoved=false;
            for idx=1:length(writer.Packets)
                if strcmp(name,writer.Packets(idx).Name)


                    if~strcmp(writer.Packets(idx).Type,...
                        "position reference")


                        if strcmp(writer.Packets(idx).Type,"polyline")
                            referencePackets=...
                            writer.Packets(idx).ReferencePackets;



                            for idx2=1:length(referencePackets)
                                removePacket(writer,...
                                referencePackets{idx2});
                            end
                        end


                        removePacket(writer,name);


                        writer.NumGraphics=writer.NumGraphics-1;
                        packetRemoved=true;
                        break
                    end
                end
            end


            if~packetRemoved
                error(message(...
                'shared_globe:viewer:UnableToRemoveCZMLGraphic'));
            end
        end
    end

    methods
        function currentGraphics=get.CurrentGraphics(writer)




            graphicName(1:writer.NumGraphics,1)="";
            graphicType(1:writer.NumGraphics,1)="";
            packetIdx=1;

            for idx=1:length(writer.Packets)


                if~strcmp(writer.Packets(idx).Type,"position reference")
                    graphicName(packetIdx)=writer.Packets(idx).Name;
                    graphicType(packetIdx)=writer.Packets(idx).Type;
                    packetIdx=packetIdx+1;
                end
            end


            currentGraphics=table(graphicName,graphicType);
        end

        function set.FileName(writer,fileName)

            validateFileName(fileName);
            writer.FileName=fileName;
            addDocumentPacket(writer);
        end

        function set.FilePath(writer,filePath)

            validateFilePath(filePath);
            writer.FilePath=filePath;
        end

        function set.StartTime(writer,startTime)

            validateTimes(startTime,writer.EndTime,...
            writer.CurrentTime);%#ok<MCSUP>
            writer.StartTime=startTime;
            writer.addDocumentPacket;
        end

        function set.EndTime(writer,endTime)

            validateTimes(writer.StartTime,endTime,...
            writer.CurrentTime);%#ok<MCSUP>
            writer.EndTime=endTime;
            writer.addDocumentPacket;
        end

        function set.CurrentTime(writer,currentTime)

            validateTimes(writer.StartTime,writer.EndTime,...
            currentTime);%#ok<MCSUP>
            writer.CurrentTime=currentTime;
            writer.addDocumentPacket;
        end

        function set.Speed(writer,speed)

            validateSpeed(speed);
            writer.Speed=speed;
            writer.addDocumentPacket;
        end
    end

    methods
        addPolyline(writer,varargin)
        addBillboard(writer,varargin)
        addRectangle(writer,varargin)
        addCylinder(writer,varargin)
        addEllipse(writer,varargin)
        addModel(writer,varargin)
        addPath(writer,varargin)
        addPoint(writer,varargin)
        addLabel(writer,varargin)
        addLineWithIntervals(writer,varargin)
    end

    methods(Access=protected)
        addPositionReference(writer,varargin)
    end

    methods(Access=protected)
        function addDocumentPacket(writer)




            fileName=writer.FileName;
            startTime=writer.StartTime;
            endTime=writer.EndTime;
            currentTime=writer.CurrentTime;
            speed=writer.Speed;


            if isempty(startTime)||isempty(endTime)||...
                isempty(currentTime)||isempty(speed)
                return
            end


            intervalString=string(datetime(startTime,...
            'Format','yyyy-MM-dd''T''HH:mm:ss.SSSSSSSS''Z'))+"/"...
            +string(datetime(endTime,'Format',...
            'yyyy-MM-dd''T''HH:mm:ss.SSSSSSSS''Z'));
            currentTimeString=string(datetime(currentTime,...
            'Format','yyyy-MM-dd''T''HH:mm:ss.SSSSSSSS''Z'));
            clk=struct("interval",intervalString,"currentTime",...
            currentTimeString,"multiplier",speed,"range",...
            "CLAMPED");

            packetString=struct("id","document",...
            "name",fileName,"version","1.0","clock",clk);

            writer.DocumentPacket.Name="document";
            writer.DocumentPacket.Type="document";
            writer.DocumentPacket.PacketString=jsonencode(packetString);
        end

        function packetIdx=findPacket(writer,packetName)



            packetIdx=0;

            if~isempty(writer.Packets)
                nameMatches=writer.PacketNames==packetName;
                if any(nameMatches)
                    packetIdx=find(nameMatches);
                end
            end
        end

        function removePacket(writer,name)



            for idx=1:length(writer.Packets)
                if strcmp(name,writer.Packets(idx).Name)
                    writer.Packets(idx)=[];
                    writer.PacketNames(idx)=[];
                    break
                end
            end
        end

        function compileFileContent(writer)



            if isempty(writer.Packets)
                fileContent="["+newline+...
                writer.DocumentPacket.PacketString+newline+"]";
            else
                fileContent="["+newline+...
                writer.DocumentPacket.PacketString;

                for idx=1:length(writer.Packets)
                    fileContent=fileContent+", "+newline+...
                    writer.Packets(idx).PacketString;
                end

                fileContent=fileContent+newline+"]";
            end
            writer.FileContent=fileContent;
        end

        function addPacket(writer,name,type,packetString)





            idx=findPacket(writer,name);
            if idx~=0
                error(message(...
                'shared_globe:viewer:UnableToAddCZMLGraphic'));
            else
                packetIdx=length(writer.Packets)+1;
                writer.Packets(packetIdx).Name=name;
                writer.Packets(packetIdx).Type=type;
                writer.Packets(packetIdx).PacketString=...
                jsonencode(packetString);


                writer.NumGraphics=writer.NumGraphics+1;
                writer.PacketNames(end+1)=name;
            end
        end
    end
end

function validateFileName(fileName)




    validateattributes(fileName,...
    {'char','string'},{'scalartext'},...
    'CZMLWriter','fileName');
end

function validateFilePath(filePath)




    validateattributes(filePath,...
    {'char','string'},{'scalartext'},...
    'CZMLWriter','filePath');
end

function validateTimes(startTime,endTime,currentTime)



    validateattributes(startTime,{'datetime'},{'finite','scalar'},...
    'CZMLWriter','startTime');


    validateattributes(endTime,{'datetime'},{'finite','scalar'},...
    'CZMLWriter','endTime');


    validateattributes(seconds(endTime-startTime),...
    {'numeric'},{'finite','positive'},'CZMLWriter',...
    'difference in seconds between endTime and starTime');



    validateattributes(currentTime,{'datetime'},{'finite','scalar'},...
    'CZMLWriter','currentTime');

    validateattributes(seconds(currentTime-startTime),{'numeric'},...
    {'finite','nonnegative'},'CZMLWriter',...
    'difference between CurrentTime and startTime');

    validateattributes(seconds(endTime-currentTime),{'numeric'},...
    {'finite','nonnegative'},'CZMLWriter',...
    'difference between endTime and CurrentTime');
end

function validateSpeed(speed)


    validateattributes(speed,...
    {'numeric'},{'nonempty','scalar','real','positive','finite'},...
    'CZMLWriter','Speed');
end