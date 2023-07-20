function varargout=set(h,varargin)



















    SimulinkTsProps={'BlockPath','PortIndex','SignalName','ParentName','RegionInfo'};
    if nargin>=3
        for k=1:floor((nargin-1)/2)
            if any(strcmpi(varargin{2*k-1},SimulinkTsProps))
                h.(varargin{2*k-1})=varargin{2*k};
            else
                if~strcmpi(varargin{2*k-1},'tsvalue')




                    if strcmpi('time',varargin{2*k-1})
                        h.tsValue.Time=varargin{2*k};
                    elseif strcmpi('data',varargin{2*k-1})
                        try
                            h.tsValue.Data=varargin{2*k};
                        catch me


                            if(strcmpi('MATLAB:timeseries:chkDataProp:arraymismatch',me.identifier)||strcmpi('MATLAB:timeseries:utreshape:datatimearraymismatch',me.identifier))&&...
                                isempty(h.tsValue.Data)
                                h.TsValue.dataInfo.InterpretSingleRowDataAs3D=~h.TsValue.dataInfo.InterpretSingleRowDataAs3D;
                                h.tsValue.Data=varargin{2*k};
                            else
                                rethrow(me);
                            end
                        end

                    else
                        h.tsValue=set(h.tsValue,varargin{2*k-1},varargin{2*k});
                    end
                else
                    h.tsValue=varargin{2*k};
                end
            end
        end
    elseif nargin==2
        if~ischar(varargin{1})
            error(message('Simulink:Logging:SlTimeseriesSetInvprop'));
        end
        if any(strcmpi(varargin{1},SimulinkTsProps))
            Out=get(h,varargin{1});
        else
            Out=set(h.TsValue,varargin{1});
        end
        if nargout==0
            disp(Out);
        else
            varargout{1}=Out;
        end
    elseif nargin==1
        Out=get(h);
        if nargout==0
            disp(Out);
        else
            varargout{1}=Out;
        end
    end




