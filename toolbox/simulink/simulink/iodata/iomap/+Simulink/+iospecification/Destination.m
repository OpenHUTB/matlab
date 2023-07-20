classdef Destination


























    properties
BlockPath
SignalName
BlockName
PortNumber
SSID
    end


    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
Version
    end


    methods
        function aDestination=Destination(varargin)
            numArg=nargin;


            if numArg==0

            end

            if numArg>0

                aDestination.BlockPath=varargin{1};
                aDestination.BlockName=[];
                aDestination.SignalName=[];
                aDestination.PortNumber=[];
                aDestination.SSID=[];
            end

            if numArg>1

                aDestination.BlockName=varargin{2};
            end

            if numArg>2

                aDestination.SignalName=varargin{3};
            end

            if numArg>3
                aDestination.PortNumber=varargin{4};
            end

            if numArg>4
                aDestination.SSID=varargin{5};
            end
            aDestination.Version=1.0;
        end


        function aDestination=set.BlockPath(aDestination,blkPath)

            if isStringScalar(blkPath)
                blkPath=convertStringsToChars(blkPath);
            end

            if ischar(blkPath)||isempty(blkPath)
                aDestination.BlockPath=blkPath;
            else
                DAStudio.error('sl_iospecification:iostrategy:errorBlockPath');
            end
        end


        function aDestination=set.BlockName(aDestination,blkName)

            if isStringScalar(blkName)
                blkName=convertStringsToChars(blkName);
            end

            if ischar(blkName)||isempty(blkName)
                aDestination.BlockName=blkName;
            else
                DAStudio.error('sl_iospecification:iostrategy:errorBlockName');
            end
        end


        function aDestination=set.SignalName(aDestination,sigName)

            if isStringScalar(sigName)
                sigName=convertStringsToChars(sigName);
            end

            if ischar(sigName)||isempty(sigName)
                aDestination.SignalName=sigName;
            else
                DAStudio.error('sl_iospecification:iostrategy:errorSignalName');
            end
        end


        function aDestination=set.PortNumber(aDestination,portNum)
            if isnumeric(portNum)||isempty(portNum)
                aDestination.PortNumber=portNum;
            else
                DAStudio.error('sl_iospecification:iostrategy:errorPort');
            end
        end


        function aDestination=set.SSID(aDestination,SSID)

            if isStringScalar(SSID)
                SSID=convertStringsToChars(SSID);
            end

            if ischar(SSID)||isempty(SSID)
                aDestination.SSID=SSID;
            else
                DAStudio.error('sl_iospecification:iostrategy:errorSSID');
            end
        end

    end
end
