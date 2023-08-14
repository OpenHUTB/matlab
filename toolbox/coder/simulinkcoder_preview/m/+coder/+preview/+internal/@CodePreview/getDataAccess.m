


function out=getDataAccess(obj)
    out='';
    entry=obj.getEntry;

    if isempty(entry)||~isa(entry,'coderdictionary.data.StorageClass')
        return;
    end
    if entry.DataAccess==coderdictionary.data.DataAccessEnum.Direct||entry.DataAccess==coderdictionary.data.DataAccessEnum.Pointer
        return;
    end

    ms=entry.AccessMethod.MemorySection;
    if isempty(ms)
        msComment='';
        msPreStatement='';
        msPostStatement='';
    else
        comment=struct('string',ms.Comment,...
        'tooltip',message('SimulinkCoderApp:ui:CommentOfAccessMethodMemorySectionTooltip').getString);
        preStatement=struct('string',ms.PreStatement,...
        'tooltip',message('SimulinkCoderApp:ui:PreStatementOfAccessMethodMemorySectionTooltip').getString);
        postStatement=struct('string',ms.PostStatement,...
        'tooltip',message('SimulinkCoderApp:ui:PostStatementOfAccessMethodMemorySectionTooltip').getString);
        property='MemorySection';
        [msComment,msPreStatement,msPostStatement]=obj.pvt_getMemorySection(property,comment,preStatement,postStatement);
    end

    fcnCall='';
    if entry.DataAccess==coderdictionary.data.DataAccessEnum.Function
        fcnCall='()';
        getterLabel=message('SimulinkCoderApp:core:GetFunctionLabel').getString;
        setterLabel=message('SimulinkCoderApp:core:SetFunctionLabel').getString;
        setterArg=['const ',obj.DataType,' ',obj.DataName];
        setterReturn='void ';
    else
        getterLabel=message('SimulinkCoderApp:core:GetMacroLabel').getString;
        setterLabel=message('SimulinkCoderApp:core:SetMacroLabel').getString;
        setterArg='value';
        setterReturn='';
    end

    if entry.AccessMethod.HasGetFunction
        out=[out,'<div class="previewSection"><span class="previewHeader">'...
        ,getterLabel,':</span><div class="previewcode">'];
        getFcnName=obj.resolveAccessFunctionNameToken(entry.AccessMethod.GetFunctionName);
        switch entry.AccessMethod.AccessMode
        case coderdictionary.data.AccessModeEnum.Pointer
            fcnStr=[obj.DataType,'* ',getFcnName,fcnCall,';'];
        case coderdictionary.data.AccessModeEnum.Value
            fcnStr=[obj.DataType,' ',getFcnName,fcnCall,';'];
        case coderdictionary.data.AccessModeEnum.PointerPass
            fcnStr=['void ',getFcnName,'(',obj.DataType,'* const data);'];
        otherwise
            fcnStr='';
        end
        fcnStr=sprintf('%s%s<p>%s</p>%s',...
        msComment,...
        msPreStatement,...
        fcnStr,...
        msPostStatement);

        out=[out,fcnStr,newline,'</div></div>'];
    else
        getFcnName='';
    end

    if entry.AccessMethod.HasSetFunction
        out=[out,'<div class="previewSection"><span class="previewHeader">'...
        ,setterLabel,':</span><div class="previewcode">'];
        setFcnName=obj.resolveAccessFunctionNameToken(entry.AccessMethod.SetFunctionName);
        if entry.AccessMethod.AccessMode==coderdictionary.data.AccessModeEnum.Value
            fcnStr=[setterReturn,setFcnName,'(',setterArg,');'];

            fcnStr=sprintf('%s%s<p>%s</p>%s',...
            msComment,...
            msPreStatement,...
            fcnStr,...
            msPostStatement);
        elseif entry.AccessMethod.AccessMode==coderdictionary.data.AccessModeEnum.Pointer
            if isempty(getFcnName)
                fcnStr=[setterReturn,setFcnName,'(',obj.DataType,' *',obj.DataName,');'];
            else
                fcnStr=['*',getFcnName,'() = var;'];
            end
        elseif entry.AccessMethod.AccessMode==coderdictionary.data.AccessModeEnum.PointerPass
            fcnStr=['void ',setFcnName,'(const ',obj.DataType,' * const data);'];
        end
        out=[out,fcnStr,newline,'</div></div>'];
    end
end


