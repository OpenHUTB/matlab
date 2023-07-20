classdef(StrictDefaults)Simulation3dGet<Simulation3DActor&...
Simulation3DHandleMap






    properties(Nontunable)





        TopicName char='mySignal'





        DataType char='uint8'




        MessageSize(1,2)uint32{mustBePositive}=[1,1];
    end

    properties(Hidden,Constant)
        DataTypeSet=matlab.system.StringSet({'double','single','int8','uint8','int16','uint16','int32','uint32','boolean'});
    end


    properties(Access=private)
        Reader=[];
        Flag=0;
        Size=0;
        Buffer=[];
        ModelName=[];
    end

    methods(Access=protected)

        function setupImpl(self)
            setupImpl@Simulation3DActor(self);
            switch(self.DataType)
            case 'uint8'
                self.Reader=setupSimulation3DMessageUInt8Reader(self.TopicName,uint32((self.MessageSize(1)*self.MessageSize(2))));
            case 'uint16'
                self.Reader=setupSimulation3DMessageUInt16Reader(self.TopicName,uint32((self.MessageSize(1)*self.MessageSize(2))));
            case 'uint32'
                self.Reader=setupSimulation3DMessageUInt32Reader(self.TopicName,uint32((self.MessageSize(1)*self.MessageSize(2))));
            case 'int8'
                self.Reader=setupSimulation3DMessageInt8Reader(self.TopicName,uint32((self.MessageSize(1)*self.MessageSize(2))));
            case 'int16'
                self.Reader=setupSimulation3DMessageInt16Reader(self.TopicName,uint32((self.MessageSize(1)*self.MessageSize(2))));
            case 'int32'
                self.Reader=setupSimulation3DMessageInt32Reader(self.TopicName,uint32((self.MessageSize(1)*self.MessageSize(2))));
            case 'single'
                self.Reader=setupSimulation3DMessageSingleReader(self.TopicName,uint32((self.MessageSize(1)*self.MessageSize(2))));
            case 'double'
                self.Reader=setupSimulation3DMessageDoubleReader(self.TopicName,uint32((self.MessageSize(1)*self.MessageSize(2))));
            case 'boolean'
                self.Reader=setupSimulation3DMessageBoolReader(self.TopicName,uint32((self.MessageSize(1)*self.MessageSize(2))));
            otherwise
                noDataType=MException('sim3dblks:Simulation3DGet:setupImpl:NoDataType',...
                ['The data type selected for block ''',gcb...
                ,''' is not currently supported.']);
                throw(noDataType);
            end

            if self.loadflag
                self.ModelName=['Simulation3dGet/',self.TopicName];
                self.Sim3dSetGetHandle([self.ModelName,'/Reader'],self.Reader);
            end
        end

        function readMessage=stepImpl(self)

            if isempty(self.Reader)
                readMessage=[];
            else
                switch(self.DataType)
                case 'uint8'
                    [result,readMessage]=readSimulation3DMessageUInt8(self.Reader,uint32((self.MessageSize(1)*self.MessageSize(2))));
                case 'uint16'
                    [result,readMessage]=readSimulation3DMessageUInt16(self.Reader,uint32((self.MessageSize(1)*self.MessageSize(2))));
                case 'uint32'
                    [result,readMessage]=readSimulation3DMessageUInt32(self.Reader,uint32((self.MessageSize(1)*self.MessageSize(2))));
                case 'int8'
                    [result,readMessage]=readSimulation3DMessageInt8(self.Reader,uint32((self.MessageSize(1)*self.MessageSize(2))));
                case 'int16'
                    [result,readMessage]=readSimulation3DMessageInt16(self.Reader,uint32((self.MessageSize(1)*self.MessageSize(2))));
                case 'int32'
                    [result,readMessage]=readSimulation3DMessageInt32(self.Reader,uint32((self.MessageSize(1)*self.MessageSize(2))));
                case 'single'
                    [result,readMessage]=readSimulation3DMessageSingle(self.Reader,uint32((self.MessageSize(1)*self.MessageSize(2))));
                case 'double'
                    [result,readMessage]=readSimulation3DMessageDouble(self.Reader,uint32((self.MessageSize(1)*self.MessageSize(2))));
                case 'boolean'
                    [result,readMessage]=readSimulation3DMessageBool(self.Reader,uint32((self.MessageSize(1)*self.MessageSize(2))));
                otherwise
                    noDataType=MException('sim3dblks:Simulation3DGet:setupImpl:NoDataType',...
                    ['The data type selected for block ''',gcb...
                    ,''' is not currently supported.']);
                    throw(noDataType);
                end


                if result==0&&~isempty(readMessage)
                    readMessage=reshape(readMessage,[self.MessageSize(1),self.MessageSize(2)]);
                    self.Buffer=readMessage;
                elseif result==13&&~isempty(readMessage)

                    error(message('shared_sim3dblks:sim3dblkMessageGET:blkPrm_WR_MsgSize'));
                else
                    readMessage=self.Buffer;
                end

            end
        end

        function releaseImpl(self)

            releaseImpl@Simulation3DActor(self);

            switch(self.DataType)
            case 'uint8'
                result=releaseSimulation3DMessageUInt8Reader(self.Reader);
            case 'uint16'
                result=releaseSimulation3DMessageUInt16Reader(self.Reader);
            case 'uint32'
                result=releaseSimulation3DMessageUInt32Reader(self.Reader);
            case 'int8'
                result=releaseSimulation3DMessageInt8Reader(self.Reader);
            case 'int16'
                result=releaseSimulation3DMessageInt16Reader(self.Reader);
            case 'int32'
                result=releaseSimulation3DMessageInt32Reader(self.Reader);
            case 'single'
                result=releaseSimulation3DMessageSingleReader(self.Reader);
            case 'double'
                result=releaseSimulation3DMessageDoubleReader(self.Reader);
            case 'boolean'
                result=releaseSimulation3DMessageBoolReader(self.Reader);
            otherwise
                noDataType=MException('sim3dblks:Simulation3DGet:setupImpl:NoDataType',...
                ['The data type selected for block ''',gcb...
                ,''' is not currently supported.']);
                throw(noDataType);
            end

            if(~result)
                self.Reader=[];
            else
                warning('Message reader was not closed properly!');
                self.Reader=[];
            end

            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/Reader'],[]);
            end
        end

        function icon=getIconImpl(~)
            icon={'Simulation 3D Message','Get'};
        end

        function num=getNumOutputsImpl(~)
            num=1;
        end

        function loadObjectImpl(self,s,wasInUse)
            self.DataType=s.DataType;
            self.MessageSize=s.MessageSize;
            self.Flag=s.Flag;
            self.Size=s.Size;
            self.Buffer=s.Buffer;
            if self.loadflag
                self.ModelName=s.ModelName;
                self.Reader=self.Sim3dSetGetHandle([self.ModelName,'/Reader']);
            else
                self.Reader=s.Reader;
            end

            loadObjectImpl@matlab.System(self,s,wasInUse);
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@matlab.System(self);

            s.DataType=self.DataType;
            s.MessageSize=self.MessageSize;
            s.Reader=self.Reader;
            s.Flag=self.Flag;
            s.Size=self.Size;
            s.Buffer=self.Buffer;
            s.ModelName=self.ModelName;
        end

        function[sz1]=getOutputSizeImpl(self)
            sz1=[double(self.MessageSize(1)),double(self.MessageSize(2))];
        end


        function[fz1]=isOutputFixedSizeImpl(~)
            fz1=true;
        end

        function[dt1]=getOutputDataTypeImpl(self)
            if(strcmp(self.DataType,'boolean'))
                dt1='logical';
            else
                dt1=self.DataType;
            end
        end

        function[cp1]=isOutputComplexImpl(~)
            cp1=false;
        end

    end
end




