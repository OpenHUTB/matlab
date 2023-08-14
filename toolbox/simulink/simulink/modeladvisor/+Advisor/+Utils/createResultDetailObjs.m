function objs=createResultDetailObjs(InputData,varargin)


    if ischar(InputData)
        InputData={InputData};
    end
    if isnumeric(InputData)
        SIDCell=cell(1,length(InputData));
        for i=1:length(InputData)
            SIDCell{i}=InputData(i);
        end
        InputData=SIDCell;
    end
    if numel(InputData)>0

        for i=1:numel(InputData)
            objs(i)=ModelAdvisor.ResultDetail;
            typeString='SID';
            for j=1:(nargin-1)/2
                name=varargin{2*j-1};
                value=varargin{2*j};
                if strcmpi(name,'Type')
                    typeString=value;
                else
                    objs(i).(name)=value;
                end
            end
            ModelAdvisor.ResultDetail.setData(objs(i),typeString,InputData{i});
        end
    else
        objs=[];
    end
end
