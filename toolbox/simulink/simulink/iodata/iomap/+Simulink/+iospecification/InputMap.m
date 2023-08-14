classdef InputMap<matlab.mixin.SetGet



























    properties
Type
DataSourceName
Destination
        Status=-1
    end


    properties(Dependent)
BlockName
BlockPath
SignalName
PortNumber
    end

    properties(Dependent,Hidden)
VariableName
    end


    properties(Hidden,Constant)
        ValidMapTypes={'Inport','EnablePort','TriggerPort','ConfigParam'};
    end


    properties(Hidden=true,GetAccess=protected,SetAccess=protected)

Version
    end


    properties(Hidden=true)


InputParentName
InputString
    end


    methods
        function aInputMap=InputMap(varargin)

            numArg=nargin;

            if numArg==0
                aInputMap.Type='Inport';

            end

            if numArg>0
                aInputMap.Type=varargin{1};
            end

            if numArg>1
                aInputMap.DataSourceName=varargin{2};
            end

            if numArg>2
                aInputMap.Destination=varargin{3};
            end

            if numArg>3
                str=varargin{4};
                if isStringScalar(str)
                    str=convertStringsToChars(str);
                end
                aInputMap.InputString=str;
            end





            aInputMap.Version=1.4;
        end

        function aInputMap=set.Type(aInputMap,str)

            if isStringScalar(str)
                str=convertStringsToChars(str);
            end

            if ischar(str)&&any(strcmpi(aInputMap.ValidMapTypes,str))
                aInputMap.Type=...
                aInputMap.ValidMapTypes{strcmpi(aInputMap.ValidMapTypes,str)};
            else
                DAStudio.error('sl_iospecification:iostrategy:errorType');
            end
        end


        function aInputMap=set.DataSourceName(aInputMap,str)

            if isStringScalar(str)
                str=convertStringsToChars(str);
            end

            if ischar(str)||...
                isempty(str)
                aInputMap.DataSourceName=str;
            else
                DAStudio.error('sl_iospecification:iostrategy:errorDataSource');
            end
        end

        function aInputMap=set.Destination(aInputMap,dest)
            if isa(dest,'Simulink.iospecification.Destination')||...
                isempty(dest)
                aInputMap.Destination=dest;
            else
                DAStudio.error('sl_iospecification:iostrategy:errorDestination');
            end
        end



        function blockName=get.BlockName(aInputMap)

            blockName=[];


            if~isempty(aInputMap.Destination)
                blockName=aInputMap.Destination.BlockName;
            end
        end


        function blockPath=get.BlockPath(aInputMap)

            blockPath=[];


            if~isempty(aInputMap.Destination)
                blockPath=aInputMap.Destination.BlockPath;
            end
        end


        function signalName=get.SignalName(aInputMap)

            signalName=[];


            if~isempty(aInputMap.Destination)
                signalName=aInputMap.Destination.SignalName;
            end
        end


        function portNumber=get.PortNumber(aInputMap)

            portNumber=[];


            if~isempty(aInputMap.Destination)
                portNumber=aInputMap.Destination.PortNumber;
            end
        end


        function aInputMap=set.BlockName(aInputMap,blockName)


            if isempty(aInputMap.Destination)
                aInputMap.Destination=createDestination(aInputMap);
            end


            try

                aInputMap.Destination.BlockName=blockName;

            catch ME

                throw(ME);

            end
        end


        function aInputMap=set.BlockPath(aInputMap,blockPath)


            if isempty(aInputMap.Destination)
                aInputMap.Destination=createDestination(aInputMap);
            end


            try

                aInputMap.Destination.BlockPath=blockPath;

            catch ME

                throw(ME);

            end
        end


        function aInputMap=set.SignalName(aInputMap,signalName)


            if isempty(aInputMap.Destination)
                aInputMap.Destination=createDestination(aInputMap);
            end


            try

                aInputMap.Destination.SignalName=signalName;

            catch ME

                throw(ME);

            end
        end


        function aInputMap=set.PortNumber(aInputMap,portNumber)


            if isempty(aInputMap.Destination)
                aInputMap.Destination=createDestination(aInputMap);
            end


            try

                aInputMap.Destination.PortNumber=portNumber;

            catch ME

                throw(ME);

            end
        end


        function varStr=get.VariableName(aInputMap)

            varStr=[];


            if~isempty(aInputMap.DataSourceName)


                arrayIdx=strfind(aInputMap.DataSourceName,'(');


                if~isempty(arrayIdx)

                    varStr=aInputMap.DataSourceName(1:arrayIdx-1);

                else
                    varStr=aInputMap.DataSourceName;
                end
            end

        end


        function aInputMap=set.VariableName(aInputMap,~)

        end


        function aInputMap=set.Status(aInputMap,theStatus)


            if(isscalar(theStatus)&&any(theStatus==[-1,0,1,2]))||islogical(theStatus)
                aInputMap.Status=theStatus;
            else
                DAStudio.error('sl_iospecification:iostrategy:errorInMapStatusMCOS');
            end
        end


        function aInputMap=set.InputString(aInputMap,str)

            if isStringScalar(str)
                str=convertStringsToChars(str);
            end

            if ischar(str)
                aInputMap.InputString=str;
            else
                DAStudio.error('sl_iospecification:iostrategy:errorType');
            end
        end
    end

    methods(Access=private)

        function dest=createDestination(~)
            dest=Simulink.iospecification.Destination;
        end
    end

    methods(Hidden)


        function inputStr=getExternalInputString(aInputMap)

            if isscalar(aInputMap)

                inputStr=aInputMap.InputString;
            else
                inputStr='';

                for kMap=1:(length(aInputMap)-1)




                    if isempty(getExternalInputString(aInputMap(kMap)))
                        break;
                    end

                    inputStr=[inputStr,getExternalInputString(aInputMap(kMap)),','];
                end

                inputStr=[inputStr,getExternalInputString(aInputMap(end))];

            end

        end

    end

end
