
function Ast=GetParsedAstFromModel(modelHandle)
    Ast=[];

    try
        SerializedAst=slcc('getSerializedAst',modelHandle);
        if~isempty(SerializedAst)
            Ast=internal.cxxfe.ast.Ast.deserializeFromUTF8String(SerializedAst,internal.cxxfe.ast.io.IoFormat.json);
        end
    catch ME
        reportAsError(MSLDiagnostic(ME),get_param(modelHandle,'Name'),1);
    end

end