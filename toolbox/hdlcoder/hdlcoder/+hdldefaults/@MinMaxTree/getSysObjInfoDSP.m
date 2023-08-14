function[blockDSPInfo,v]=getSysObjInfoDSP(this,hC,v)%#ok<INUSL>



    if nargin<3
        v=[];
    end

    sysObjHandle=hC.getSysObjImpl;
    operOver=sysObjHandle.Dimension;
    blockName=hC.Name;
    blockDSPInfo=[];

    switch lower(operOver)
    case 'column'
        blockDSPInfo.operateOver='column';

    case 'row'
        blockDSPInfo.operateOver='row';

    case 'custom'
        blockDSPInfo.operateOver='dim';

    case 'all'
        if~isempty(v)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:unsupportedEntireInputMode'));
            return;
        else
            error(message('hdlcoder:validate:unsupportedEntireInputMode'));
        end

    otherwise
        if~isempty(v)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:emlunsupported',blockName));
            return;
        else
            error(message('hdlcoder:validate:emlunsupported',blockName));
        end
    end

    if strcmpi(blockDSPInfo.operateOver,'dim')
        blockDSPInfo.specifyDim=str2double(sysObjHandle.CustomDimension);
    else
        blockDSPInfo.specifyDim=1;
    end

end
