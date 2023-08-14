function obj=getTimeseriesObject(name,varargin)




    if isequal(nargin,1)
        blockType='IO Data Source';
    else
        blockType=varargin{1};
    end

    if~evalin('base',['exist(''',name,''')'])
        error(message('ioplayback:utils:TimeseriesObjNotFound',name,blockType));
    else

        obj=evalin('base',name);
        szTime=size(obj.Time);
        szData=size(obj.Data);
        switch blockType
        case 'IO Data Source'
            if~isequal(szTime(1),szData(1))
                error(message('ioplayback:utils:InvalidTimeseriesObjDimension',...
                name,blockType));
            end
        case 'Interrupt Event Source'

        end
    end
end
