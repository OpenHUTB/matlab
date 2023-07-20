function obj=getClassInterfaceSpecification(modelName)











    if nargin>0
        modelName=convertStringsToChars(modelName);
    end

    if ischar(modelName)
        try
            hModel=get_param(modelName,'Handle');
        catch exc %#ok<NASGU>
            DAStudio.error('RTW:fcnClass:invalidModelName',modelName);
        end
    else
        hModel=modelName;
    end

    try
        obj=get_param(hModel,'object');
        if~obj.isa('Simulink.BlockDiagram')
            DAStudio.error('RTW:fcnClass:invalidMdlHdl');
        end
    catch exc %#ok<NASGU>
        DAStudio.error('RTW:fcnClass:invalidMdlHdl');
    end

    obj=get_param(hModel,'RTWCPPFcnClass');

    if isempty(obj)||~ishandle(obj)||~isa(obj,'RTW.ModelCPPClass')
        obj=[];
    else
        obj.ModelHandle=hModel;
    end
