function varargout=autoblksMatchTimeseriesTime(varargin)








    for i=1:nargin
        if isnumeric(varargin{i})
            Value=varargin{i};
            varargin{i}=timeseries([Value;Value],[0;1]);
        end
    end


    EqualTimes=true;
    GlobalTimeArray=varargin{1}.Time;

    for i=2:nargin
        if~isequal(varargin{i}.Time,GlobalTimeArray)
            EqualTimes=false;
            GlobalTimeArray=unique([GlobalTimeArray;varargin{i}.Time]);
        end
    end


    varargout=cell(nargout,1);

    if EqualTimes
        for i=1:nargout
            varargout{i}=varargin{i};
        end

    else
        for i=1:nargout

            OldData=varargin{i}.Data;
            OldTime=varargin{i}.Time;
            OldDataSize=size(OldData);


            NewDataSize=[length(GlobalTimeArray),OldDataSize(2:end)];
            NewData=zeros(NewDataSize);


            for j=1:numel(NewData(1,:))
                InterpData=interp1(OldTime,OldData(:,j),GlobalTimeArray,'linear');
                InterpData(GlobalTimeArray>OldTime(end))=OldData(end,j);
                InterpData(GlobalTimeArray<OldTime(1))=OldData(1,j);

                NewData(:,j)=InterpData;
            end


            NewTs=varargin{i};
            NewTs.set('Data',NewData,'Time',GlobalTimeArray);

            varargout{i}=NewTs;
        end

    end




