classdef PortInfo<handle











    properties
        Type='generic';
        Label='';
        Side='Right';
        Id='';
        ConnectionCallback='';
    end
    methods
        function pInfo=PortInfo(varargin)
            mlock;
            if nargin==4
                pInfo.Type=varargin{1};
                pInfo.Label=varargin{2};
                pInfo.Side=varargin{3};
                pInfo.Id=varargin{4};
            elseif nargin==3
                pInfo.Type=varargin{1};
                pInfo.Label=varargin{2};
                pInfo.Side=varargin{3};
                pInfo.Id=varargin{2};
            elseif nargin~=0
                pm_error('sm:sli:portinfo:InvalidNumOfArgs');
            end
            pInfo.Side=[upper(pInfo.Side(1)),pInfo.Side(2:end)];
        end

        function set.Type(thisPortInfo,pType)
            if ischar(pType)
                portsInfo(1)=sm_ports_info('frame');
                portsInfo(2)=sm_ports_info('geometry');
                portsInfo(3)=sm_ports_info('beltcable');
                validTypes={portsInfo.PortType};
                if any(strcmpi(validTypes,pType))
                    thisPortInfo.Type=pType;
                else
                    pm_error('sm:sli:portinfo:InvalidPortType',pType);
                end
            else
                pm_error('sm:sli:portinfo:PortTypeNotChar');
            end
        end

        function set.Label(thisPortInfo,pLabel)
            if ischar(pLabel)
                thisPortInfo.Label=pLabel;
            else
                pm_error('sm:sli:portinfo:PortLabelNotChar');
            end
        end

        function set.Side(thisPortInfo,pSide)
            if ischar(pSide)
                if strcmpi('Right',pSide)
                    thisPortInfo.Side='Right';
                end
                if strcmpi('Left',pSide)
                    thisPortInfo.Side='Left';
                end
            else
            end
        end

        function set.ConnectionCallback(thisPortInfo,cbStr)
            if ischar(cbStr)
                thisPortInfo.ConnectionCallback=cbStr;
            else
                pm_error('sm:sli:portinfo:InvalidPortCallBack');
            end
        end
    end
end


