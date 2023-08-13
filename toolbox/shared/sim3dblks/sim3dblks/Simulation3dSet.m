classdef Simulation3dSet<Simulation3DActor&...
Simulation3DHandleMap


    properties(Nontunable)

        TopicName char='mySignal'
    end

    properties(Access=private)
        Writer=[];
        DataType char='uint8';
        ModelName=[];
    end


    methods(Access=protected)
        function setupImpl(self,messagetowrite)
            setupImpl@Simulation3DActor(self);
            self.DataType=propagatedInputDataType(self,1);
            s1=size(messagetowrite,1);s2=size(messagetowrite,2);


            switch(self.DataType)
            case 'uint8'
                self.Writer=setupSimulation3DMessageUInt8Writer(self.TopicName,uint32(s1*s2));
            case 'uint16'
                self.Writer=setupSimulation3DMessageUInt16Writer(self.TopicName,uint32(s1*s2));
            case 'uint32'
                self.Writer=setupSimulation3DMessageUInt32Writer(self.TopicName,uint32(s1*s2));
            case 'int8'
                self.Writer=setupSimulation3DMessageInt8Writer(self.TopicName,uint32(s1*s2));
            case 'int16'
                self.Writer=setupSimulation3DMessageInt16Writer(self.TopicName,uint32(s1*s2));
            case 'int32'
                self.Writer=setupSimulation3DMessageInt32Writer(self.TopicName,uint32(s1*s2));
            case 'single'
                self.Writer=setupSimulation3DMessageSingleWriter(self.TopicName,uint32(s1*s2));
            case 'double'
                self.Writer=setupSimulation3DMessageDoubleWriter(self.TopicName,uint32(s1*s2));
            case 'logical'
                self.Writer=setupSimulation3DMessageBoolWriter(self.TopicName,uint32(s1*s2));
            otherwise
                warning('This Data Type is not supported');
            end
            self.ModelName=['Simulation3dSet/',self.TopicName];
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/Writer'],self.Writer);
            end
        end

        function stepImpl(self,messagetowrite)
            s1=size(messagetowrite,1);s2=size(messagetowrite,2);
            messagetowrite=reshape(messagetowrite,[1,s1*s2]);

            if coder.target('MATLAB')
                switch(self.DataType)
                case 'uint8'
                    Data=uint8(messagetowrite);
                    result=writeSimulation3DMessageUInt8(self.Writer,Data);
                case 'uint16'
                    Data=uint16(messagetowrite);
                    result=writeSimulation3DMessageUInt16(self.Writer,Data);
                case 'uint32'
                    Data=uint32(messagetowrite);
                    result=writeSimulation3DMessageUInt32(self.Writer,Data);
                case 'int8'
                    Data=int8(messagetowrite);
                    result=writeSimulation3DMessageInt8(self.Writer,Data);
                case 'int16'
                    Data=int16(messagetowrite);
                    result=writeSimulation3DMessageInt16(self.Writer,Data);
                case 'int32'
                    Data=int32(messagetowrite);
                    result=writeSimulation3DMessageInt32(self.Writer,Data);
                case 'single'
                    Data=single(messagetowrite);
                    result=writeSimulation3DMessageSingle(self.Writer,Data);
                case 'double'
                    Data=double(messagetowrite);
                    result=writeSimulation3DMessageDouble(self.Writer,Data);
                case 'logical'
                    Data=logical(messagetowrite);
                    result=writeSimulation3DMessageBool(self.Writer,Data);
                otherwise
                    warning('This Data Type is not supported');
                end
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            self.TopicName=s.TopicName;
            self.DataType=s.DataType;

            if self.loadflag
                self.ModelName=s.ModelName;
                self.Writer=self.Sim3dSetGetHandle([self.ModelName,'/Writer']);
            else
                self.Writer=s.Writer;
            end

            loadObjectImpl@matlab.System(self,s,wasInUse);
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@matlab.System(self);
            s.ModelName=self.ModelName;
            s.TopicName=self.TopicName;
            s.DataType=self.DataType;
            s.Writer=self.Writer;
        end


        function releaseImpl(self)
            switch(self.DataType)
            case 'uint8'
                result=releaseSimulation3DMessageUInt8Writer(self.Writer);
            case 'uint16'
                result=releaseSimulation3DMessageUInt16Writer(self.Writer);
            case 'uint32'
                result=releaseSimulation3DMessageUInt32Writer(self.Writer);
            case 'int8'
                result=releaseSimulation3DMessageInt8Writer(self.Writer);
            case 'int16'
                result=releaseSimulation3DMessageInt16Writer(self.Writer);
            case 'int32'
                result=releaseSimulation3DMessageInt32Writer(self.Writer);
            case 'single'
                result=releaseSimulation3DMessageSingleWriter(self.Writer);
            case 'double'
                result=releaseSimulation3DMessageDoubleWriter(self.Writer);
            case 'logical'
                result=releaseSimulation3DMessageBoolWriter(self.Writer);
            otherwise
                warning('This Data Type is not supported');
            end

            if(~result)
                self.Writer=[];
            else
                warning('Message writer was not closed properly.');
                self.Writer=[];
            end

            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/Writer'],[]);
            end
        end

        function icon=getIconImpl(~)
            icon={'Simulation 3D Message','Set'};
        end

    end
end



