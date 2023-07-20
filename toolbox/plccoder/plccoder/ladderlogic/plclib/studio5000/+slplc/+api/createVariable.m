function var=createVariable(varName,varargin)




    p=inputParser;

    p.addRequired('Name',@(x)ischar(x));
    p.addParameter('Scope','Local',@(x)ismember(x,{'Local','Input','Output','InOut','External','Global'}));
    p.addParameter('PortIndex','1',@(x)(mod(str2double(x),1)==0)&&(str2double(x)>0));
    p.addParameter('DataType',slplc.utils.getDefaultDataType(),@(x)ischar(x));
    p.addParameter('InitialValue',[],@(x)isempty(x)||ischar(x));
    p.addParameter('IsFBInstance',false,@(x)x==0||x==1||islogical(x));
    p.addParameter('Access','readwrite',@(x)ischar(x));

    p.addParameter('PortType','',@(x)isempty(x)||ismember(x,{'Hidden','Inport','Outport','Inport/Outport'}));
    p.addParameter('Size','',@(x)isempty(x)||ischar(x));
    p.addParameter('IsAutoImport',[],@(x)isempty(x)||x==0||x==1||islogical(x));

    p.parse(varName,varargin{:});
    res=p.Results;

    if isempty(res.InitialValue)&&res.IsFBInstance


        varInitialValue=getFBInitialValueName(res.DataType);
    elseif strcmpi(varName,'EnableIn')&&isempty(res.InitialValue)

        varInitialValue='true';
    elseif strcmpi(varName,'EnableOut')&&isempty(res.InitialValue)


        varInitialValue='false';
    else

        varInitialValue=res.InitialValue;
    end
    var=slplc.utils.createNewVar(res.Name,res.Scope,res.PortIndex,res.DataType,varInitialValue,res.IsFBInstance,res.Access);

    if~isempty(res.PortType)
        var.PortType=res.PortType;
    end

    if~isempty(res.Size)
        var.Size=res.Size;
    end

    if~isempty(res.IsAutoImport)
        var.IsAutoImport=res.IsAutoImport;
    end
end

function fbInitValueName=getFBInitialValueName(dataType)
    fbType=strrep(dataType,'Bus: ','');
    fbInitValueName=[fbType,'_InitialValue'];
end


