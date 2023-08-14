

classdef WebscopesStreamingSource<matlabshared.scopes.WebWindow&...
    matlabshared.scopes.WebDynamicStreamingSource

    properties
        ScopeLocked=true;
    end

    methods



        function str=getQueryString(this)
            str=getQueryString@matlabshared.scopes.WebDynamicStreamingSource(this);
        end

        function varargout=setDebugLevel(this,varargin)
            [varargout{1:nargout}]=setDebugLevel@matlabshared.scopes.WebDynamicStreamingSource(this,varargin{:});
        end

        function level=getDebugLevel(this)
            level=getDebugLevel@matlabshared.scopes.WebDynamicStreamingSource(this);
        end
    end

    methods(Access=private,Hidden)


        function signalInfoObject=getSignalInfoObject(this,signalIdsToWrite,userData,varargin)

            numSigs=numel(signalIdsToWrite);
            signalInfoObject=[];
            signalInfoObject.clientID=this.ClientId;
            signalInfoObject.userData=userData;
            for indx=1:numSigs
                dataSize=size(varargin{indx});
                sigInfo.frame=dataSize(1);
                sigInfo.channel=dataSize(2);
                sigInfo.uuid=signalIdsToWrite{indx};

                signalInfoObject.signalInfo(indx)=sigInfo;
            end
            signalInfoObject=jsonencode(signalInfoObject);
        end
    end

    methods(Hidden)


        function write(this,signalIdsToWrite,varargin)
            if(~this.ScopeLocked)


                this.release();
                this.setupStreamingSource();
                this.ScopeLocked=true;
            end
            userData=struct;
            if isstruct(varargin{end})
                userData=varargin{end};
                varargin=varargin(1:end-1);
            end
            varargin=varargin{:};
            numData=numel(varargin);
            assert(isequal(numel(signalIdsToWrite),numData));

            varargin=cellfun(@double,varargin,'UniformOutput',false);
            signalInfoObject=this.getSignalInfoObject(signalIdsToWrite,userData,varargin{:});
            varargin{end+1}=signalInfoObject;

            this.StreamingSourceImpl.write(varargin{:});
        end

        function release(this)
            this.StreamingSourceImpl.release();
            this.releaseStreamingSource();
            this.ScopeLocked=false;
        end
    end

    methods(Access=protected)
        function value=getDataProcessingStrategy(~)
            value='webscope_nontime_dataproc_strategy';
        end

        function value=getFilterImpls(~)

            value={'webscope_datastorage_filter',...
            'webscope_thinner_filter'};
        end

        function isTimeBased=isTimeBased(~)

            isTimeBased=false;
        end

        function h=getMessageHandler(~)
            h=sigwebappsutils.internal.webscopes.WebscopesStreamingSourceMessageHandler;
        end
    end

    methods
        function setAxesLimits(this,axesLimits)
            this.MessageHandler.setAxesLimits(axesLimits);
        end

        function clientID=getClientID(this)
            clientID=this.ClientId;
        end

        function delete(this)
            delete(this.MessageHandler);
        end
    end
end