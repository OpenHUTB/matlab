


classdef InterfaceListBase<handle


    properties(Access=protected)


        InterfaceIDList={};


        InputInterfaceIDList={};
        OutputInterfaceIDList={};


        InterfaceMap=[];

    end

    methods

        function obj=InterfaceListBase()

            obj.clearInterfaceList;
        end
        function clearInterfaceList(obj)
            obj.InterfaceIDList={};
            obj.InterfaceMap=containers.Map();
            obj.InputInterfaceIDList={};
            obj.OutputInterfaceIDList={};
        end


        function addInterface(obj,hInterface)

            interfaceID=hInterface.InterfaceID;

            if~obj.InterfaceMap.isKey(interfaceID)















                interfacePortLabel=regexprep(interfaceID,'[\W]*','_');
                interfacePortLabelList=regexprep(obj.InterfaceIDList,'[\W]*','_');
                if any(strcmp(interfacePortLabel,interfacePortLabelList))
                    error(message('hdlcommon:plugin:DuplicateInterfacePortLabel',interfaceID,interfacePortLabel));
                end

                obj.InterfaceMap(interfaceID)=hInterface;
                obj.InterfaceIDList{end+1}=interfaceID;
            else
                error(message('hdlcommon:plugin:DuplicateInterfaceID',interfaceID));
            end
        end


        function list=getInterfaceIDList(obj)

            list=obj.InterfaceIDList;
        end

        function hInterface=getInterface(obj,interfaceID)
            if obj.InterfaceMap.isKey(interfaceID)
                hInterface=obj.InterfaceMap(interfaceID);
            else
                error(message('hdlcommon:plugin:InvalidInterfaceID',interfaceID));
            end
        end

        function propVal=getInterfaceProperty(obj,interfaceID,varargin)






            try
                hInterface=obj.getInterface(interfaceID);
                propVal=get(hInterface,varargin{:});
            catch me
                propList=varargin;
                if isempty(propList)
                    propListStr='';
                elseif length(propList)==1&&ischar(propList{1})
                    propListStr=propList{1};
                elseif length(propList)==1&&iscell(propList{1})
                    propListStr=strjoin(propList{1},', ');
                else
                    propListStr='';
                end

                msg=MException(message('hdlcommon:plugin:GetInterfaceProperty',propListStr,interfaceID));
                msg=msg.addCause(me);
                throw(msg);
            end
        end


        function list=getInputInterfaceIDList(obj)
            list=obj.InputInterfaceIDList;
        end
        function list=getOutputInterfaceIDList(obj)
            list=obj.OutputInterfaceIDList;
        end
        function populateRAWINOUTInterfaceIDList(obj)



            obj.InputInterfaceIDList={};
            obj.OutputInterfaceIDList={};

            rawInterfaceIDList=obj.getInterfaceIDList;
            for ii=1:length(rawInterfaceIDList)
                interfaceID=rawInterfaceIDList{ii};
                hInterface=obj.getInterface(interfaceID);

                if hInterface.InterfaceType==hdlturnkey.IOType.IN
                    obj.InputInterfaceIDList{end+1}=interfaceID;
                elseif hInterface.InterfaceType==hdlturnkey.IOType.OUT
                    obj.OutputInterfaceIDList{end+1}=interfaceID;
                else
                    obj.InputInterfaceIDList{end+1}=interfaceID;
                    obj.OutputInterfaceIDList{end+1}=interfaceID;
                end
            end
        end

    end

end
