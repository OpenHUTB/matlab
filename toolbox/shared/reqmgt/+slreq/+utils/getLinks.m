function result=getLinks(varargin)

    if isstruct(varargin{1})
        src=varargin{1};
    else
        src=slreq.utils.getRmiStruct(varargin{1});
    end
    if isempty(src.artifact)


        result=[];
        return;
    end

    if nargin==2||(nargin==3&&varargin{2}>0&&varargin{3}<0)

        src.id=sprintf('%s.%d',src.id,varargin{2});
        result=slreq.data.ReqData.getInstance.getOutgoingLinks(src);
    elseif strcmp(src.domain,'linktype_rmi_simulink')&&rmisl.is_signal_builder_block(varargin{1})

        [~,mdlName]=fileparts(src.artifact);
        [~,~,result]=slreq.getSigbGrpData([mdlName,src.id],false);
    else

        result=slreq.data.ReqData.getInstance.getOutgoingLinks(src);
    end

    if~isempty(result)&&nargin==3&&varargin{2}>0&&varargin{3}>=0

        offset=varargin{2};
        count=varargin{3};
        result=result(offset:offset+count-1);
    end
end
