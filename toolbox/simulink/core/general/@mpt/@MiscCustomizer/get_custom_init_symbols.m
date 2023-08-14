function varargout=get_custom_init_symbols(hcustom)





    symbols={};

    if~isempty(hcustom)&&isprop(hcustom,'MPFSymbolDefinition')&&...
        ~isempty(hcustom.MPFSymbolDefinition)

        symStruct.symbolName='';
        symStruct.symbolExpand=[];
        symStruct.dataPlacementFunction=[];
        symStruct.dataPlacementFile=[];
        symStruct.duplicateFlag='No';
        symStruct.parent='Documentation';

        try
            for i=1:length(hcustom.MPFSymbolDefinition)
                obj=hcustom.MPFSymbolDefinition{i};
                symbols{end+1}=symStruct;
                symbols{end}.symbolName=obj.Name;
                prop=getProperty(obj,'Property');
                for j=1:length(prop)
                    switch lower(prop{j}{1})
                    case 'symbolexpand'
                        symbols{end}.symbolExpand=prop{j}{2};
                    case 'dataplacementfunction'
                        symbols{end}.dataPlacementFunction=prop{j}{2};
                    case 'dataplacementfile'
                        symbols{end}.dataPlacementFile=prop{j}{2};
                    case 'duplicateflag'
                        symbols{end}.duplicateFlag=prop{j}{2};
                    case 'parent'
                        symbols{end}.parent=prop{j}{2};
                    otherwise
                    end
                end
            end
        catch ME
            MSLDiagnostic('Simulink:mpt:MPTSLGenMsg',ME.message).reportAsWarning;
        end
    end
    varargout{1}=symbols;

